
import Foundation
import UIKit


extension ZoomView: UIDragInteractionDelegate,
                    UIDropInteractionDelegate,
                    PhotoItemsDraggable
 
{
 
 var photoSnippet: PhotoSnippet!
 {
  set {}
  get {return photoSnippetVC.photoSnippet}
 }
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
 {
  print (#function)
  if photoSnippetVC != nil
  {

   AppDelegate.clearAllDraggedItems()
  }
  
 }
 
 
 func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession)
 {
  
  print (#function)
  
  
  //PhotoSnippetViewController.printAllDraggedItems()
  
 }
 
 
 func getDragItems (_ interaction: UIDragInteraction, for session: UIDragSession) -> [UIDragItem]
 {
  for subView in subviews
  {
   if let _ = subView as? UIImageView
   {
    AppDelegate.clearCancelledDraggedItems()
    
    let photoItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
    let itemProvider = NSItemProvider(object: photoItem)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    
    guard allPhotoItems.lazy.first(where: {$0.id == photoItem.id}) == nil else {return []}
    
    AppDelegate.globalDragItems.append(photoItem)
    
    photoItem.isSelected = true
    photoItem.dragSession = session
    dragItem.localObject = photoItem
    
    AppDelegate.printAllDraggedItems()
    
    return [dragItem]
    
   }
  }
 
  return []
 }
  

 func dragInteraction(_ interaction: UIDragInteraction,
                        itemsForBeginning session: UIDragSession) -> [UIDragItem]
 {
   print (#function)
   //PhotoSnippetViewController.printAllDraggedItems()
   return getDragItems(interaction, for: session)
 }

 func dragInteraction(_ interaction: UIDragInteraction,
                        itemsForAddingTo session: UIDragSession,
                        withTouchAt point: CGPoint) -> [UIDragItem]

 {
  
  print (#function)
  let dragItems = getDragItems(interaction, for: session)
  
  //PhotoSnippetViewController.printAllDraggedItems()
  return dragItems
  
 }
  
  
  
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
 {
  if session.localDragSession == nil
  {
   return UIDropProposal(operation: .copy)
  }
  else
  {
   return UIDropProposal(operation: .move)
  }
 }
  
 
 func copyImagesFromSideApp (_ interaction: UIDropInteraction, with session: UIDropSession)
 {
  session.loadObjects(ofClass: UIImage.self)
  {[weak self] items in
    if let images = items as? [UIImage], images.count > 0,
       let vc = self?.photoSnippetVC,
       let ip = self?.zoomedCellIndexPath,
       let cv = self?.openWithCV(in: vc.view),
       let imageSize = self?.imageSize
    {
      var mergedPhotoItems = [vc.photoItems2D[ip.section][ip.row] as! PhotoItem]
     
      images.forEach
      {image in
       let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth: imageSize)
       newPhotoItem.isSelected = true
       mergedPhotoItems.append(newPhotoItem)
       vc.photoItems2D[ip.section].insert(newPhotoItem, at: ip.row)
       vc.photoCollectionView.insertItems(at: [ip])
      }
     
      if let _ = vc.performMergeIntoFolder(vc.photoCollectionView, from: mergedPhotoItems, into: ip)
      {
       self?.photoItems = mergedPhotoItems
       cv.reloadData()
      }
      else
      {
       print ("\(#function): Unable to merge loaded items into Photo Folder at Index Path: \(ip)")
      }
     
    }
  }
 }
 
 
 func unfolderLocalPhotoItems () -> [PhotoItemProtocol]
 {
  let removedIndexPaths = removedLocalFolders.compactMap{self.photoSnippetVC.photoItemIndexPath(photoItem: $0)}

  photoSnippetVC.photoCollectionView.performBatchUpdates(
  {
   removedIndexPaths.sorted{$0.row >= $1.row}.forEach
   {
     guard let rf = photoSnippetVC.photoItems2D[$0.section][$0.row] as? PhotoFolderItem else {return}
     guard let si = rf.singlePhotoItems.lazy.first(where: {x in !localFoldered.contains{$0.id == x.id}}) else
     {
      photoSnippetVC.photoItems2D[$0.section].remove(at: $0.row)
      photoSnippetVC.photoCollectionView.deleteItems(at: [$0])
      return
      
     }
     photoSnippetVC.photoItems2D[$0.section][$0.row] = si
    // photoSnippetVC.photoCollectionView.reloadItems(at: [$0])
   }
   
   localFoldered.forEach
   {
    photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert($0, at: zoomedCellIndexPath.row)
    photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
   }
  }, completion:
  {_ in
   self.photoSnippetVC.photoCollectionView.reloadSections(IndexSet(removedIndexPaths.map{$0.section}))
  })
  
  return PhotoItem.unfolderPhotos(from: photoSnippet, to: photoSnippet)
  
 }
 
 

// func xunfolderedLocalPhotoItems () -> [PhotoItemProtocol]
// {
//  let foldered = localFoldered
//  
//  if foldered.isEmpty {return []}
//  
//  let collectionView = photoSnippetVC.photoCollectionView!
//  
//  var nextItemFlag = false
//  
//  var photoItemsMap: [IndexPath : [PhotoItem]] = [:]
//  
//  for item in foldered
//  {
//   if nextItemFlag {nextItemFlag = false; continue}
//   
//   let folder = PhotoFolderItem(folder: item.photo.folder!)
//   let sourceIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: folder)!
//   
//   if let cell = collectionView.cellForItem(at: sourceIndexPath) as? PhotoFolderCell
//   {
//    let ip = cell.photoItemIndexPath(photoItem: item)!
//    cell.photoItems.remove(at: ip.row)
//    cell.photoCollectionView.deleteItems(at: [ip])
//    
//    if (cell.photoItems.count == 1)
//    {
//     photoSnippetVC.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
//     AppDelegate.removeDraggedItem(item: folder)
//     let singleItem = cell.photoItems.remove(at: 0)
//     cell.photoCollectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
//     collectionView.deleteItems(at: [sourceIndexPath])
//     
//     if (singleItem.isSelected) {nextItemFlag = true}
//     else
//     {
//      photoSnippetVC.photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
//      
//      if (collectionView.photoGroupType == .makeGroups)
//      {
//       singleItem.priorityFlag = photoSnippetVC.sectionTitles?[sourceIndexPath.section]
//      }
//      collectionView.insertItems(at: [sourceIndexPath])
//      collectionView.reloadSections([sourceIndexPath.section])
//     }
//    }
//   }
//   else 
//   {
//    var proxyPhotoItems: [PhotoItem] = []
//    if let photoItems = photoItemsMap[sourceIndexPath]
//    {
//     proxyPhotoItems = photoItems
//    }
//    else if let photosInFolder = folder.folder.photos?.allObjects as? [Photo]
//    {
//     proxyPhotoItems = photosInFolder.map{PhotoItem(photo: $0)}
//    }
//    else
//    {
//     print ("Invalid Folder at Index Path \(sourceIndexPath)")
//     continue
//    }
//    
//    let itemIndex = proxyPhotoItems.index{$0.id == item.id}
//    proxyPhotoItems.remove(at: itemIndex!)
//    photoItemsMap[sourceIndexPath] = proxyPhotoItems
//    
//    if (proxyPhotoItems.count == 1)
//    {
//     photoSnippetVC.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
//     AppDelegate.removeDraggedItem(item: folder)
//     let singleItem = proxyPhotoItems.remove(at: 0)
//     photoItemsMap[sourceIndexPath] = nil
//     collectionView.deleteItems(at: [sourceIndexPath])
//     
//     if (singleItem.isSelected) {nextItemFlag = true}
//     else
//     {
//      photoSnippetVC.photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
//      
//      if (collectionView.photoGroupType == .makeGroups)
//      {
//       singleItem.priorityFlag = photoSnippetVC.sectionTitles?[sourceIndexPath.section]
//      }
//      collectionView.insertItems(at: [sourceIndexPath])
//      collectionView.reloadSections([sourceIndexPath.section])
//     } //if (singleItem.isSelected)...
//    } //if (proxyPhotoItems.count == 1)...
//   } //if let cell = collectionView.cellForItem... else...
//  } //for item in...
//  
//  let unfoldered = PhotoItem.unfolderPhotos(from: photoSnippet, to: photoSnippet)
//  
//  unfoldered.forEach
//  {movedItem in
//   photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert(movedItem, at: zoomedCellIndexPath.row)
//   photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
//  }
//  
//  return unfoldered
// }
// 
// 
// 
// 
 func movedOuterPhotoItems () -> [PhotoItemProtocol]
 {
   var movedItems: [PhotoItemProtocol] = []
   outerSnippets.forEach
   {source in

     let folders:    [PhotoItemProtocol] = PhotoItem.moveFolders    (from: source, to: photoSnippet)
     let photos :    [PhotoItemProtocol] = PhotoItem.movePhotos     (from: source, to: photoSnippet)
     let unfoldered: [PhotoItemProtocol] = PhotoItem.unfolderPhotos (from: source, to: photoSnippet)
    
     let totalMoved = photos + folders + unfoldered
    
     totalMoved.forEach
     {movedItem in
       photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert(movedItem, at: zoomedCellIndexPath.row)
       photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
     }
    
     movedItems += totalMoved
    
   }
   return movedItems
 }
 
 
 
 func movePhotoItemsInsideApp ()
 {
  let zoomedItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
  
  let local =  localItems
  let unfold = unfolderLocalPhotoItems()
  let moved =  movedOuterPhotoItems ()
  
  let totalItems = local + unfold + moved + (local.contains{$0.id == zoomedItem.id} ? [] : [zoomedItem])
 
  guard totalItems.count > 1 else {return}
  
  totalItems.forEach{$0.isSelected = true}
 
  let photoCV = photoSnippetVC.photoCollectionView!
  
  if let newFolderItem = photoSnippetVC.performMergeIntoFolder(photoCV, from: totalItems, into: zoomedCellIndexPath)
  {
   zoomedPhotoItem = newFolderItem
   zoomedCellIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: newFolderItem)
   
   let cv = openWithCV(in: photoSnippetVC.view)
   if let newFolderCell = photoCV.cellForItem(at: zoomedCellIndexPath!) as? PhotoFolderCell
   {
    photoItems = newFolderCell.photoItems
   }
   else if let photosInFolder = newFolderItem.folder.photos?.allObjects as? [Photo]
   {
    photoItems = photosInFolder.map{PhotoItem(photo: $0)}
   }
   else
   {
    print ("Invalid new merged folder at index path \(zoomedCellIndexPath!)")
   }
   cv.reloadData()
  }
  else
  {
   print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(zoomedCellIndexPath.description)")
  }

 }
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
 {
   print (#function)
  
   if (session.localDragSession != nil && allPhotoItems.count > 0)
   {
    movePhotoItemsInsideApp ()
   }
   else
   {
    copyImagesFromSideApp (interaction, with: session)
   }
 }
 
 
}//extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate...
