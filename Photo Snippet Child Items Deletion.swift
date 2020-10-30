

import UIKit
import CoreData
import Combine
import RxSwift

extension PhotoSnippetCollectionView
{
 func deletePhoto(at indexPath: IndexPath)
 {
  let ds = dataSource as! PhotoSnippetViewController
  ds.photoItems2D[indexPath.section][indexPath.row].deleteFromContext()
 }
}


extension PhotoSnippet
{
 
 final func removeSelectedFromDrags(with selectedObjects: [NSManagedObject])
 {
  AppDelegate.globalDragItems.removeAll
  {dragged in
   selectedObjects.contains{ dragged.hostedManagedObject.objectID == $0.objectID }
  }
  
  AppDelegate.globalDropItems.removeAll
  {dropped in
   selectedObjects.contains{ dropped.hostedManagedObject.objectID == $0.objectID }
  }
 }
 
 
 
 final func removeSinglePhotoFolders()
 {
  let folders = singlePhotoFolders
  
  folders.forEach { undoer.removeAllOperations(for: $0) }
  
  let singlePhotos = folders.flatMap{ $0.folderedPhotos }
  let deletedURLs = folders.compactMap { $0.url }
  let fromURLs = singlePhotos.map { $0.url }

  managedObjectContext?.performChanges(block:
  {
   singlePhotos.forEach
   {photo in
    guard let folder = photo.folder else { return } //1 - photo must be foldered before repositioning!
    photo.setSinglePhotoRowPositions()              //2 - while in folder set up all unfoldered position...
    folder.removeFromPhotos(photo)                  //3 - remove it from folder
    folder.photoSnippet?.removeFromFolders(folder)
    self.managedObjectContext?.delete(folder)       //4 - delete finally empty folder from MOC!
   }
  })
  {result  in
   guard case .success() = result else { return }
   DispatchQueue.global(qos: .utility).async
   {
    zip(fromURLs, singlePhotos.sorted{$0.rowPosition < $1.rowPosition}).forEach
    {fromURL, singlePhoto in
     guard let fromURL = fromURL else { return }
     guard let toURL = singlePhoto.url else { return }
     PhotoItem.movePhotoItemOnDisk(from: fromURL, to: toURL)
     NotificationCenter.default.post(name: .singleItemDidUnfolder, object: singlePhoto)
    }

    deletedURLs.forEach { PhotoItem.deletePhotoItemFromDisk(at: $0) }
   }
  }
 }//final func removeSinglePhotoFolders()...
 


 final func removeSelectedItems()
 {
  let selected = selectedObjects
  
  selected.forEach { undoer.removeAllOperations(for: $0) }
  
  removeSelectedFromDrags(with: selected)
  
  let deletedURLs = selected.compactMap{ $0.url }
  let deletedIDs = selectedPhotoIDs
  
  managedObjectContext?.performChanges( block:
  {
   selected.forEach
   {
    $0.shiftRowPositionsBeforeDelete()
    switch $0
    {
     case let photo as Photo:
      photo.folder?.removeFromPhotos(photo)
      self.removeFromPhotos(photo)
     
     case let folder as PhotoFolder:
      self.removeFromPhotos(folder.photos ?? [])
      self.removeFromFolders(folder)
   
     default : break
    }
    
    self.managedObjectContext?.delete($0)
    
   }
  })
  {result in
   guard case .success() = result else { return }
   DispatchQueue.global(qos: .utility).async
   {
    deletedURLs.forEach { PhotoItem.deletePhotoItemFromDisk(at: $0) }
    self.removeSinglePhotoFolders()
    deletedIDs.forEach
    {photoID in
     PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: photoID) }
    }
   }
  }
 }
 
}


