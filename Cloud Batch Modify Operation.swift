//
//  Cloud Modify Operation.swift
//  Newsman
//
//  Created by Anton2016 on 19.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import Combine
import CloudKit


final class ModifyBatchCloudOperation: BatchCloudOperation
{
 
 init(batch: [CKRecordConvertable],
      cloudScope: CKDatabase.Scope,
      batchCompletionBlock: @escaping TBatchHandler)
  
 {
  self.cloudScope = cloudScope
  self.batchCompletionBlock = batchCompletionBlock
  super.init(batch: batch)
 }
 
 
 typealias TBatchHandler = (Result<[CKRecord], Error>) -> Void
 
 let cloudScope: CKDatabase.Scope
 var batchCompletionBlock: TBatchHandler
 
 var changedFieldsMap = [ String? : Set<String> ]()

 private final var cancellables = Set<AnyCancellable>()
 
 private final var cloudDB: CKDatabase { CKContainer.default().database(with: cloudScope) }
 
 private final var recordBatchPublisher: AnyPublisher<[CKRecord], CKError>
 {
  batch
   .filter { $0.managedObjectContext != nil } // ignore if already saved deleted from context
   .filter { !$0.isDeleted } // ignore if marked to be deleted from context after save...
   .publisher
   .setFailureType(to: CKError.self)
   .receive(on: DispatchQueue.main)
   .flatMap{ $0.cloudRecordPublisher }
   .collect()
   .handleEvents(receiveOutput:
    {[unowned self] in
     print("*************************************************************************************** ")
     print("<<< RECORD BATCH PUBLISHER >>> RECORD BATCH IS READY FOR [\(self.name ?? "NO ID")]:    ")
     print("*************************************************************************************** ")
     $0.enumerated().forEach
     {
      print("[\($0.0)] - CK RECORD NAME: <\($0.1.recordType)>(\($0.1.recordID.recordName)), TAG: {\($0.1.recordChangeTag ?? "N/T")}")
     }
     print("***************************************************************************************\n")
     
    })
   .eraseToAnyPublisher()
 }
 
 private var timeoutIntervalForResource: TimeInterval = 1.0
 {
  didSet { timeoutIntervalForResourceCounter += 1 }
 }
 
 private var timeoutIntervalForResourceIncrement: TimeInterval = 1.5
 private var timeoutIntervalForNetworkIncrement: TimeInterval = 5.0
 private var timeoutIntervalForServiceIncrement: TimeInterval = 10.0
 
 private var timeoutIntervalForResourceCounter = 0
 private var timeoutIntervalForResourceMaxTries = 10

 
 private final func modifyRecordsPublisher(for recordBatch: [CKRecord]) -> AnyPublisher<[CKRecord], CKError>
 {
  Future<[CKRecord], CKError>
  {[unowned self] promise in
   let saveOp = CKModifyRecordsOperation(recordsToSave: recordBatch, recordIDsToDelete: nil)
 
   saveOp.isAtomic = true
   saveOp.configuration.timeoutIntervalForResource = self.timeoutIntervalForResource
   
   saveOp.modifyRecordsCompletionBlock = { saved, _ , error in
    
    guard let saveError = error as? CKError else
    {
     promise(.success(saved!))
     return
    }
    
    promise(.failure(saveError))
   }
   
   self.cloudDB.add(saveOp)
    
  }
  .receive(on: DispatchQueue.main)
  .tryCatch { [unowned self] (error) -> AnyPublisher<[CKRecord], CKError> in
   
    guard self.timeoutIntervalForResourceCounter < self.timeoutIntervalForResourceMaxTries else
    {
     print("************************************************************************************** ")
     print ("<<< RETRY OPERATION ATTEMPTS EXCEEDED - \(self.timeoutIntervalForResourceCounter)>>> ")
     print("**************************************************************************************\n")
     throw error
    }
   
    var errorRecordsBatch = recordBatch
   
    print("***************************************************************************************** ")
    print ("<<< ERROR CAUGHT IN MODIFY RECORDS PUBLISHER [\(self.name ?? "NO ID")] >>> \(error)")
    print("*****************************************************************************************\n")
   
    switch error.code
    {
     
     case .networkFailure:     self.timeoutIntervalForResource += self.timeoutIntervalForNetworkIncrement
     case .networkUnavailable: self.timeoutIntervalForResource += self.timeoutIntervalForResourceIncrement
     case .serviceUnavailable: self.timeoutIntervalForResource += self.timeoutIntervalForServiceIncrement
     
     case .partialFailure:
      
      guard let errorsMap = error.userInfo[CKPartialErrorsByItemIDKey] as? [CKRecord.ID: CKError] else
      {
       print("******************************************************************************************* ")
       print ("<<< PARTIAL RECORD ERRORS PROCCESSING FAILED >>> NO FURTHER INFO PROVIDED TO PROCESS ERROR ")
       print("*******************************************************************************************\n")
       self.timeoutIntervalForResourceCounter += 1
       break
      }
      
      switch true
      {
       case errorsMap.values.first{ $0.code == .networkFailure} != nil:
        self.timeoutIntervalForResource += self.timeoutIntervalForNetworkIncrement
       
       case errorsMap.values.first{ $0.code == .networkUnavailable} != nil:
        self.timeoutIntervalForResource += self.timeoutIntervalForResourceIncrement
       
       case errorsMap.values.first{ $0.code == .serviceUnavailable} != nil:
        self.timeoutIntervalForResource += self.timeoutIntervalForServiceIncrement
       
       default:  self.timeoutIntervalForResourceCounter += 1
       
      }
    
   
      errorsMap.forEach{ (recordID, recordError) -> () in
       guard let recordIndex = (errorRecordsBatch.firstIndex{ $0.recordID == recordID }) else { return }
       guard
        let object = (self.batch.first{ $0.recordName == recordID.recordName }),
        object.managedObjectContext != nil,
        object.isDeleted == false
       else
       {
        errorRecordsBatch.remove(at: recordIndex) //remove deleted record from error batch...
        return
       }
       
       switch recordError.code
       {
        case .assetFileNotFound:
         object.ck_assets.forEach { (assetName, assetURL) -> () in
          guard let assetURL = assetURL else
          {
           print ("<<< ASSET FILE NOT FOUND >>> MO ASSET NAMED \(assetName) IS NIL AND NOT UPDATED!")
           return
          }
          errorRecordsBatch[recordIndex][assetName] = CKAsset(fileURL: assetURL)
         }
        
        case .serverRecordChanged:
         
         guard let sr = recordError.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else { return }
         guard let cr = recordError.userInfo[CKRecordChangedErrorClientRecordKey] as? CKRecord else { return }
         self.changedFieldsMap[cr.recordID.recordName]?.forEach { sr[$0] = cr[$0] }
         errorRecordsBatch[recordIndex] = sr
        
        
        default: break
       
         
       }//switch recordError.code...
      }//errorsMap.forEach....
      
      
      
//      errorsMap.filter{ $0.value.code == .assetFileNotFound }.forEach
//      {(recordID, error)  in
//       //print (recordID.recordName,"\n",error.userInfo[NSFilePathErrorKey] as Any)
//       guard let recordIndex = (errorRecordsBatch.firstIndex{ $0.recordID == recordID }) else { return }
//       guard let object = (self.batch.first{ $0.recordName == recordID.recordName }),
//        object.managedObjectContext != nil, !object.isDeleted
//       else
//       {
//        errorRecordsBatch.remove(at: recordIndex)
//        return
//       }
//
//       object.ck_assets.forEach {assetName, assetURL in
//        errorRecordsBatch[recordIndex][assetName] = CKAsset(fileURL: assetURL)
//       }
//
//      }
//
//
//      errorsMap.values.filter{ $0.code == .serverRecordChanged }.forEach
//      {error in
//
//       guard let sr = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else { return }
//       guard let cr = error.userInfo[CKRecordChangedErrorClientRecordKey] as? CKRecord else { return }
//
//       self.changedFieldsMap[cr.recordID.recordName]?.forEach { sr[$0] = cr[$0] }
//
//       guard let recordIndex = (errorRecordsBatch.firstIndex{ $0.recordID == cr.recordID }) else { return }
//
//       errorRecordsBatch[recordIndex] = sr
//
//
//      }//{error in...}
//
//      if (errorsMap.values.first{ $0.code == .networkFailure  }) != nil
//      {
//       self.timeoutIntervalForResource += self.timeoutIntervalForResourceIncrement
//      }
     default: break
    }
   
   print("************************************************************************************************ ")
   print ("<<< RETRY SAVE RECORDS PUBLISHER IN OPERATION [\(self.name ?? "NO ID")] - (\(self.timeoutIntervalForResourceCounter)) >>> ")
   print("************************************************************************************************ ")
   
   
   return self.modifyRecordsPublisher(for: errorRecordsBatch)
  }
  .mapError{ $0 as! CKError}
  .eraseToAnyPublisher()
  
 }//func cloudRecordsSaver...
 
 
 
 private final func updateMetadataPublisher(for modifiedRecords: [CKRecord] ) -> AnyPublisher<[CKRecord], Error>
 {
  let recordObjectTuples = modifiedRecords.map
  {record in
   (record: record, object: batch.first{ $0.recordName == record.recordID.recordName })
  }
  
  return Dictionary(grouping: recordObjectTuples){ $0.object?.managedObjectContext }
   .filter{ $0.key != nil }
   .publisher
   .setFailureType(to: Error.self)
   .flatMap {(moc, recordObjectTuples) -> AnyPublisher<Void, Error> in
    
     return moc!.performChangesPublisher
     {
      recordObjectTuples.forEach {record, managedObject in
       let coder = NSKeyedArchiver(requiringSecureCoding: true)
       record.encodeSystemFields(with: coder)
       managedObject?.ck_metadata = coder.encodedData as NSData //ENCODE AND UPDATE NEW RECORD META DATA!!!
       managedObject?.isClouded = true
      }
     }
     .handleEvents(receiveCompletion:
      { _ in
       print("***************************************************************************************************")
       print("<<< MO CONTEXT METADATA PUBLISHER FOR OPERATION [\(self.name ?? "NO ID")] >>> ")
       print("***************************************************************************************************")
       print("METADATA HAS BEEN UPDATED IN MOC: <\(moc.debugDescription)>\nFOR THE FOLLOWING MO:")
       recordObjectTuples.enumerated().forEach
       {
        print ("[\($0.0)] <\($0.1.0.recordType)>[\($0.1.0.recordID.recordName)] => NEW TAG {\($0.1.0.recordChangeTag ?? "N/T")}")
       }
       print("*************************************************************************************************\n")
     }).eraseToAnyPublisher()
    }//.flatMap ...
    .collect()
    .map { _ in modifiedRecords}
    .eraseToAnyPublisher()
   
 }
 
 
 override final func main()
 {
  print("**************************************************************************************** ")
  print("<<< SAVE OPERATION STARTING (MAIN) >>> WITH ID: [\(name ?? "NO ID")]:")
  print("****************************************************************************************\n")
  
  recordBatchPublisher
   .flatMap { [unowned self] in self.modifyRecordsPublisher(for: $0)}
   .mapError { $0 as Error }
   .flatMap { [unowned self] in self.updateMetadataPublisher(for: $0)}
   .receive(on: DispatchQueue.main)
   .sink(receiveCompletion: { [unowned self] result in
     defer { self.state = .finished }
     switch result
     {
      case .failure(let error):
       self.batchCompletionBlock(.failure(error))
       print("************************************************************************************************* ")
       print("<<<OPERATION ERROR (MAIN)>>> MODIFY OPRERATION ERROR OCCURED [\(self.name ?? "NO ID")] [\(error)]")
       print("************************************************************************************************\n")
      default: break
     }
    }, receiveValue:
    {[unowned self] in
     self.batchCompletionBlock(.success($0))
     print("*********************************************************************************************** ")
     print("<<< SAVE OPERATION FINISHED (MAIN) >>> WITH ID: [\(self.name ?? "NO ID")] SUCCESSFULLY:")
     print("************************************************************************************************ ")
     $0.enumerated().forEach
     {
      print("[\($0.0)] - CK RECORD NAME: <\($0.1.recordType)>(\($0.1.recordID.recordName)), TAG: {\($0.1.recordChangeTag ?? "N/T")}")
     }
     print("***********************************************************************************************\n")
    })
   .store(in: &cancellables)
 
 }
 
}



