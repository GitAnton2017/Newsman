//
//  CKRecordConvertable.swift
//  Newsman
//
//  Created by Anton2016 on 10.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import CloudKit
import CoreData
import Combine

protocol CKRecordConvertable where Self: NSManagedObject
{
 var isClouded:   Bool                 { get set }
 var ck_metadata: NSData?              { get set } //AppCloudData.cloudMetaDataFieldName...
 //var id:          UUID?               { get set } //AppCloudData.idFieldName...
 var ck_assets:  [ String : URL? ]       { get }
 
 var recordName: String!               { get set }
 
 var changedFieldsInCurrentBatchModifyOperation: Set<String> { get set }
 
 var removedChildenRecords: Set<NSManagedObject> { get set }
 
 
}

extension BaseSnippet: CKRecordConvertable
{
 var ck_assets: [String : URL?] { [:] }
 
 public override func awakeFromFetch()
 {
  super.awakeFromFetch()
  recordName = id!.uuidString
 }

}

extension Photo: CKRecordConvertable
{
 var ck_assets: [String : URL?] { ["imageData" : self.url] }
 
 public override func awakeFromFetch()
 {
  super.awakeFromFetch()
  recordName = id!.uuidString
 }
 
 
}

extension PhotoFolder: CKRecordConvertable
{
 var ck_assets: [String : URL?] { [:] }
 
 public override func awakeFromFetch()
 {
  super.awakeFromFetch()
  recordName = id!.uuidString
 }
 
 
}
 
extension CKRecordConvertable
{
 
 var appCloudData: AppCloudData { (UIApplication.shared.delegate as! AppDelegate).appCloudData }
 
 private var moc: NSManagedObjectContext  { appCloudData.moc               }
 private var bmoc: NSManagedObjectContext { appCloudData.backgroundContext }
 
 var backgroundObject: NSManagedObject?
 {
  guard let context = self.managedObjectContext else
  {
   print("<<< MOC ERROR >>> MO: [\(debugDescription)] IS NOT REGISTERED IN ANY MOC!")
   return nil
  }
  
  if ( context.concurrencyType == .mainQueueConcurrencyType && context === moc )
  {
   return bmoc.object(with: objectID)
  }
  
  if (context.concurrencyType == .privateQueueConcurrencyType && context === bmoc )
  {
   return self
  }
  
  print("<<< MOC ERROR >>> MO: [\(debugDescription)] HAS UNKNOWN MOC !")
  return nil

 }
 
 
 var cloudedAttributesKeys: Set<String>
 //only MO attributes that are not in service field names array are generated in CKRecord!!
 {
  Set(entity.attributesByName.keys.filter{ !AppCloudData.notCloudedFieldNames.contains($0) })
 }
 
 var cloudedRelationshipsKeys: Set<String>
 //only MO TO-ONE ralationships are generated in CKRecord as CKRecord.Refererences to parent their object!!
 {
  Set(entity.relationshipsByName.filter{ !$0.value.isToMany }.map{ $0.key })
 }
 
 var toManyRelationshipsKeys: Set<String>
 {
  Set(entity.relationshipsByName.filter{ $0.value.isToMany }.map{ $0.key })
 }
 
 var allCloudedKeys: Set<String> { cloudedAttributesKeys.union(cloudedRelationshipsKeys) }
 
 var changedKeysForCurrentEvent: Set<String> { Set(changedValuesForCurrentEvent().keys) }
 
 var cloudedKeysForCurrentEvent: Set<String> { allCloudedKeys.intersection(changedKeysForCurrentEvent) }
 
 var toManyRelationshipsForCurrentEvent: Set<String>
 {
  changedKeysForCurrentEvent.intersection(toManyRelationshipsKeys)
 }
 
 func updateRemovedChildren()
 {
  if toManyRelationshipsForCurrentEvent.isEmpty { return }
  let allChanges = changedValuesForCurrentEvent()
  toManyRelationshipsForCurrentEvent.forEach
  {key in
   let old = (allChanges[key] as? Set<NSManagedObject>) ?? []
   let new = (value(forKey: key) as? Set<NSManagedObject>) ?? []
   let diff = old.symmetricDifference(new)
   removedChildenRecords.formUnion(diff)
  }
 }
 
 func updateCloudedState()
 {
  if cloudedKeysForCurrentEvent.isEmpty { return }
  changedFieldsInCurrentBatchModifyOperation.formUnion(cloudedKeysForCurrentEvent)
  //all changes in MO from this device are saved in this set to be used in case of CKRecord save conflicts & merging data
  
  guard isClouded else { return }
  managedObjectContext?.perform { self.isClouded = false }
 
 }
 
 // this Publisher emits either absolutely new CKRecord based on MO Self or the one with saved metadata...
 // first off it checks if there exists CKDatabaseSubscription to trace changes
 // secondly it emits existing CKRecordZone for CKRecord or creates new one in private DB
 
 var cloudRecordIDPublisher: AnyPublisher<CKRecord.ID, CKError>
 {
  //guard let recordName = id?.uuidString else { return Empty().eraseToAnyPublisher() }
  
  return appCloudData
   .recordZone(for: self)
   .compactMap{$0?.zoneID}
   .map { CKRecord.ID(recordName: self.recordName, zoneID: $0) }
   .eraseToAnyPublisher()
 }
 
 var cloudRecordPublisher: AnyPublisher<CKRecord, CKError>
 {
  guard let recordType = entity.name else { return Empty().eraseToAnyPublisher() }
  guard managedObjectContext != nil else { return Empty().eraseToAnyPublisher() }
  if isDeleted { return Empty().eraseToAnyPublisher() }
  
  //guard let recordName = id?.uuidString else { return Empty().eraseToAnyPublisher() }
  
  let recordPublisher = appCloudData.recordZone(for: self).compactMap {recordZone -> CKRecord? in
   //try to get async the record zone for this type of MO entity
   //if such zone cannot be created from specified MO we generate NIL and strip this case out by compactMap...
   
   guard let recordZone = recordZone else { return nil }

   // this closure generates either absolutely new CKRecord or reinstantiate it from metadata saved in MO...
   let record: CKRecord =
   {
    // sets up new default record for this zone and recordName = MO.id (UUID)
    let newRecordID = CKRecord.ID(recordName: self.recordName, zoneID: recordZone.zoneID)
    let newRecord = CKRecord(recordType: recordType, recordID: newRecordID)
    
    //MO has no CK metadata saved before we return this new record...
    guard let recordMeta = self.ck_metadata else { return newRecord }
    
    //MO has CK metadata saved before we try to reinstantiate such using saved data ...
    guard let recordDecoder = try? NSKeyedUnarchiver(forReadingFrom: recordMeta as Data) else { return newRecord }
    recordDecoder.requiresSecureCoding = true
    
    // Cannot reinstantiate CKRecord from metadta using this decoder we return default new one above...
    guard let decodedRecord = CKRecord(coder: recordDecoder) else { return newRecord }
    recordDecoder.finishDecoding()
    return decodedRecord
    
   }()
   
   //saving MO attributes (fields which do not represent relationships)
   self.cloudedAttributesKeys.forEach
   {key in
    guard let value = self.value(forKey: key) else
    {
     record[key] = nil //must be explicitly set to nil if value in existing CKRecord changes from .some to .none!!!
     return
    }
    if let value = value as? CKRecordValue { record[key] = value } //if MO field can be saved as is in CKRecord
    //otherwise archive it into data and save...
    else if let valueData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
    {
     record[key] = valueData
    }
   }
   
   //saving only to-one relationships as CKRecord referances
   self.cloudedRelationshipsKeys.forEach {key in
    guard let refObject = self.value(forKey: key) as? CKRecordConvertable else
    {
     record[key] = nil //must be explicitly set to nil if reference in existing CKRecord changes from .some to .none!!!
     return
    }
    guard let refObjectID = refObject.recordName /*id?.uuidString*/ else
    {
     record[key] = nil
     return
    }
    let recordID = CKRecord.ID(recordName: refObjectID, zoneID: recordZone.zoneID)
    let recordRef = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
    record[key] = recordRef
   }
   
   //saving all assets from urls specified in ck_assets requirement
   //assets uploaded to cloud DB only once when CKRecord created so when it has no metadata yet!
   guard self.ck_metadata == nil else { return record }
   self.ck_assets.forEach {assetName, assetURL in
    guard let assetURL = assetURL else
    {
     print ("<<< CLOUD RECORD PUBLISHER >>> MO ASSET NAMED [\(assetName)] IS NIL AND NOT ADDED TO NEW RECORD!")
     return
    }
    record[assetName] = CKAsset(fileURL: assetURL)
   }
 
   return record
  }.eraseToAnyPublisher()
  
  return appCloudData.privateDBSubscriber
   .combineLatest(recordPublisher)
   .map{ $0.1 }
   .eraseToAnyPublisher()
 
 }
}
