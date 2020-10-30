//
//  Cloud Batch Saver.swift
//  Newsman
//
//  Created by Anton2016 on 03.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import Combine
import CloudKit



extension AppCloudData
{
 
//****************************************************************************************************
 final var insertedObjectsPublisher: AnyPublisher<CKRecordConvertable, Never>
//****************************************************************************************************
// This calcuated property returns Combine.Publisher that generates the sequence of MO references.
// The MO referance generated after MO is inserted into MOC if <isClouded> flag is set to false
// which means that local MO is not saved in cloud DB yet or is created as reported from
// cloud DB APN subscription when MO has been recently created in app on some other user device.
 {
  contextChangePublisher
   .compactMap{ ($0[NSInsertedObjectsKey] as? NSSet)?.allObjects as? [CKRecordConvertable] }
   .flatMap { $0.publisher }
   .filter { !$0.isClouded }
   .handleEvents(receiveOutput:
    {
     print("**************************************************************************************************")
     print("<<<INSERTED MO PUBLISHER>>> MO: <\($0.entity.name ?? "NO ENTITY")>[\($0.recordName!)]")
     print("**************************************************************************************************")
     print("\n")
    })
   .eraseToAnyPublisher()
 }//************************************** insertedObjectsPublisher ****************************************
 

 


//********************************************************************************************************
 final var updatedObjectsPublisher: AnyPublisher<CKRecordConvertable, Never>
//********************************************************************************************************
// This calcuated property returns Combine.Publisher that generates the sequence of MO references.
// The MO referance generated after MO is modified in MOC if <isClouded> flag is set to false
// which means that local MO has modified filelds to be saved to cloud BD.
 {
  contextChangePublisher
   .compactMap{ ($0[NSUpdatedObjectsKey] as? NSSet)?.allObjects as? [CKRecordConvertable] }
   .flatMap{ $0.publisher }
   .handleEvents(receiveOutput:
    {object in
     defer
     {
      object.updateCloudedState()
      object.updateRemovedChildren()
     }
     print("*********************************************************************************************************")
     print("<<<UPDATED MO PUBLISHER>>> MO <\(object.entity.name ?? "NO ENTITY")>[\(object.recordName!)]")
     print("*********************************************************************************************************")
     print("List of changed filelds: ")
     object.changedValuesForCurrentEvent().forEach
     {
      print ("Key: [\($0.key)] from value: \($0.value) to value: \(object.value(forKey: $0.key) ?? "n/v")")
     }
     print("\n")
    })
   .filter { !$0.isClouded }
   .eraseToAnyPublisher()
 }//********************************** final var updatedObjectsPublisher ************************************
  

 //This properties define the buffering policy

 final var maxContextUpdatesBatchSize: Int { 50 }// max MO changes per operation in batch
 
 final var maxContextUpdatesInterval: DispatchQueue.SchedulerTimeType.Stride { .seconds(10) }
 //the time span to be elapsed to generate next batch for cloud records modify operation
 
 
 
//************************************************************************************************************
 final func cloudModifyOperationsPublisher(for scope: CKDatabase.Scope) -> AnyPublisher<[CKRecord], Error>
//************************************************************************************************************
// This instance method returns Combine.publisher that merges references of both inserted MOs and updated ones
// then buffers them according the policy of the time and counter of references then feeds them
// in batches to generated modify cloud DB operation publisher that is returned by managedObjectsCloudSaver method.
 {
  insertedObjectsPublisher.merge(with: updatedObjectsPublisher)
   .filter { $0.managedObjectContext != nil } // ignore if already saved deleted from context
   .filter { !$0.isDeleted } // ignore if marked to be deleted from context after save...
   .setFailureType(to: Error.self)
   .collect(.byTimeOrCount(DispatchQueue.main, maxContextUpdatesInterval, maxContextUpdatesBatchSize))
    {$0.recordName == $1.recordName}
   .flatMap { [unowned self] in self.managedObjectsCloudSaver(batch: $0, for: scope) }
   .catch { [unowned self] (error) -> AnyPublisher<[CKRecord], Error> in
     print ("<<< APP CLOUD DATA PUBLISHER >>> CATCHING ERROR WHEN SAVING RECORDS BATCH <\(error)>")
     return self.cloudModifyOperationsPublisher(for: scope)
    }
   .eraseToAnyPublisher()

 }//******************* final func cloudModifyOperationsPublisher *****************************************
 
 
 
 
//*********************************************************************************************************
 final func managedObjectsCloudSaver(batch: [CKRecordConvertable],
                                     for scope: CKDatabase.Scope) -> AnyPublisher<[CKRecord], Error>
//*********************************************************************************************************
 {
 
  //let unique_batch = Set(batch as [NSManagedObject])
  
  let finalBatch = /*(Array(unique_batch) as! [CKRecordConvertable])*/batch.filter
  {object in
   switch (object.changedFieldsInCurrentBatchModifyOperation.isEmpty, object.ck_metadata == nil)
   {
    case (   _,  true ) : return true  // insertions (no metadata yet) always proceed...
    case (true,  false) : return false // empty updates are filtered out...
    case (false, false) : return true  // not empty updates proceed...
   }
    
  }
  
  guard !finalBatch.isEmpty else { return Empty().eraseToAnyPublisher() }
  
  let changedKeysInBatch = finalBatch.map{($0.recordName, $0.changedFieldsInCurrentBatchModifyOperation)}
 
  print ("********************** <<< CHANGED KEYS IN MO IN THIS BATCH >>>> ***********************************")
  finalBatch.enumerated().forEach
  {
   print("[\($0.0)] MO ID: <\($0.1.entity.name ?? "NO ENTITY")>[\($0.1.recordName!)] IN OPERATION: [\($0.1.changedFieldsInCurrentBatchModifyOperation)]")
   
   $0.1.changedFieldsInCurrentBatchModifyOperation.removeAll()
  }
  print ("**************************************************************************************************\n")
  
  return Future<[CKRecord], Error> { [unowned self] promise in
  
   let mop = ModifyBatchCloudOperation(batch: finalBatch, cloudScope: scope, batchCompletionBlock: promise)
  
   mop.changedFieldsMap = Dictionary(uniqueKeysWithValues: changedKeysInBatch)
   mop.name = UUID().uuidString
   
   print ("***************************************************************************************************")
   print ("<<<<< LIST OF DEPENDENCIES FOR BATCH OPERATION ID [\(mop.name ?? "NO ID")] >>>>>")
   print ("***************************************************************************************************")
   self.batchOperationsDependencies(for: mop).forEach
   {
    print("OPERATION ID: [\($0.name ?? "NO ID")]\nDESCRIPTION: [\($0.debugDescription)]")
    mop.addDependency($0)
    
   }
   print ("*************************************************************************************************\n")
   
   //if let prevMop = self.prevBatchOperation { mop.addDependency(prevMop) }
   
   //self.prevBatchOperation = mop
   
   self.batchOperationBuffer.insert(mop)
   
   mop.completionBlock = { [unowned self] in
    print("************************************************************************************************** ")
    print("<<< OPERATION FINISHED (COMPLETION BLOCK) >>> WITH ID: [\(mop.name ?? "NO ID")]")
    print("**************************************************************************************************\n")
    DispatchQueue.main.async { self.batchOperationBuffer.remove(mop) }
   }
   
   self.operationQueue.addOperation(mop)
   
  }
  .eraseToAnyPublisher()
  
 }//func cloudRecordsSaver...
}
//*********************************************************************************************************
