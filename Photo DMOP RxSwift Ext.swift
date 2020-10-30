//
//  RxSwift.swift
//  Newsman
//
//  Created by Anton2016 on 28.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import class Foundation.NSString
import class Foundation.FileManager

import class  RxSwift.Observable
import struct RxSwift.Completable
import class  RxSwift.MainScheduler

extension DeletableManagedObjectProtocol where Self: Photo
{
 var deleteCompletable: Completable
 {
  Observable.combineLatest(MOC$, URL$).flatMap { moc, photoURL -> Completable in
   
   let contextDeleter: Completable = moc.performCnangesCompletable
   {
    self.shiftRowPositionsBeforeDelete()
    self.folder?.removeFromPhotos(self)
    self.photoSnippet?.removeFromPhotos(self)
    
    moc.delete(self)
   }
   
   let diskDeleter: Completable = FileManager.removeItemFromDisk(at: photoURL)
   
   let singleProcess = self.FOLDER$.filter{ $0?.count ?? 0 == 1 }.flatMap { $0!.processSinglePhoto() }
   
   return Completable.zip(contextDeleter, diskDeleter, self.undoer.removeAllOperations(for: self))
                     .andThen(singleProcess)
                     .asCompletable()
   
  }.asCompletable()
  
//   .subscribeOn(MainScheduler.instance)
//   .observeOn(MainScheduler.instance)
  
 }
}//extension DeletableManagedObjectProtocol where Self: Photo...
