//
//  App Cloud Data Deleter.swift
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
//************************************************************************************************************
 final var deletedObjectsPublisher: AnyPublisher<CKRecordConvertable, Never>
//************************************************************************************************************
 {
  contextChangePublisher
   .compactMap{ ($0[NSDeletedObjectsKey] as? NSSet)?.allObjects as? [NSManagedObject] }
   .flatMap{ $0.publisher }
   .unique
   .map { $0 as! CKRecordConvertable }
   .handleEvents(receiveOutput:
    {object in
     print("********************************************************************************************************")
     print("<<<DELETED MO PUBLISHER>>> MO <\(object.entity.name ?? "NO ENTITY")>[\(object.recordName!)]")
     print("********************************************************************************************************")
    })
   .eraseToAnyPublisher()
 }//var deletedObjectsPublisher: AnyPublisher<CKRecordConvertable, Never>....
 
 
 final var maxContextDeletesInterval: DispatchQueue.SchedulerTimeType.Stride { .seconds(10) }
 final var maxContextDeletesBatchSize: Int { 20 }
 
//************************************************************************************************************
 final func cloudDeleteOperationsPublisher(for scope: CKDatabase.Scope) -> AnyPublisher<[CKRecord.ID], Error>
//************************************************************************************************************
 {
  deletedObjectsPublisher
   .setFailureType(to: Error.self)
   .collect(.byTimeOrCount(DispatchQueue.main, maxContextDeletesInterval, maxContextDeletesBatchSize))
   .flatMap { [unowned self] in self.managedObjectsCloudDeleter(batch: $0, for: scope) }
   .catch { [unowned self] (error) -> AnyPublisher<[CKRecord.ID], Error> in
     print ("<<< APP CLOUD DATA PUBLISHER >>> CATCHING ERROR WHEN DELETING RECORDS BATCH <\(error)>")
     return self.cloudDeleteOperationsPublisher(for: scope)
    }
   .eraseToAnyPublisher()

 }//********************** final func cloudModifyOperationsPublisher *****************************************
 
 
 
//*********************************************************************************************************
 final func managedObjectsCloudDeleter(batch: [CKRecordConvertable],
                                       for scope: CKDatabase.Scope) -> AnyPublisher<[CKRecord.ID], Error>
//*********************************************************************************************************
 {

  Future<[CKRecord.ID], Error> { [unowned self] promise in
  
   let dop = DeleteBatchCloudOperation(batchToDelete: batch, cloudScope: scope, batchDeleteCompletionBlock: promise)
  
   dop.name = UUID().uuidString
   
   print ("***************************************************************************************************")
   print ("<<< LIST OF DEPENDENCIES FOR DELETE OPERATION ID [\(dop.name ?? "NO ID")] >>>")
   print ("***************************************************************************************************")
   self.batchOperationsDependencies(for: dop).forEach
   {
    print("OPERATION ID: [\($0.name ?? "NO ID")]\nDESCRIPTION: [\($0.debugDescription)]")
    dop.addDependency($0)
    
   }
   print ("*************************************************************************************************\n")
  
   
   self.batchOperationBuffer.insert(dop)
   
   dop.completionBlock = { [unowned self] in
    print("************************************************************************************************** ")
    print("<<< DELETE OPERATION FINISHED (COMPLETION BLOCK) >>> WITH ID: [\(dop.name ?? "NO ID")]")
    print("**************************************************************************************************\n")
    DispatchQueue.main.async { self.batchOperationBuffer.remove(dop) }
   }
   
   self.operationQueue.addOperation(dop)
   
  }
  .eraseToAnyPublisher()
  
 }//func cloudRecordsSaver...
}//*****************************  final func managedObjectsCloudDeleter **************************************
