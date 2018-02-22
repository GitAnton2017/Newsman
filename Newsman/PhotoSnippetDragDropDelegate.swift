
import Foundation
import CoreData
import UIKit
//MARK: -

//MARK: =============================== CV ITEMS DRAG AND DROP DELEGATE =================================
extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
//=======================================================================================================
{
    
//MARK: -
 
//MARK:-------------------------------- PREPARING DRAG ITEMS --------------------------------------------
//-------------------------------------------------------------------------------------------------------
 func getDragItems (forCellAt indexPath: IndexPath) -> [UIDragItem]
//-------------------------------------------------------------------------------------------------------
    
 {
    switch (photoItems2D[indexPath.section][indexPath.row])
    {
     case let item as PhotoItem:
      if let image = item.getImage(requiredImageWidth: imageSize)
      {
        let itemProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
      }
      else
      {
       return []
      }
     case let item as PhotoFolderItem:
      if let photos = item.folder.photos?.allObjects as? [Photo]
      {
        var dragItems = [UIDragItem]()
        let photoItems = photos.map{PhotoItem(photo: $0)}
        photoItems.forEach
        {
          if let image = $0.getImage(requiredImageWidth: imageSize)
          {
           let itemProvider = NSItemProvider(object: image)
           dragItems.append(UIDragItem(itemProvider: itemProvider))
          }
        }
        
        dragItems.first?.localObject = indexPath
        return dragItems
      }
      else
      {
       return []
      }
     default: return []
    }
 }//func getDragItems (forCellAt indexPath: IndexPath)...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:--------------------------- PREPARING DRAG ITEMS DELEGATE METHOD ---------------------------------
//-------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem]
//-------------------------------------------------------------------------------------------------------
 {
   if let cell = collectionView.cellForItem(at: indexPath)
   {
       if isInvisiblePhotosDraged
       {
        if !cell.isSelected
        {
           photoItems2D[indexPath.section][indexPath.row].isSelected = true
        }
        return getDragItems(forCellAt: indexPath)
        
       }
       else
       {
         isInvisiblePhotosDraged = true
         var dragItems = getDragItems(forCellAt: indexPath)
         for item in photoItems2D.reduce([], {$0 + $1.filter({$0.isSelected})})
         {
           let itemIndexPath = photoItemIndexPath(photoItem: item)
           guard itemIndexPath != indexPath else {continue}
           if collectionView.indexPathsForVisibleItems.first(where: {$0 == itemIndexPath}) == nil ||
              collectionView.indexPathsForSelectedItems?.first(where: {$0 == itemIndexPath}) == nil
           {
             dragItems.append(contentsOf: getDragItems(forCellAt: itemIndexPath))
           }
         }
        
         if !cell.isSelected
         {
           photoItems2D[indexPath.section][indexPath.row].isSelected = true
         }
         return dragItems
       }
   }
   else
   {
     return []
   }

 }//func collectionView(_ collectionView: UICollectionView, itemsForBeginning...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:----------------- ADDING DRAG ITEMS TO CURRENT DRAG SESSION DELEGATE METHOD ----------------------
//-------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,
                       itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//-------------------------------------------------------------------------------------------------------
 {
  if let cell = collectionView.cellForItem(at: indexPath)
  {
    if !cell.isSelected
    {
        photoItems2D[indexPath.section][indexPath.row].isSelected = true
    }
  
    return getDragItems(forCellAt: indexPath)
  }
  else
  {
      return []
  }
 }//unc collectionView(_ collectionView: UICollectionView,itemsForAddingTo...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
    
//MARK:----------------------------- DROPPING PROPOSAL DELEGATE METHOD ----------------------------------
//-------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate session: UIDropSession,
                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
  if session.localDragSession != nil
  {
   return UICollectionViewDropProposal(operation: .move)
  }
  else
  {
   return UICollectionViewDropProposal(operation: .copy)
  }
 }//func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
    
//---------------------------------------------------------------------------------------------------------
 typealias DropPhotoItem = (photoItem: PhotoItemProtocol, dropItem: UICollectionViewDropItem)
//---------------------------------------------------------------------------------------------------------
  
    
    
//MARK:---------------------- MERGING DRAGED PHOTO ITEMS INTO PHOTO FOLDER --------------------------------
//---------------------------------------------------------------------------------------------------------
 func performMergeIntoFolder (_ collectionView: UICollectionView,
                                performDropWith coordinator: UICollectionViewDropCoordinator,
                                to destinationIndexPath: IndexPath,
                                using dropPhotoItems: [DropPhotoItem])
//---------------------------------------------------------------------------------------------------------
 {
  if let newFolder = PhotoFolderItem(photoSnippet: photoSnippet)
  {
    photoItems2D[destinationIndexPath.section].insert(newFolder, at: destinationIndexPath.row)
    collectionView.insertItems(at: [destinationIndexPath])
    
    dropPhotoItems.forEach
    {
       let sourceIndexPath = photoItemIndexPath(photoItem: $0.photoItem)
       photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
       collectionView.deleteItems(at: [sourceIndexPath])
       coordinator.drop($0.dropItem.dragItem, toItemAt: destinationIndexPath)
    }
   
    PhotoFolderItem.removeEmptyFolders(from: photoSnippet)
  }
 }//func performMergeIntoFolder (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:------------------------- MOVE OF DRAGED PHOTO ITEMS TO DESTINATION IP -----------------------------
//---------------------------------------------------------------------------------------------------------
 func performItemsMove (_ collectionView: UICollectionView,
                          performDropWith coordinator: UICollectionViewDropCoordinator,
                          to destinationIndexPath: IndexPath,
                          using dropPhotoItems: [DropPhotoItem])
//---------------------------------------------------------------------------------------------------------
 {
   dropPhotoItems.forEach
   {
    var item = $0
    item.photoItem.isSelected = false
    let sourceIndexPath = photoItemIndexPath(photoItem: item.photoItem)
    let photoCV = collectionView as! PhotoSnippetCollectionView
    photoCV.movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    coordinator.drop(item.dropItem.dragItem, toItemAt: destinationIndexPath)
   }
 }//func performItemsMove (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
  
    
    
//MARK:------------------ MOVING DRAGED PHOTO ITEMS INSIDE CV CREATED AT DESTINATION IP -------------------
//---------------------------------------------------------------------------------------------------------
 func movePhotosInsideCollectionView (_ collectionView: UICollectionView,
                                        performDropWith coordinator: UICollectionViewDropCoordinator,
                                        to destinationIndexPath: IndexPath)
//---------------------------------------------------------------------------------------------------------
 {
   isInvisiblePhotosDraged = false
   var mergeIntoFolder = false //merge into folder flag...
    
   var dropPhotoItems = [DropPhotoItem]()
   //counting only drag items having assigned source index path to localObject field...
   let itemsCount = coordinator.items.filter{$0.dragItem.localObject != nil}.count
    
   for dropItem in coordinator.items
   {
    if let indexPath = dropItem.dragItem.localObject as? IndexPath
    {
     let photoItem = photoItems2D[indexPath.section][indexPath.row]
     dropPhotoItems.append((photoItem, dropItem))
     //if one of the index pathes of the draged items equals to destination index path and number of items more than one...
     //we try to merge items into single folder...
        
     if (indexPath == destinationIndexPath && itemsCount > 1)
     {
      mergeIntoFolder = true
     }
    }
   }
 
   if mergeIntoFolder
   {
    performMergeIntoFolder(collectionView, performDropWith: coordinator, to: destinationIndexPath, using: dropPhotoItems)
   }
   else
   {
    performItemsMove(collectionView, performDropWith: coordinator, to: destinationIndexPath, using: dropPhotoItems)
   }
 }//func movePhotosInsideCollectionView (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:-------------------------- MOVING DRAGED PHOTO FROM ANOTHER APP ------------------------------------
//---------------------------------------------------------------------------------------------------------
 func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                              performDropWith coordinator: UICollectionViewDropCoordinator,
                              to destinationIndexPath: IndexPath)
//---------------------------------------------------------------------------------------------------------
 {
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "PhotoSnippetCell")
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   {[weak self] item, error in
     OperationQueue.main.addOperation
     {
      guard let image = item as? UIImage else
      {
       placeholderContext.deletePlaceholder(); return
      }
      placeholderContext.commitInsertion
      {indexPath in
       let newPhotoItem = PhotoItem(photoSnippet: (self?.photoSnippet)!, image: image, cachedImageWidth:(self?.imageSize)!)
       if let flagStrs = self?.sectionTitles
       {
        newPhotoItem.photo.priorityFlag = flagStrs[indexPath.section]
       }
       self?.photoItems2D[indexPath.section].insert(newPhotoItem, at: indexPath.row)
      }
     }
    }
   }
 }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
   
    
    
    
//MARK:------------------------ MAKING PREPARATIONS BEFORE DRAG SESSION BEGINS ----------------------------
//---------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
//---------------------------------------------------------------------------------------------------------
 {
  session.localContext = self //getting strong referance to the current VC with current CV...
 }//func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
    
//MARK:----------------------- MOVING DRAGED PHOTO ITEMS BETWEEN CVs --------------------------------------
//---------------------------------------------------------------------------------------------------------
 func movePhotosBetweenCollectionViews (_ collectionView: UICollectionView,
                                          from dragSessionVC: PhotoSnippetViewController,
                                          performDropWith coordinator: UICollectionViewDropCoordinator,
                                          to destinationIndexPath: IndexPath)
//---------------------------------------------------------------------------------------------------------
 {
   if dragSessionVC.photoSnippet === photoSnippet
   {
    dragSessionVC.photoItems2D.reduce([], {$0 + $1.filter({$0.isSelected})}).forEach
    {
     var item = $0
     let sourceIndexPath = photoItemIndexPath(photoItem: item)
     item.isSelected = false
     let photoCV = collectionView as! PhotoSnippetCollectionView
     photoCV.movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
 
    }
   }
   else
   {
    let movedPhotoItems: [PhotoItemProtocol] = PhotoItem.movePhotos(from: dragSessionVC.photoSnippet, to: photoSnippet) ?? []
    let movedFolderItems: [PhotoItemProtocol] = PhotoItem.moveFolders(from: dragSessionVC.photoSnippet, to: photoSnippet) ?? []
    
    (movedPhotoItems + movedFolderItems).forEach
    {
      photoItems2D[destinationIndexPath.section].insert($0, at: destinationIndexPath.row)
      if photoCollectionView.photoGroupType == .makeGroups
      {
       var item = $0
       item.priorityFlag = sectionTitles?[destinationIndexPath.section]
      }
      (collectionView as! PhotoSnippetCollectionView).insertItems(at: [destinationIndexPath])
    }
   }
 
   coordinator.session.items.forEach{coordinator.drop($0, toItemAt: destinationIndexPath)}
 
 }//func movePhotosBetweenCollectionViews (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
    
//MARK:-------------------------------- PERFORM DROP DELEGATE METHOD --------------------------------------
//---------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {
  
   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
 
   switch (coordinator.proposal.operation)
   {
    case .move:
     if let dragSessionVC = coordinator.session.localDragSession?.localContext as? PhotoSnippetViewController, dragSessionVC !== self
     {
      movePhotosBetweenCollectionViews (collectionView, from: dragSessionVC, performDropWith: coordinator, to: destinationIndexPath)
      coordinator.session.localDragSession?.localContext = nil
     }
     else
     {
      movePhotosInsideCollectionView (collectionView, performDropWith: coordinator, to: destinationIndexPath)
     }
    case .copy:
      copyPhotosFromSideApp (collectionView, performDropWith: coordinator, to: destinationIndexPath)
    
    default: return
   }
  
 } //func collectionView(_ collectionView: UICollectionView, performDropWith...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:-------------------------------- DROP SESSION EXIT DELEGATE METHOD ---------------------------------
//---------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession)
 {
  //self.navigationController?.popViewController(animated: true)
    
 }//func collectionView(_ collectionView: UICollectionView, dropSessionDidExit ...
//---------------------------------------------------------------------------------------------------------
//MARK: -
 
    
    
//---------------------------------------------------------------------------------------------------------
}//extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate...
//---------------------------------------------------------------------------------------------------------
//MARK: -
//MARK: -
