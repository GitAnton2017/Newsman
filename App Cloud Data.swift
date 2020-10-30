//
//  AppCloudData.swift
//  Newsman
//
//  Created by Anton2016 on 10.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import CloudKit
import Combine
import RxSwift
import CoreData

class AppCloudData: NSObject
{
 final var cnxx = Set<AnyCancellable>() //the Combine dispose bag for Publishers subscriptions.
 
 static let zoneNameSuffix = "Zone"
 static let privateDBSubscriptionID: CKSubscription.ID = "privateDBSubscriptionName"
 
 static let cloudMetaDataFieldName = "ck_metadata"
 static let idFieldName = "id"
 static let isCloudedFieldName = "isClouded"
 static let notCloudedFieldNames = [cloudMetaDataFieldName, idFieldName, isCloudedFieldName]
  
 final var privateDB: CKDatabase { CKContainer.default().privateCloudDatabase }
 final var publicDB:  CKDatabase { CKContainer.default().publicCloudDatabase  }
 final var sharedDB:  CKDatabase { CKContainer.default().sharedCloudDatabase  }
 
 final func cloudDB(_ scope: CKDatabase.Scope) -> CKDatabase { CKContainer.default().database(with: scope) }
 
 final var appDelegate: AppDelegate { UIApplication.shared.delegate as! AppDelegate }
 final var mom: NSManagedObjectModel { appDelegate.persistentContainer.managedObjectModel }
 final var moc: NSManagedObjectContext { appDelegate.viewContext }
 
 final var backgroundContext: NSManagedObjectContext { appDelegate.backgroundContext }
 
 //The operation queue to execute Modify and Delete Batch Cloud Operations.
 final lazy var operationQueue: OperationQueue =
 {
  let queue = OperationQueue()
  queue.qualityOfService = .utility
  return queue
 }()
 
 final var prevBatchOperation: ModifyBatchCloudOperation?
 final var batchOperationBuffer = Set<BatchCloudOperation>()
 {
  didSet
  {
   print("******************************************************************************** ")
   print("<<< OPERATION BUFFER CHANGED >>> THE LIST OF UNFINISHED BATCH OPERATIONS:")
   print("******************************************************************************** ")
   batchOperationBuffer.enumerated().forEach
   {
    print("[\($0.0)] - ID: [\($0.1.name ?? "NO ID")] [ \($0.1.debugDescription)]")
   }
   print("********************************************************************************\n ")
  }
 }
 //The referance to previous operation is needed to create dependancy between consequent batch operations
 //to avoid cloud DB records save conflicts.
 
//******************************************************************************
 final var privateDBSubscriber: AnyPublisher<Void, CKError>
//******************************************************************************
//This method returns Combine.Pudlisher that cerates private DB modify subscription when subscribed.
//The new subscription is created once and forever when app first starts and this action is reflected
//in user defaults BD by setting flag to true under the key AppCloudData.privateDBSubscriptionID.
//The DB modify subscription is created via CloudKit.CKModifySubscriptionsOperation under the same name.
 {
  Future<Void, CKError>
  {promise in
  
   if UserDefaults.standard.bool(forKey: AppCloudData.privateDBSubscriptionID)
   {
    promise(.success(()))
    return
   }
   
   let newSub = CKDatabaseSubscription(subscriptionID: AppCloudData.privateDBSubscriptionID)
   let info = CKSubscription.NotificationInfo()
   info.shouldSendContentAvailable = true
   newSub.notificationInfo = info

   let subSaveOp = CKModifySubscriptionsOperation(subscriptionsToSave: [newSub], subscriptionIDsToDelete: nil)
   
   subSaveOp.modifySubscriptionsCompletionBlock = { saved, _ , error in
    guard let error = error as? CKError else
    {
     UserDefaults.standard.set(true, forKey: AppCloudData.privateDBSubscriptionID)
     promise(.success(()))
     return
    }
    
    promise(.failure(error))
   }
   
   self.cloudDB(.private).add(subSaveOp)
  }.eraseToAnyPublisher()
  
 }
// ***** var privateDBSubscriber: AnyPublisher<CKSubscription, CKError>...
 
//******************************************************************************
  final func configueCloudDB (_ scope: CKDatabase.Scope)
//******************************************************************************
//This method creates subscription Combine.Publisher that generates new private DB subscription.
 {
  switch scope
  {
    case .private: privateDBSubscriber.sink(receiveCompletion:
    { result in
      switch result
      {
       case .failure(let error):
        print ("<<<ERROR OCCURED!>>> WHEN CREATING PRIVATE CLOUD DB SUBSCRIPTION: \(error.localizedDescription)")
       
       case .finished: print ("<<< **** PRIVATE CLOUD DB SUBSCRIPTION SUCCESSFULLY CREATED! **** >>>")
        self.configueContextObservers()
      }
     
    }, receiveValue: {_ in }).store(in: &cnxx)
     
   case .public: break
   case .shared : break
   @unknown default: break
  }
 }
//**** func configueCloudDB (_ scope: CKDatabase.Scope)...
 
 
//****************************************************************************
 final private func initializeZonesDefaults()
//****************************************************************************
//Record Zones are genarated lazily when first BaseSnippet is created and saved in private cloud DB.
//The corresponding flag is set to false in user defaults under the key of the new zome name.
//When zone is created the flag will be set to true.

 {
  let entities = mom.entities
   .filter { !$0.isAbstract && $0.isKindOf(entity: BaseSnippet.entity()) }
   .compactMap{ $0.name?.appending(AppCloudData.zoneNameSuffix) }
  
  var defaults = Dictionary(uniqueKeysWithValues: entities.map{($0, false)})
  
  defaults[AppCloudData.privateDBSubscriptionID] = false
  
  UserDefaults.standard.register(defaults: defaults)
  
 }
//***** private func initializeZonesDefaults()...
 
 
//*******************************************************************************
 final func recordZone(for object: CKRecordConvertable) -> Single<CKRecordZone?>
//*******************************************************************************
//This method returns RxSwift.Single observable which creates new zone in private DB when subscribed.
//The zone is created via CloudKit.CKModifyRecordZonesOperation.
 {
  Single.create { promise in
   
    let disposable = Disposables.create()
    
   
    guard let zoneName = object.entity.name?.appending(AppCloudData.zoneNameSuffix) else
    {
     promise(.success(nil))
     return disposable
    }
   
    let zoneID = CKRecordZone.ID(zoneName: zoneName)
    let zone = CKRecordZone(zoneID: zoneID)
   
    if UserDefaults.standard.bool(forKey: zoneName) { promise(.success(zone))  } else
    {
     let zoneSaveOp = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)

     zoneSaveOp.modifyRecordZonesCompletionBlock = {saved, _ , error in
      guard let error = error as? CKError else
      {
       UserDefaults.standard.set(true, forKey: zoneName)
       promise(.success(saved?.first))
       return
      }
      
      promise(.error(error))
     }
     
     self.cloudDB(.private).add(zoneSaveOp)
    }
   
    return disposable
  }
 }
//***** func recordZone(for object: CKRecordConvertable) -> Single<CKRecordZone?>
 
//******************************************************************************************
 final func recordZoneName(for object: CKRecordConvertable) -> String?
//******************************************************************************************
 {
  let entity = object.entity
  
  if entity.isKindOf(entity: BaseSnippet.entity())
  {
   return entity.name?.appending(AppCloudData.zoneNameSuffix)
  }
  
  return entity.relationshipsByName.values
   .compactMap { $0.destinationEntity }
   .filter { $0.isKindOf(entity: BaseSnippet.entity()) }
   .first?.name?.appending(AppCloudData.zoneNameSuffix)
 }
 
 
//******************************************************************************************
 final func recordZone(for object: CKRecordConvertable) -> Future<CKRecordZone?, CKError>
//******************************************************************************************
//This method returns Combine.Future which creates new zone in private DB when subscribed.
//The zone is created via CloudKit.CKModifyRecordZonesOperation.
 {
  Future<CKRecordZone?, CKError> { promise in
  
   guard let zoneName = self.recordZoneName(for: object) else
   {
    promise(.success(nil))
    return
   }
   
   let zoneID = CKRecordZone.ID(zoneName: zoneName)
   let zone = CKRecordZone(zoneID: zoneID)
   
   if UserDefaults.standard.bool(forKey: zoneName) { promise(.success(zone)) } else
   {
    let zoneSaveOp = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)

    zoneSaveOp.modifyRecordZonesCompletionBlock = {saved, _ , error in
     guard let error = error as? CKError else
     {
      UserDefaults.standard.set(true, forKey: zoneName)
      promise(.success(saved?.first))
      return
     }
     
     promise(.failure(error))
    }
    
    self.cloudDB(.private).add(zoneSaveOp)
   }
   
  }
 }//************ func recordZone(for object: CKRecordConvertable)*****************
 
 
 
 
 typealias UserInfoType = [AnyHashable : Any] //Notification info dictionary type.
 
//******************************************************************************************
 final var contextChangePublisher: AnyPublisher<UserInfoType, Never>
//******************************************************************************************
//This calculated property returns shared Combine.Publisher which generates the sequence of
//user info dictionaries ([AnyHashable : Any]) from NSManagedObjectContextObjectsDidChange notification.
 {
  NotificationCenter.default
   .publisher(for: .NSManagedObjectContextObjectsDidChange, object: moc)
   .compactMap{ $0.userInfo }
   .share()
   .eraseToAnyPublisher()
 }//*********** final var contextChangePublisher **************
 


 
 private func hasUncloudedChanges(in object: NSManagedObject, with record: CKRecord) -> Bool
 {
  let recordFields = record.allKeys().compactMap{ record[$0] }
  let objectFields = record.allKeys().compactMap{ object.value(forKey: $0) as? CKRecordValue}
  
  guard recordFields.count == objectFields.count else { return true }
  
  return zip(recordFields, objectFields).first
  {
   switch ($0.0, $0.1)
   {
    case let (rf as NSString, of as NSString) where rf != of : return true
    case let (rf as NSNumber, of as NSNumber) where rf != of : return true
    case let (rf as NSArray,  of as NSArray)  where rf != of : return true
    case let (rf as NSDate,   of as NSDate)   where rf != of : return true
    case let (rf as NSData,   of as NSData)   where rf != of : return true
    default: return false
   }
  } != nil
 }
 
 private func localObjectsUpdater(for modifiedRecords: [CKRecord]) -> AnyPublisher<Void, Error>
 {
  moc.persist
  {
   modifiedRecords.forEach
   {record in
    let request = NSFetchRequest<NSManagedObject>(entityName: record.recordType)
    let predicate = NSPredicate(format: "SELF.id == %@", record.recordID.recordName)
    request.predicate = predicate
    guard let insertedObject = try? self.moc.fetch(request).first as? CKRecordConvertable else { return }
    let coder = NSKeyedArchiver(requiringSecureCoding: true)
    record.encodeSystemFields(with: coder)
    insertedObject.ck_metadata = coder.encodedData as NSData //ENCODE AND SAVE NEW RECORD META DATA!!!
    print("CLOUDED MO METADATA HAS BEEN UPDATED: \(insertedObject.recordName!)")
   }
  }
 }//private func localObjectsUpdater...
 
 
 private func updateLocalObjects(from records: [CKRecord])
 {
  DispatchQueue.main.async
  {
   self.moc.persist({
    records.forEach
    {record in
     let request = NSFetchRequest<NSManagedObject>(entityName: record.recordType)
     let predicate = NSPredicate(format: "SELF.id == %@", record.recordID.recordName)
     request.predicate = predicate
     guard let insertedObject = try? self.moc.fetch(request).first as? CKRecordConvertable else { return }
     let coder = NSKeyedArchiver(requiringSecureCoding: true)
     record.encodeSystemFields(with: coder)
     insertedObject.ck_metadata = coder.encodedData as NSData //ENCODE AND SAVE NEW RECORD META DATA!!!
     insertedObject.isClouded = !self.hasUncloudedChanges(in: insertedObject, with: record)
     // if some fields of corresponding MO have been modified up until this moment
     // mark this MO to be updated into the clouds during the next generated update operation...
     print("CLOUDED MO METADATA HAS BEEN UPDATED: \(insertedObject)")
    }
   })
   {result in
    
   }
  }
 }
 
 // <<<<<< ************** CREATION NEW MOs IN CLOUD ***************** >>>>>>>>
 

//******************************************************************************************
 final var updateCloudedStatePublisher: AnyPublisher<CKRecordConvertable, Never>
//******************************************************************************************
// This calcuated property returns Combine.Publisher that generates the sequence of MO references.
// The MO reference generated after MO is modified in MOC if <isClouded> flag is set to true
// which means that local MO has modified filelds and must update isClouded property
 {
  contextChangePublisher
   .compactMap{ ($0[NSUpdatedObjectsKey] as? NSSet)?.allObjects as? [CKRecordConvertable] }
   .flatMap{ $0.publisher }
   .filter { $0.isClouded }
   .handleEvents(receiveOutput: //for debug perposes!
    { object in
      print("************************************************************************************************")
      print("<<<UPDATED STATE PUBLISHER>>> CLOUDED STATE CHANGED FOR: (\(object.recordName!))")
      print("************************************************************************************************")
      print("List of changed filelds: ")
      object.changedValuesForCurrentEvent().forEach
      {
       print ("Key: [\($0.key)] from value: \($0.value) to value: \(object.value(forKey: $0.key) ?? "n/v")")
      }
      print("\n")
    })
   .eraseToAnyPublisher()
 }//************************ final var updatedObjectsPublisher ************************************
 

 
 
 func cloudRecordsDeleter(batch: [CKRecord.ID], for scope: CKDatabase.Scope) -> AnyPublisher<[CKRecord.ID], CKError>
 {
  Future<[CKRecord.ID], CKError>
  {promise in
   let deleteOp = CKModifyRecordsOperation(recordsToSave: nil , recordIDsToDelete: batch)
   deleteOp.modifyRecordsCompletionBlock = { _, deleted, error in
    guard let deleteError = error as? CKError else
    {
     promise(.success(deleted!))
     return
    }
    
    promise(.failure(deleteError))
   }
   
   self.cloudDB(scope).add(deleteOp)
    
  }.eraseToAnyPublisher()
 }//func cloudRecordsSaver...
 
 
 
 
//*********************************************************************************************************
 private final func configueContextObservers()
//*********************************************************************************************************
// This method creates subscription to the cloud modify operations publisher which generates sequence of
// cloud batch records modify operations and records delete operations.
 {

  cloudModifyOperationsPublisher(for: .private).sink(receiveCompletion:
  {
   switch $0
   {
    case .finished:
     print ("**** <<< RECORDS UPDATED SUCCESSFULLY INTO PRIVATE DB!>>> ****")
    case .failure(let error):
     print ("<<<ERROR>>> UPDATING RECORDS INTO PRIVATE DB FAILED: <\(error.localizedDescription)>")
   
   }
  }, receiveValue: {records in
   print("*************************** <<< FINAL UPDATED RECORDS REPORT >>> *********************************")
   records.map{ $0.recordID.recordName }.enumerated().forEach
   {
    print ("[\($0.offset)] CK RECORD ID <\($0.element)> UPDATED SUCCESSFULLY TO PRIVATE CLOUD DB!")
   }
   print("**************************************************************************************************")
   print("\n")
  }).store(in: &cnxx)
  
  cloudDeleteOperationsPublisher(for: .private).sink(receiveCompletion:
  {
   switch $0
   {
    case .finished:
     print ("**** <<< RECORDS DELETED SUCCESSFULLY FROM PRIVATE DB!>>> ****")
    case .failure(let error):
     print ("<<<ERROR>>> DELETING RECORDS FROM PRIVATE DB FAILED: <\(error.localizedDescription)>")
   
   }
  }, receiveValue: {records in
   print("*************************** <<< FINAL DELETED RECORDS REPORT >>> *********************************")
   records.map{ $0.recordName }.enumerated().forEach
   {
    print ("[\($0.offset)] CK RECORD ID <\($0.element)> DELETED SUCCESSFULLY FROM PRIVATE CLOUD DB!")
   }
   print("**************************************************************************************************")
   print("\n")
  }).store(in: &cnxx)
 }
 

 override init()
 {
  super.init()
  initializeZonesDefaults()
  
 }//override init()
 
 
}// AppCloudData manager...
