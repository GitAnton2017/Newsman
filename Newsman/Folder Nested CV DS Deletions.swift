//
//  Folder Nested CV DS Deletions.swift
//  Newsman
//
//  Created by Anton2016 on 24/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoFolderCell
{
 
 var deletedFolders: [PhotoFolder]
 {
  return moc.deletedObjects.compactMap{ $0 as? PhotoFolder }
 }
 
 var deletedFoldersPhotos: [Photo]
 {
  return deletedFolders.flatMap{$0.folderedPhotos}
 }
 
 func deletePhotoItem(with hostedManagedObject: NSManagedObject)
 {
 
  photoCollectionView.performBatchUpdates({
   guard let photo = hostedManagedObject as? Photo else { return }
   if deletedFoldersPhotos.contains(photo) { return }
   guard let indexPath = photoItemIndexPath(with: photo) else { return }
   photoItems.remove(at: indexPath.row)
   photoCollectionView.deleteItems(at: [indexPath])
  })
  
 
  
 }//func deletePhotoItem(with hostedManagedObject: NSManagedObject)...
 
}//extension PhotoFolderCell...


