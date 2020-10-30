//
//  Batch Cloud Operation.swift
//  Newsman
//
//  Created by Anton2016 on 03.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import CoreData

/* Base asyncronous wrapper for CKRecords batch modify operation */

class BatchCloudOperation: Operation
{
 let batch: [CKRecordConvertable] // the unique batch of modified or deleted managed objects.
 
 init(batch: [CKRecordConvertable])
 {
  self.batch = batch
  super.init()
 }
 
 override final func start() // overridden sync operation start used by both subclasses
 {
  main()
  state = .executing
 }
 
 enum State: String
 {
  case ready, executing, finished
  var keyPath: String {  "is\(rawValue.capitalized)" }
 }
 
 final var state = State.ready
 {
  willSet
  {
    willChangeValue(forKey: newValue.keyPath)
    willChangeValue(forKey: state.keyPath)
  }
  didSet
  {
    didChangeValue(forKey: oldValue.keyPath)
    didChangeValue(forKey: state.keyPath)
  }
 }
 
 override final var isReady:        Bool { super.isReady && state == .ready }
 override final var isExecuting:    Bool { state == .executing }
 override final var isFinished:     Bool { state == .finished }
 override final var isAsynchronous: Bool { true }
 
 private final var batchSet: Set<NSManagedObject> { Set(batch as [NSManagedObject]) }
 
 final func hasInsertionRelationships(with otherBatchOperation: BatchCloudOperation) -> Bool
 {
  let related = batch.flatMap { object -> [NSManagedObject] in
   let keys = object.cloudedRelationshipsKeys
   let related = keys.compactMap{ object.value(forKey: $0) as? CKRecordConvertable }
   return related.filter{ $0.ck_metadata == nil }
  }
  return !(Set(related).isDisjoint(with: otherBatchOperation.batchSet))
 }
 
 final func hasDeletionRelationships(with otherBatchOperation: BatchCloudOperation) -> Bool
 {
  guard otherBatchOperation is DeleteBatchCloudOperation else { return false }
  let removedChildren = Set(otherBatchOperation.batch.flatMap{$0.removedChildenRecords})
  return !(batchSet.isDisjoint(with: removedChildren))
 }
 
 
 final func isJoint(with otherBatchOperation: BatchCloudOperation) -> Bool
 {
  (!batchSet.isDisjoint(with: otherBatchOperation.batchSet)) ||
   hasInsertionRelationships(with: otherBatchOperation)      ||
   hasDeletionRelationships(with: otherBatchOperation)
 }
 
}
