

import Foundation

import class  RxSwift.Observable
import struct RxSwift.Completable
import class  RxSwift.MainScheduler



extension DeletableManagedObjectProtocol where Self: PhotoSnippet
{
 var deleteCompletable: Completable
 {
  Observable.combineLatest(MOC$, URL$).flatMap { moc, snippetURL -> Completable in
   
   let contextDeleter: Completable = moc.performCnangesCompletable { moc.delete(self)}
   let diskDeleter: Completable = FileManager.removeItemFromDisk(at: snippetURL)
   return .zip(contextDeleter, diskDeleter)
  }.asCompletable()
   
  }
//   .subscribeOn(MainScheduler.instance)
//   .observeOn(MainScheduler.instance)
  
 
}//extension DeletableManagedObjectProtocol where Self: Photo...
