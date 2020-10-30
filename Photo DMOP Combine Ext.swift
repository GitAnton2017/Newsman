//
//  Combine.swift
//  Newsman
//
//  Created by Anton2016 on 28.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import class Foundation.NSString
import Foundation


import Combine

extension DeletableManagedObjectProtocol where Self: Photo
{
 var deletePublisher: AnyPublisher<Void, ManagedObjectError>
 {
  Publishers.CombineLatest(MOC$$, URL$$).print("Combine MOC & URL").flatMap
  {[unowned self] moc, URL -> AnyPublisher<Void, ManagedObjectError> in
   
   let contextDeleter = Deferred {
    moc.persist {[unowned self] in
     self.shiftRowPositionsBeforeDelete()
     moc.delete(self)
    }.mapError{ ManagedObjectError.contextSaveFailure(description: $0.localizedDescription)}
    .print("Context Deleter")
   }.eraseToAnyPublisher()
   
   let diskDeleter = Deferred {
    FileManager.removeItemFromDisk(at: URL)
    .mapError{ ManagedObjectError.deleteFailure(at: URL, description: $0.localizedDescription)}
    .print("Disk Deleter")
   }.eraseToAnyPublisher()
   
   let singleProcess = self.FOLDER$$.flatMap
   {folder -> AnyPublisher<Void, ManagedObjectError> in
    guard let folder = folder, folder.count == 1 else { return Empty().eraseToAnyPublisher() }
    return folder.processSinglePhoto()
   }.print("Process Single")
    
   
   return Publishers.Merge(contextDeleter, diskDeleter)
                    .append(singleProcess)
                    .print("Merge + append")
                    .eraseToAnyPublisher()
   
  }
  .subscribe(on: DispatchQueue.main)
  .receive(on: DispatchQueue.main)
  .eraseToAnyPublisher()

  
 }
}
