//
//  Cloud Batch Delete Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import Combine
import CloudKit


final class DeleteBatchCloudOperation: BatchCloudOperation
{
 
 init(batchToDelete: [CKRecordConvertable],
      cloudScope: CKDatabase.Scope,
      batchDeleteCompletionBlock: @escaping TBatchDeleteHandler)
  
 {
  self.cloudScope = cloudScope
  self.batchDeleteCompletionBlock = batchDeleteCompletionBlock
  super.init(batch: batchToDelete)
 }
 
 
 typealias TBatchDeleteHandler = (Result<[CKRecord.ID], Error>) -> Void
 
 let cloudScope: CKDatabase.Scope
 var batchDeleteCompletionBlock: TBatchDeleteHandler

 private final var cancellables = Set<AnyCancellable>()
 
 private final var cloudDB: CKDatabase { CKContainer.default().database(with: cloudScope) }
 
 private final var recordIDsPublisher: AnyPublisher<[CKRecord.ID], CKError>
 {
  batch.publisher
   .filter{ $0.ck_metadata != nil } //ignore MOs that were not persisted in CloudDB before...
   .setFailureType(to: CKError.self)
   .receive(on: DispatchQueue.main)
   .flatMap{ $0.cloudRecordIDPublisher }
   .collect()
   .handleEvents(receiveOutput:
    {[unowned self] in
     print("*********************************************************************************************** ")
     print("<<< RECORD IDs BATCH PUBLISHER >>> BATCH IS READY TO DELETE FOR [\(self.name ?? "NO ID")]")
     print("*********************************************************************************************** ")
     $0.enumerated().forEach
     {
      print("[\($0.0)] - CK RECORD TO BE DELETED WITH ID: [(\($0.1.recordName))]")
     }
     print("***********************************************************************************************\n")
    })
   .eraseToAnyPublisher()
 }
 
 private var timeoutIntervalForResource: TimeInterval = 1.0
 {
  didSet { timeoutIntervalForResourceCounter += 1 }
 }
 
 private var timeoutIntervalForResourceIncrement: TimeInterval = 1.0
 private var timeoutIntervalForResourceCounter = 0
 private var timeoutIntervalForResourceMaxTries = 10
 
 final func deleteRecordsPublisher(for recordBatch: [CKRecord.ID]) -> AnyPublisher<[CKRecord.ID], CKError>
 {
  Future<[CKRecord.ID], CKError>
  {[unowned self] promise in
    let deleteOp = CKModifyRecordsOperation(recordsToSave: nil , recordIDsToDelete: recordBatch)
    deleteOp.configuration.timeoutIntervalForResource = self.timeoutIntervalForResource
    deleteOp.isAtomic = true
   
    deleteOp.modifyRecordsCompletionBlock = { _, deleted, error in
     guard let deleteError = error as? CKError else
     {
      promise(.success(deleted!))
      return
     }
     
     promise(.failure(deleteError))
   }
   
   self.cloudDB.add(deleteOp)
    
  }.tryCatch { [unowned self] (error) -> AnyPublisher<[CKRecord.ID], CKError> in
    print("****************************************************************************************** ")
    print ("<<< ERROR CAUGHT IN DELETE RECORDS PUBLISHER >>> \(error)\n")
    print("******************************************************************************************\n")
    switch error.code
    {
     case .partialFailure:
      
      guard self.timeoutIntervalForResourceCounter < self.timeoutIntervalForResourceMaxTries else
      {
       print("****************************************************************************************** ")
       print ("<<< RETRY DELETE RECORDS ATTEMPTS EXCEEDED - \(self.timeoutIntervalForResourceCounter)>>> ")
       print("******************************************************************************************\n")
       throw error
      }
      
      guard let errorsMap = error.userInfo[CKPartialErrorsByItemIDKey] as? [CKRecord.ID: CKError] else { break }
       
      if (errorsMap.values.first{ $0.code == .networkFailure  }) != nil
      {
       self.timeoutIntervalForResource += self.timeoutIntervalForResourceIncrement
      }
     
     default: break
    }
   
   print("************************************************************************************************ ")
   print("<<< RETRY DELETE RECORDS PUBLISHER OPERATION - (\(self.timeoutIntervalForResourceCounter)) >>>   ")
   print("************************************************************************************************\n")
   
   return self.deleteRecordsPublisher(for: recordBatch)
  }
  .mapError{ $0 as! CKError}
  .eraseToAnyPublisher()
 }//func cloudRecordsSaver...
 
 
 override final func main()
 {
  print("************************************************************************************ ")
  print(" <<< DELETE BATCH OPERATION STARTING (MAIN) >>> WITH ID: [\(name ?? "NO ID")]")
  print("************************************************************************************ ")
  
  recordIDsPublisher
   .flatMap { [unowned self] in self.deleteRecordsPublisher(for: $0) }
   .receive(on: DispatchQueue.main)
   .sink(receiveCompletion:
   { [unowned self] result in
     defer { self.state = .finished }
     switch result
     {
      case .failure(let error):
       self.batchDeleteCompletionBlock(.failure(error))
       print("*************************************************************************************************")
       print("<<< DELETE OPERATION ERROR (MAIN) >>> ERROR OCCURED: [\(error)] IN [\(self.name ?? "NO ID")]")
       print("************************************************************************************************\n")
      default: break
     }
    }, receiveValue:
    {[unowned self] in
     self.batchDeleteCompletionBlock(.success($0))
     print("************************************************************************************************")
     print("<<< DELETE OPERATION FINISHED (MAIN) >>> [\(self.name ?? "NO ID")] FINISHED SUCCESSFULLY:")
     print("************************************************************************************************ ")
     $0.enumerated().forEach
     {
      print("[\($0.0)] - CK RECORD WITH ID: (\($0.1.recordName)) IS DELETED")
     }
     print("************************************************************************************************ \n")
    })
   .store(in: &cancellables)
 
 }
 
}
