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
 
 @objc optional func updatePhotoItemsFlag(with hostedManagedObjects: [NSManagedObject])
 
 //PHOTO ITEMS DRAG & DROP NOTIFICATIONS...
 @objc optional func moveItem(after notification: Notification)
 @objc optional func moveToFolder(after notification: Notification)
 @objc optional func moveFromFolder(after notification: Notification)
 @objc optional func moveBetweenFolders(after notification: Notification)
 @objc optional func moveInsideFolder(after notification: Notification)
 @objc optional func mergeIntoFolder(after notification: Notification)
 @objc optional func unfolderSingleItem(after notification: Notification)
 @objc optional func unfolderEntireFolder(after notification: Notification)
 
 //ENTIRE PHOTO SNIPPET DRAG & DROP NOTIFICATIONS...
 @objc optional func folderPhotoSnippet(after notification: Notification)
 @objc optional func mergePhotoSnippet(after notification: Notification)
 @objc optional func movePhotoSnippet(after notification: Notification)
 
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
   let photoSnippets = changed.compactMap{$0 as? PhotoSnippet}
   handler(photos + folders + photoSnippets)
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
   hostedManagedObjects.forEach { self.deletePhotoItem(with: $0) }
  }
  
  contextChangeObservers.insert(observer)
 }
 
 private func addPhotoItemUpdateObserver()
 {
  let observer = configueChangeContextObserver(for: NSUpdatedObjectsKey)
  { [unowned self] hostedManagedObjects in
   
   // process all types of changes exept for colored flag marker ones...
   hostedManagedObjects.forEach  { self.updatePhotoItem(with: $0) }
   
   // process colored flag marker change separately as it needs to move sections...
   let flagged = hostedManagedObjects.filter
   {
    $0.changedValuesForCurrentEvent().keys.contains(#keyPath(Photo.priorityFlag))
   }
   
   if !flagged.isEmpty { self.updatePhotoItemsFlag?(with: flagged) }
   
  }
  
  contextChangeObservers.insert(observer)
 }
 
 private func addFunctionalObserver(for name: Notification.Name, using handler: ( (Notification) -> () )?)
 {
  guard handler != nil else { return }
  let center = NotificationCenter.default
  let queue = OperationQueue.main
  let observer = center.addObserver(forName: name, object: nil, queue: queue, using: handler!)
  contextChangeObservers.insert(observer as! NSObject)
 }
 

 func addContextObservers()
 {
  addPhotoItemInsertObserver()
  addPhotoItemDeleteObserver()
  addPhotoItemUpdateObserver()
  
  addFunctionalObserver(for: .photoItemDidFolder)
  {[unowned self] in
   self.moveToFolder?(after: $0)
  }
  // 1 - FOLDER...
  
  addFunctionalObserver(for: .photoItemDidRefolder)
  {[unowned self] in
   self.moveBetweenFolders?(after: $0)
  }
  // 2 - REFOLDER...
  
  addFunctionalObserver(for: .photoItemDidUnfolder)
  {[unowned self] in
   self.moveFromFolder?(after: $0)
  }
  // 3 - UNFOLDER ...

  addFunctionalObserver(for: .singleItemDidUnfolder)
  {[unowned self] in
   self.unfolderSingleItem?(after: $0)
  }
  // 4 - SINGLE...
  
  addFunctionalObserver(for: .photoItemDidMove)
  {[unowned self] in
   self.moveItem?(after: $0)
  }
  // 5 - MOVE...
  
  addFunctionalObserver(for: .photoItemDidMerge)
  {[unowned self] in
   self.mergeIntoFolder?(after: $0)
  }
  // 6 - MERGE...
  
  addFunctionalObserver(for: .folderedPhotoDidMove)
  {[unowned self] in
   self.moveInsideFolder?(after: $0)
  }
  // 7 - MOVE PHOTOS INSIDE FOLDER...
  
  addFunctionalObserver(for: .folderItemDidUnfolder)
  {[unowned self] in
   self.unfolderEntireFolder?(after: $0)
  }
  // 8 - UNFOLDER ENTIRE FOLDER WHEN MOVED INTO SINGLE PHOTOS SECTION...
  
  addFunctionalObserver(for: .snippetItemDidFolder)
  {[unowned self] in
   self.folderPhotoSnippet?(after: $0)
  }
  // 9 - FOLDER ENTIRE SNIPPET INTO OTHER/THE SAME SNIPPET FOLDER...
  
  addFunctionalObserver(for: .snippetItemDidMerge)
  {[unowned self] in
   self.mergePhotoSnippet?(after: $0)
  }
  // 10 - MERGE ENTIRE SNIPPET WITH OTHER/THE SAME SNIPPET SINGLE PHOTO ITEM...
  
  
  addFunctionalObserver(for: .snippetItemDidMove)
  {[unowned self] in
   self.movePhotoSnippet?(after: $0)
  }
  // 11 - MOVE ENTIRE SNIPPET INTO OTHER SNIPPET...
  
 }
 
 
 func removeContextObservers()
 {
  
  let center = NotificationCenter.default
  contextChangeObservers.forEach { center.removeObserver($0) }
  contextChangeObservers.removeAll()
 }
 
}
