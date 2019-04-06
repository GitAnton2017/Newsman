
import Foundation
import CoreData
import UIKit


extension PhotoSnippetViewController
{

 
 func performMergeIntoFolder (_ collectionView: PhotoSnippetCollectionView,
                                from photoItems: [PhotoItemProtocol],
                                into destinationIndexPath: IndexPath) -> PhotoFolderItem?
 {
  if let newFolder = PhotoFolderItem(photoSnippet: photoSnippet)
  {
   PhotoItem.MOC.persistAndWait
   {
    newFolder.priorityFlag = self.sectionTitles?[destinationIndexPath.section]

    photoItems.forEach
    {photoItem in
     let sourceIndexPath = self.photoItemIndexPath(photoItem: photoItem)
     self.photoItems2D[sourceIndexPath!.section].remove(at: sourceIndexPath!.row)
     photoItem.removeFromDrags()
     collectionView.deleteItems(at: [sourceIndexPath!])

     if (collectionView.photoGroupType == .makeGroups && sourceIndexPath!.section != destinationIndexPath.section)
     {
      collectionView.reloadSections([sourceIndexPath!.section])
     }

    }//photoItems.forEach...

    let sectionCnt = self.photoItems2D[destinationIndexPath.section].count
    if (destinationIndexPath.row < sectionCnt)
    {
     self.photoItems2D[destinationIndexPath.section].insert(newFolder, at: destinationIndexPath.row)
     collectionView.insertItems(at: [destinationIndexPath])
    }
    else
    {
     self.photoItems2D[destinationIndexPath.section].append(newFolder)
     let indexPath = IndexPath(row: sectionCnt, section: destinationIndexPath.section)
     collectionView.insertItems(at: [indexPath])
    }

    if (collectionView.photoGroupType == .makeGroups)
    {
     collectionView.reloadSections([destinationIndexPath.section])
    }

    self.deleteEmptySections()

    PhotoFolderItem.removeEmptyFolders(from: self.photoSnippet)
   }
   return newFolder
  }

  return nil
 }



// func unfolderedLocalPhotoItems (in collectionView: PhotoSnippetCollectionView,
//                                 at destinationIndexPath: IndexPath) -> [PhotoItemProtocol]
//
// {
//  let foldered = localFoldered
//  if foldered.isEmpty {return []}
//  var nextItemFlag = false
//  var photoItemsMap: [IndexPath : [PhotoItem]] = [:]
//
//  for item in foldered
//  {
//     if (nextItemFlag) {nextItemFlag = false; continue}
//     let folder = PhotoFolderItem(folder: item.photo.folder!)
//     let sourceIndexPath = photoItemIndexPath(photoItem: folder)!
//
//     if let cell = collectionView.cellForItem(at: sourceIndexPath) as? PhotoFolderCell
//     {
//      let ip = cell.photoItemIndexPath(photoItem: item)!
//      cell.photoItems.remove(at: ip.row)
//      cell.photoCollectionView.deleteItems(at: [ip])
//
//      if (cell.photoItems.count == 1)
//      {
//       photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
//       AppDelegate.removeDraggedItem(item: folder)
//       let singleItem = cell.photoItems.remove(at: 0)
//       cell.photoCollectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
//       collectionView.deleteItems(at: [sourceIndexPath])
//
//       if (singleItem.isSelected) {nextItemFlag = true}
//       else
//       {
//        photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
//
//        if (collectionView.photoGroupType == .makeGroups)
//        {
//         singleItem.priorityFlag = sectionTitles?[sourceIndexPath.section]
//        }
//        collectionView.insertItems(at: [sourceIndexPath])
//        collectionView.reloadSections([sourceIndexPath.section])
//       }//if (singleItem.isSelected)....
//       if let zv = collectionView.zoomView {zv.removeZoomView()}
//      }//if (cell.photoItems.count == 1)...
//     }
//     else
//     {
//      var proxyPhotoItems: [PhotoItem] = []
//      if let photoItems = photoItemsMap[sourceIndexPath]
//      {
//       proxyPhotoItems = photoItems
//      }
//      else if let photosInFolder = folder.folder.photos?.allObjects as? [Photo]
//      {
//       proxyPhotoItems = photosInFolder.map{PhotoItem(photo: $0)}
//      }
//
//      let itemIndex = proxyPhotoItems.index{$0.id == item.id}
//      proxyPhotoItems.remove(at: itemIndex!)
//      photoItemsMap[sourceIndexPath] = proxyPhotoItems
//
//      if (proxyPhotoItems.count == 1)
//      {
//       photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
//       AppDelegate.removeDraggedItem(item: folder)
//       let singleItem = proxyPhotoItems.remove(at: 0)
//       photoItemsMap[sourceIndexPath] = nil
//       collectionView.deleteItems(at: [sourceIndexPath])
//
//       if (singleItem.isSelected) {nextItemFlag = true}
//       else
//       {
//        photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
//
//        if (collectionView.photoGroupType == .makeGroups)
//        {
//         singleItem.priorityFlag = sectionTitles?[sourceIndexPath.section]
//        }
//        collectionView.insertItems(at: [sourceIndexPath])
//        collectionView.reloadSections([sourceIndexPath.section])
//       } // if (singleItem.isSelected)...
//
//       if let zv = collectionView.zoomView {zv.removeZoomView()}
//      } //if (proxyPhotoItems.count == 1)...
//     } //if let cell = collectionView.cellForItem...
//
//     if let zv = collectionView.zoomView,
//        let cv = zv.presentSubview as? UICollectionView,
//        let ip = zv.photoItemIndexPath(photoItem: item)
//     {
//        zv.photoItems.remove(at: ip.row)
//        cv.deleteItems(at: [ip])
//     }//if let zv = collectionView.zoomView...
//  } //for item in...
//
//  let unfoldered = PhotoItem.unfolderPhotos(from: photoSnippet, to: photoSnippet)
//
//  unfoldered.forEach
//  {movedItem in
//
//   photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
//
//   if (collectionView.photoGroupType == .makeGroups)
//   {
//    movedItem.priorityFlag = sectionTitles?[destinationIndexPath.section]
//   }
//
//   collectionView.insertItems(at: [destinationIndexPath])
//   collectionView.reloadSections([destinationIndexPath.section])
//
//  }
//
//  return unfoldered
// }
// //***************************************************************************************************************/
//
// //MARK: -
//
////***************************************************************************************************************/
// func movedOuterPhotoItems (in collectionView: PhotoSnippetCollectionView,
//                            at destinationIndexPath: IndexPath) -> [PhotoItemProtocol]
////***************************************************************************************************************/
// {
//
//  var movedItems: [PhotoItemProtocol] = []
//
//  outerSnippets.forEach
//  {source in
//
//   let unfoldered: [PhotoItemProtocol] = PhotoItem.unfolderPhotos (from: source, to: photoSnippet)
//   let folders:    [PhotoItemProtocol] = PhotoItem.moveFolders    (from: source, to: photoSnippet)
//   let photos :    [PhotoItemProtocol] = PhotoItem.movePhotos     (from: source, to: photoSnippet)
//
//
//   let totalMoved = photos + folders + unfoldered
//
//   totalMoved.forEach
//   {movedItem in
//     photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
//     if collectionView.photoGroupType == .makeGroups
//     {
//      movedItem.priorityFlag = sectionTitles?[destinationIndexPath.section]
//     }
//     collectionView.insertItems(at: [destinationIndexPath])
//
//   }
//
//   movedItems += totalMoved
//
//  }
//
//  if (collectionView.photoGroupType == .makeGroups && movedItems.count > 0)
//  {
//    collectionView.reloadSections([destinationIndexPath.section])
//  }
//
//  return movedItems
// }
////***************************************************************************************************************/
//
// //MARK: -
//
////***************************************************************************************************************/
// func performMergeIntoFolder ( in collectionView: PhotoSnippetCollectionView,
//                                performDropWith coordinator: UICollectionViewDropCoordinator,
//                                at destinationIndexPath: IndexPath)
////***************************************************************************************************************/
// {
//
//
//  let local = localItems
//  let unfold = unfolderedLocalPhotoItems (in: collectionView, at: destinationIndexPath)
//  let moved = movedOuterPhotoItems (in: collectionView, at: destinationIndexPath)
//
//  let totalItems = local + moved + unfold
//
//  guard totalItems.count > 1 else {return}
//
//  totalItems.forEach{$0.isSelected = true}
//
//  if let newFolderItem = performMergeIntoFolder(collectionView, from: totalItems, into: destinationIndexPath)
//  {
//    let ip = photoItemIndexPath(photoItem: newFolderItem)
//    if let cell = collectionView.cellForItem(at: ip!) as? PhotoFolderCell
//    {
//     coordinator.session.items.forEach{coordinator.drop($0, intoItemAt: destinationIndexPath, rect: cell.bounds)}
//    }
//    else
//    {
//      print ("\(#function): Invalid Merged Folder Cell at Index Path: \(ip!)")
//    }
//
//    if let zv = collectionView.zoomView
//    {
//     if let zoomedItem = zv.zoomedPhotoItem,
//        let zoomedIndexPath = photoItemIndexPath(photoItem: zoomedItem)
//     {
//      zv.zoomedCellIndexPath = zoomedIndexPath
//     }
//     else if zv.zoomedCellIndexPath == destinationIndexPath,
//             let newFolderCell = collectionView.cellForItem(at: destinationIndexPath) as? PhotoFolderCell
//     {
//      zv.zoomedPhotoItem = newFolderItem
//      if zv.presentSubview is UIImageView
//      {
//       let cv = zv.openWithCV(in: view)
//       zv.photoItems = newFolderCell.photoItems
//       cv.reloadData()
//      }
//      else
//      {
//       let cv = zv.presentSubview as! UICollectionView
//       let deleted = zv.photoItems
//       deleted?.forEach
//       {photo in
//         let ip = zv.photoItemIndexPath(photoItem: photo)
//         zv.photoItems.remove(at: ip!.row)
//         cv.deleteItems(at: [ip!])
//
//       }
//
//       newFolderCell.photoItems.forEach
//       {photo in
//         zv.photoItems.insert(photo, at: 0)
//         cv.insertItems(at: [IndexPath(row: 0, section: 0)])
//       }
//
//      }
//     }
//     else
//     {
//      zv.removeZoomView()
//     }
//    }
//
//  }
//  else
//  {
//    print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(destinationIndexPath)")
//  }
//
// }
////***************************************************************************************************************/
//
// //MARK: -
//
////***************************************************************************************************************/
// func performItemsMove (in collectionView: PhotoSnippetCollectionView,
//                        performDropWith coordinator: UICollectionViewDropCoordinator,
//                        at destinationIndexPath: IndexPath)
////***************************************************************************************************************/
// {
//  PhotoItem.MOC.persistAndWait
//  {
//   self.localItems.forEach
//   {photoItem in
//    let sourceIndexPath = self.photoItemIndexPath(photoItem: photoItem)
//    collectionView.movePhoto(sourceIndexPath: sourceIndexPath!, destinationIndexPath: destinationIndexPath)
//    photoItem.isSelected = false
//   }
//
//   let outerItems = self.movedOuterPhotoItems      (in: collectionView,  at: destinationIndexPath)
//   let unfoldered = self.unfolderedLocalPhotoItems (in: collectionView,  at: destinationIndexPath)
//
//   //coordinator.session.items.forEach{coordinator.drop($0, toItemAt: destinationIndexPath)}
//
//   let totalItems = self.localItems + outerItems + unfoldered
//
//   if let zv = collectionView.zoomView, let zoomedItem = zv.zoomedPhotoItem
//   {
//    zv.zoomedCellIndexPath = self.photoItemIndexPath(photoItem: zoomedItem)
//   }
//
//   print ("TOTAL ITEMS MOVED SUCCESSFULLY TO \(destinationIndexPath) - \(totalItems.count)")
//  }
// }//func performItemsMove (_ collectionView: UICollectionView...
////***************************************************************************************************************/
//
////MARK: -
//
////***************************************************************************************************************/
// func movePhotosInsideApp (  in collectionView: PhotoSnippetCollectionView,
//                             performDropWith coordinator: UICollectionViewDropCoordinator,
//                             at destinationIndexPath: IndexPath)
////***************************************************************************************************************/
// {
//
//   let dropItems = coordinator.items.filter{$0.sourceIndexPath != nil}
//
//   if (dropItems.first{$0.sourceIndexPath == destinationIndexPath} != nil)
//   {
//    //performMergeIntoFolder(in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
//   }
//   else
//   {
//    performItemsMove(in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
//   }
//
//
//
// }//func movePhotosInsideCollectionView (_ collectionView: UICollectionView...
//
//
//

 



}//extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate...


