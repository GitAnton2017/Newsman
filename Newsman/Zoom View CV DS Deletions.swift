
//
//  Created by Anton2016 on 25/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension ZoomView
{
 
 func deleteSinglePhoto(photo: Photo, from collectionView: UICollectionView)
 {
  guard let indexPath = photoItemIndexPath(with: photo) else { return }
  photoItems?.remove(at: indexPath.row)
  collectionView.deleteItems(at: [indexPath])
 }
 
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
  switch (hostedManagedObject, presentSubview)
  {
   case let (photo as Photo, is UIImageView)
    where photo.isUnfoldered && zoomedPhotoItem?.hostedManagedObject.objectID == photo.objectID:
     removeZoomView()
   
   case let (folder as PhotoFolder, is UICollectionView )
    where zoomedPhotoItem?.hostedManagedObject.objectID == folder.objectID:
     removeZoomView()
   
   case let (photo as Photo, photoCollectionView as UICollectionView):
     guard let indexPath = photoItemIndexPath(with: photo) else { break }
     photoItems.remove(at: indexPath.row)
     photoCollectionView.deleteItems(at: [indexPath])
   
   default: break
  }
 }
}
