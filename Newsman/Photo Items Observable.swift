//
//  Photo Items Observable.swift
//  Newsman
//
//  Created by Anton2016 on 27/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

@objc protocol PhotoManagedObjectsContextChangeObservable
{
 
 var moc: NSManagedObjectContext            { get     }
 var contextChangeObservers: Set<NSObject>  { get set }
 
 func updatePhotoItem(with hostedManagedObject: NSManagedObject)
 func insertPhotoItem(with hostedManagedObject: NSManagedObject)
 func deletePhotoItem(with hostedManagedObject: NSManagedObject)

 
 @objc optional func moveItem(after notification: Notification)
 @objc optional func moveToFolder(after notification: Notification)
 @objc optional func moveFromFolder(after notification: Notification)
 @objc optional func moveBetweenFolders(after notification: Notification)
 @objc optional func mergeIntoFolder(after notification: Notification)
 
}


extension PhotoManagedObjectsContextChangeObservable
{
 private func configueChangeContextObserver(for changeKey: String,
                                            handler: @escaping ( [NSManagedObject] ) -> () ) -> NSObject
 {
  let center = NotificationCenter.default
  let queue = OperationQueue.main
  
  let observer = center.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: moc, queue: queue)
  { notification in
   guard let userInfo = notification.userInfo else { return }
   guard let changed = userInfo[changeKey] as? Set<NSManagedObject> else { return }
   let photos = changed.compactMap{$0 as? Photo}
   let folders = changed.compactMap{$0 as? PhotoFolder}
   handler(photos + folders)
  }
  
  return observer as! NSObject
 }
 
 
 private func addPhotoItemInsertObserver()
 {
  let observer = configueChangeContextObserver(for: NSInsertedObjectsKey)
  { [unowned self] hostedManagedObjects in
   hostedManagedObjects.forEach  { self.insertPhotoItem(with: $0) }
  }
  
  contextChangeObservers.insert(observer)
 }
 
 private func addPhotoItemDeleteObserver()
 {
  let observer = configueChangeContextObserver(for: NSDeletedObjectsKey)
  { [unowned self] hostedManagedObjects in
   hostedManagedObjects.forEach
   {
    self.deletePhotoItem(with: $0)
    
   }
  }
  
  contextChangeObservers.insert(observer)
 }
 
 private func addPhotoItemUpdateObserver()
 {
  let observer = configueChangeContextObserver(for: NSUpdatedObjectsKey)
  { [unowned self] hostedManagedObjects in
   hostedManagedObjects.forEach  { self.updatePhotoItem(with: $0) }
  }
  
  contextChangeObservers.insert(observer)
 }
 
 private func addPhotoDidMoveObserver()
 {
  let center = NotificationCenter.default
  let queue = OperationQueue.main
  
  let observer = center.addObserver(forName: .photoItemDidMove, object: nil, queue: queue)
  { [unowned self] notification in
   self.moveItem?(after: notification)
  }
  
  contextChangeObservers.insert(observer as! NSObject)
 }
 
 private func addPhotoDidUnfolderObserver()
 {
  
 }
 
 private func addFolderDidMoveObserver()
 {
  
 }
 
 func addContextObservers()
 {
  addPhotoItemInsertObserver()
  addPhotoItemDeleteObserver()
  addPhotoItemUpdateObserver()
  addPhotoDidMoveObserver()
  addFolderDidMoveObserver()
 }
 
 
 func removeContextObservers()
 {
  let center = NotificationCenter.default
  contextChangeObservers.forEach { center.removeObserver($0) }
  contextChangeObservers.removeAll()
 }
 
 var observableKeys: [String]
 {
  return [#keyPath(Photo.isSelected),
          #keyPath(PhotoFolder.isSelected),
          #keyPath(Photo.isDragAnimating),
          #keyPath(PhotoFolder.isDragAnimating) ]
 }
 
}
