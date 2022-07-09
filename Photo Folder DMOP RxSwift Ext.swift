//
//  Photo Folder DMOP RxSwift Ext.swift
//  Newsman
//
//  Created by Anton2016 on 28.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

import class  RxSwift.Observable
import struct RxSwift.Completable
import class  RxSwift.MainScheduler



extension DeletableManagedObjectProtocol where Self: PhotoFolder
{
 var deleteCompletable: Completable
 {
  Observable.combineLatest(MOC$, URL$).flatMap { moc, folderURL -> Completable in
   
   let contextDeleter: Completable = moc.performCnangesCompletable
   {
    if ( !self.isSingleElementFolder ) { self.shiftRowPositionsBeforeDelete() }
    self.photoSnippet?.removeFromFolders(self)
    moc.delete(self)
   }
   
   let diskDeleter: Completable = FileManager.removeItemFromDisk(at: folderURL)
   
    return .zip(contextDeleter, diskDeleter, self.undoer.removeAllOperations(for: [self] + self.folderedPhotos))
   }.asCompletable()
   
  }
//   .subscribeOn(MainScheduler.instance)
//   .observeOn(MainScheduler.instance)
  
 
}//extension DeletableManagedObjectProtocol where Self: Photo...

