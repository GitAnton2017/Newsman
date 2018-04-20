
import Foundation
import CoreData
import UIKit


//MARK: -

extension ZoomView: UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
 //MARK: -
 
 
 func animateDragItemsBegin (_ collectionView: UICollectionView, dragItems: [UIDragItem])
 {
   dragItems.forEach
   {item in
    if let photoItem = item.localObject as? PhotoItem,
       let itemIndexPath = photoItemIndexPath(photoItem: photoItem),
       let cellInZoomCV = collectionView.cellForItem(at: itemIndexPath)
    {
     PhotoSnippetViewController.startCellDragAnimation(cell: cellInZoomCV)
    }
    
    if let photoItem = item.localObject as? PhotoItem,
     let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedCellIndexPath) as? PhotoFolderCell,
     let cellInFolderIndexPath = zoomedCell.photoItemIndexPath(photoItem: photoItem),
     let cellInFolder = zoomedCell.photoCollectionView.cellForItem(at: cellInFolderIndexPath)
    {
     PhotoSnippetViewController.startCellDragAnimation(cell: cellInFolder)
    }
    
    
  }
 }
 
 func animateDragItemsEnd (_ collectionView: UICollectionView)
 {
  globalDragItems.forEach
   {item in
    if let photoItem = item as? PhotoItem,
       let itemIndexPath = photoItemIndexPath(photoItem: photoItem),
       let cell = collectionView.cellForItem(at: itemIndexPath),
       let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedCellIndexPath) as? PhotoFolderCell,
       let cellInFolderIndexPath = zoomedCell.photoItemIndexPath(photoItem: photoItem),
       let cellInFolder = zoomedCell.photoCollectionView.cellForItem(at: cellInFolderIndexPath)
     
    {
     PhotoSnippetViewController.stopCellDragAnimation(cell: cell)
     PhotoSnippetViewController.stopCellDragAnimation(cell: cellInFolder)
    }
    else
    if let photoItem = item as? PhotoItemProtocol,
       let itemIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: photoItem),
       let cell = photoSnippetVC.photoCollectionView.cellForItem(at: itemIndexPath)
    {
     PhotoSnippetViewController.stopCellDragAnimation(cell: cell)
    }
    else
    if let photoItem = item as? PhotoItem,
       let folder = photoItem.photo.folder,
       let folderCellIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: PhotoFolderItem(folder: folder)),
       let folderCell = photoSnippetVC.photoCollectionView.cellForItem(at: folderCellIndexPath) as? PhotoFolderCell,
       let cellInFolderIndexPath = folderCell.photoItemIndexPath(photoItem: photoItem),
       let cellInFolder = folderCell.photoCollectionView.cellForItem(at: cellInFolderIndexPath)
    {
     PhotoSnippetViewController.stopCellDragAnimation(cell: cellInFolder)
    }
     
   
  }
 }
//***************************************************************************************************************
 var zoomedFolderPhotos: [PhotoItem]
 {
  let locals = globalDragItems.filter
  {
   if let photoItem = $0 as? PhotoItem,
      let photoItemFolder = photoItem.photo.folder,
      photoItem.photoSnippet === photoSnippetVC.photoSnippet,
      let zoomedFolder = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row] as? PhotoFolderItem,
      photoItemFolder.id == zoomedFolder.id
   {
    return true
   }
   return false
  }
  return locals as! [PhotoItem]
 }

//************************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
//************************************************************************************************************************
 {
    print (#function)
    animateDragItemsBegin(collectionView, dragItems: session.items)
 }
//************************************************************************************************************************
 
 //MARK: -
 
//************************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
//************************************************************************************************************************
 {
  print (#function)
  animateDragItemsEnd(collectionView)
  PhotoSnippetViewController.clearAllDraggedItems()
  
 }
//************************************************************************************************************************
 
//MARK: -
 
//************************************************************************************************************************
 func getDragItems (_ collectionView: UICollectionView, for session: UIDragSession,
                    forCellAt indexPath: IndexPath) -> [UIDragItem]
//************************************************************************************************************************
 {
  
  PhotoSnippetViewController.clearCancelledDraggedItems()
  
  let photoItem = photoItems[indexPath.row]
  
  if collectionView.cellForItem(at: indexPath) != nil
  {
   let itemProvider = NSItemProvider(object: photoItem)
   let dragItem = UIDragItem(itemProvider: itemProvider)
   
   for item in globalDragItems
   {
    if let photoGlobalItem = item as? PhotoItemProtocol,
       photoGlobalItem.id == photoItem.id || photoGlobalItem.id == zoomedPhotoItem?.id
    {
     return []
    }
   }
   
   (UIApplication.shared.delegate as! AppDelegate).globalDragItems.append(photoItem)
   
   photoItem.isSelected = true
   photoItem.dragSession = session
   dragItem.localObject = photoItem
   PhotoSnippetViewController.printAllDraggedItems()
   
   return [dragItem]
   
  }
  else
  {
   return []
  }
 }
 
//************************************************************************************************************************
 
//MARK: -

//************************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem]
//************************************************************************************************************************
 {
    return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }
//************************************************************************************************************************
 
//MARK: -
 
//************************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession,
                     at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//************************************************************************************************************************
 {
    let dragItems = getDragItems(collectionView, for: session, forCellAt: indexPath)
    animateDragItemsBegin(collectionView, dragItems: dragItems)
    return dragItems
 }
//************************************************************************************************************************
 
//MARK: -

//************************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
//************************************************************************************************************************
 {
   if session.localDragSession != nil
   {
    if session.items.count == 1
    {
     return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
    }
    
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
   }
   else
   {
    return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
   }
 }//func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate...
//************************************************************************************************************************

//MARK: -
 
//************************************************************************************************************************
 func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                             performDropWith coordinator: UICollectionViewDropCoordinator,
                             at destinationIndexPath: IndexPath)
//************************************************************************************************************************
  
  
 {
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                     reuseIdentifier: "ZoomCollectionViewCell")
   
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   {[weak self] item, error in
    OperationQueue.main.addOperation
    {
     guard let image = item as? UIImage,
           let ip = self?.zoomedCellIndexPath,
           let vc = self?.photoSnippetVC,
           let imageSize = self?.imageSize,
           let zoomedCell = vc.photoCollectionView.cellForItem(at: ip) as? PhotoFolderCell
      
     else
     {
       placeholderContext.deletePlaceholder()
       return
     }
     
     placeholderContext.commitInsertion
     {indexPath in
      let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth:imageSize)
      zoomedCell.photoItems.insert(newPhotoItem, at: indexPath.row)
      zoomedCell.photoCollectionView.insertItems(at: [indexPath])
      self?.photoItems.insert(newPhotoItem, at: indexPath.row)
     }
    }
   }
  }
  
 }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
//************************************************************************************************************************
 
 //MARK: -
 
 //*************************************************************************************************************************
 func movePhotoItemsInsideApp (_ collectionView: UICollectionView,
                               performDropWith coordinator: UICollectionViewDropCoordinator,
                               to destinationIndexPath: IndexPath)
 //*************************************************************************************************************************
 {
  
  let zoomedFolder = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row] as! PhotoFolderItem
 
  zoomedFolderPhotos.forEach
  {photo in
   let sourceIndexPath = photoItemIndexPath(photoItem: photo)
   let moved = photoItems.remove(at: sourceIndexPath!.row)
   photoItems.insert(moved, at: destinationIndexPath.row)
   collectionView.moveItem(at: sourceIndexPath!, to: destinationIndexPath)
   photo.isSelected = false
  }
  
  coordinator.items.forEach{coordinator.drop($0.dragItem, toItemAt: destinationIndexPath)}
  
  let local = localItems
  let unfold = unfolderedLocalPhotoItems ()
  let moved  = movedOuterPhotoItems      ()
  
  let totalItems = local + moved + unfold + (localFolders.contains{$0.id == zoomedFolder.id} ? [] : [zoomedFolder])
  
  guard totalItems.count > 1 else {return}
  
  totalItems.forEach{$0.isSelected = true}
  
  let photoCV = photoSnippetVC.photoCollectionView!
  
  if let newFolderItem = photoSnippetVC.performMergeIntoFolder(photoCV, from: totalItems, into: zoomedCellIndexPath)
  {
   zoomedPhotoItem = newFolderItem
   zoomedCellIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: newFolderItem)
   
   var folderPhotoItems: [PhotoItem] = []
   if let newFolderCell = photoCV.cellForItem(at: zoomedCellIndexPath!) as? PhotoFolderCell
   {
    folderPhotoItems = newFolderCell.photoItems
   }
   else if let photosInFolder =  newFolderItem.folder.photos?.allObjects as? [Photo]
   {
    folderPhotoItems = photosInFolder.map{PhotoItem(photo: $0)}
   }
   else
   {
    print ("Invalid new merged folder at index path \(zoomedCellIndexPath!)")
   }
   
   let newPhotoItems = folderPhotoItems.filter
   {photo in
    return !photoItems.contains{$0.id == photo.id}
   }
   
   newPhotoItems.forEach
    {photo in
     photoItems.insert(photo, at: destinationIndexPath.row)
     collectionView.insertItems(at: [destinationIndexPath])
   }
   
  }
  else
  {
   print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(zoomedCellIndexPath)")
  }
  
 }//func movePhotoItemsInsideApp ...
 //*************************************************************************************************************************
 
 //MARK: -

    
//***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                     performDropWith coordinator: UICollectionViewDropCoordinator)
//***************************************************************************************************************/
 {
  print (#function)
  
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
  
  switch (coordinator.proposal.operation)
  {
    case .move:
   
     if allPhotoItems.isEmpty {return}
     movePhotoItemsInsideApp (collectionView, performDropWith: coordinator, to: destinationIndexPath)
   
    case .copy: copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
   
   default: return
  }
  
  
 } //func collectionView(_ collectionView: UICollectionView, performDropWith...
 //***************************************************************************************************************/
 
 //MARK: -

    
    
    
 
    
 
}//extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate...

//MARK: -

