//
//  Photo Snippet Items Delete.swift
//  Newsman
//
//  Created by Anton2016 on 06/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData


extension PhotoSnippetCollectionView
{
 func deletePhoto (at indexPath: IndexPath)
 {
  let ds = dataSource as! PhotoSnippetViewController
  ds.photoItems2D[indexPath.section][indexPath.row].deleteFromContext()
 }
}

extension PhotoItem
{
 func deleteFromContext()
 {
  removeFromDrags()
  photoSnippet.remove(photo: photo)
 }
}

extension PhotoFolderItem
{
 func deleteFromContext()
 {
  removeFromDrags()
  photoSnippet.remove(folder: folder)
 }
}


extension PhotoSnippet
{
 
 final func remove(photo: Photo)
 {
  let deletedURL = photo.url
  let deletedID = photo.ID
  
  managedObjectContext?.persist(block: { self.managedObjectContext?.delete(photo) })
  {persisted in
   guard persisted else { return }
   DispatchQueue.global(qos: .utility).async
   {
    PhotoItem.deletePhotoItemFromDisk(at: deletedURL)
    PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: deletedID as NSString) }
   }
  }
 }
 
 final func remove(folder: PhotoFolder)
 {
  let deletedURL = folder.url
  let deletedID = folder.ID
  
  managedObjectContext?.persist(block: { self.managedObjectContext?.delete(folder) })
  {persisted in
   guard persisted else { return }
   DispatchQueue.global(qos: .utility).async
   {
    PhotoItem.deletePhotoItemFromDisk(at: deletedURL)
    PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: deletedID as NSString) }
   }
  }
 }
 
 final func removeSelectedFromDrags(with selectedObjects: [NSManagedObject])
 {
  AppDelegate.globalDragItems.removeAll
  {dragged in
   selectedObjects.contains{ dragged.hostedManagedObject === $0 }
  }
  
  AppDelegate.globalDropItems.removeAll
  {dropped in
   selectedObjects.contains{ dropped.hostedManagedObject === $0 }
  }
 }
 
 final func removeSelectedItems()
 {
 
  removeSelectedFromDrags(with: unfolderedSelected + selectedFolders)
  
  let deletedURLs = unfolderedSelected.map{ $0.url } + selectedFolders.map{ $0.url }
  let deletedIDs = selectedPhotos.map{ $0.ID }
  
  managedObjectContext?.persist(block:
  {
   self.unfolderedSelected.forEach { self.managedObjectContext?.delete($0) }
   self.selectedFolders.forEach    { self.managedObjectContext?.delete($0) }
  })
  {persisted in
   guard persisted else { return }
   DispatchQueue.global(qos: .utility).async
   {
    deletedURLs.forEach { PhotoItem.deletePhotoItemFromDisk(at: $0) }
    deletedIDs.forEach
    {photoID in
     PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: photoID as NSString) }
    }
   }
  }
 }
 
}


