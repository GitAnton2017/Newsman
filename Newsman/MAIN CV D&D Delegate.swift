
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
 func getDragItems (_ collectionView: UICollectionView, forCellAt indexPath: IndexPath) -> [UIDragItem]
//-------------------------------------------------------------------------------------------------------
 {
  if collectionView.cellForItem(at: indexPath) != nil
  {
    let photoItem = photoItems2D[indexPath.section][indexPath.row]
    photoItem.isSelected = true
    let itemProvider = NSItemProvider(object: photoItem)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = photoItem
    return [dragItem]
  }
  else
  {
    return []
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
  return getDragItems(collectionView, forCellAt: indexPath)
 }//func collectionView(_ collectionView: UICollectionView, itemsForBeginning...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
 {
   deselectSelectedItems(in: collectionView)
 }
 
 func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
 {
  deselectSelectedItems(in: collectionView)
 }
    
//MARK:----------------- ADDING DRAG ITEMS TO CURRENT DRAG SESSION DELEGATE METHOD ----------------------
//-------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,
                       itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//-------------------------------------------------------------------------------------------------------
 {
  return getDragItems(collectionView, forCellAt: indexPath)
 }//func collectionView(_ collectionView: UICollectionView,itemsForAddingTo...
//-------------------------------------------------------------------------------------------------------
//MARK: -

    
//MARK:----------------------------- DROPPING PROPOSAL DELEGATE METHOD ----------------------------------
//-------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate session: UIDropSession,
                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
    
  if session.localDragSession != nil
  {
    
    if destinationIndexPath == nil
    {
      guard let dragSessionVC = session.localDragSession?.localContext as? PhotoSnippetViewController, dragSessionVC !== self
      else
      {
        return UICollectionViewDropProposal(operation: .cancel)
      }
        
    }
  
    
    if session.items.count == 1
    {
      return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
  }
  else
  {
   return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
  }
 }//func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate...
//-------------------------------------------------------------------------------------------------------
//MARK: -
    
    func performMergeIntoFolder (_ collectionView: PhotoSnippetCollectionView,
                                   from photoItems: [PhotoItemProtocol],
                                   into destinationIndexPath: IndexPath) -> PhotoFolderItem?
    {
        if let newFolder = PhotoFolderItem(photoSnippet: photoSnippet)
        {
            newFolder.priorityFlag = sectionTitles?[destinationIndexPath.section]
            photoItems.forEach
            {photoItem in
               let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
               photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
               collectionView.deleteItems(at: [sourceIndexPath])
               
               if (collectionView.photoGroupType == .makeGroups && sourceIndexPath.section != destinationIndexPath.section)
               {
                collectionView.reloadSections([sourceIndexPath.section])
               }
               
            }//photoItems.forEach...
            
            let sectionCnt = photoItems2D[destinationIndexPath.section].count
            if  (destinationIndexPath.row < sectionCnt)
            {
                photoItems2D[destinationIndexPath.section].insert(newFolder, at: destinationIndexPath.row)
                collectionView.insertItems(at: [destinationIndexPath])
            }
            else
            {
                photoItems2D[destinationIndexPath.section].append(newFolder)
                let indexPath = IndexPath(row: sectionCnt, section: destinationIndexPath.section)
                collectionView.insertItems(at: [indexPath])
            }
            
            if (collectionView.photoGroupType == .makeGroups)
            {
                collectionView.reloadSections([destinationIndexPath.section])
            }
            
            deleteEmptySections()
            
            PhotoFolderItem.removeEmptyFolders(from: photoSnippet)
            
            return newFolder
        }
        
        return nil
    }
    
//MARK:---------------------- MERGING DRAGED PHOTO ITEMS INTO PHOTO FOLDER --------------------------------
//---------------------------------------------------------------------------------------------------------
 func performMergeIntoFolder (_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {
    
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
  let photoItems = coordinator.items.filter{$0.sourceIndexPath != nil}.map
      {photoItems2D[$0.sourceIndexPath!.section][$0.sourceIndexPath!.row]}
    
  let photoSnippetCV = collectionView as! PhotoSnippetCollectionView
  _ = performMergeIntoFolder(photoSnippetCV, from: photoItems, into: destinationIndexPath)
    
  
  coordinator.items.forEach
  {
     if let dropCellRect = collectionView.cellForItem(at: destinationIndexPath)?.bounds
     {
         coordinator.drop($0.dragItem, intoItemAt: destinationIndexPath, rect: dropCellRect)
     }
  }
    

 }//func performMergeIntoFolder (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:------------------------- MOVE OF DRAGED PHOTO ITEMS TO DESTINATION IP -----------------------------
//---------------------------------------------------------------------------------------------------------
 func performItemsMove (_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {

   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
    coordinator.items.filter{$0.sourceIndexPath != nil}.map
    {photoItems2D[$0.sourceIndexPath!.section][$0.sourceIndexPath!.row]}.forEach
    {photoItem in
      let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
      let photoCV = collectionView as! PhotoSnippetCollectionView
      photoCV.movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    

    }
    
    coordinator.items.forEach{coordinator.drop($0.dragItem, toItemAt: destinationIndexPath)}
    
    
   
 }//func performItemsMove (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
  

    
//MARK:------------------ MOVING DRAGED PHOTO ITEMS INSIDE CV ---------------------------------------------
//---------------------------------------------------------------------------------------------------------
 func movePhotosInsideCV (_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {

   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
   let dropItems = coordinator.items.filter{$0.sourceIndexPath != nil}

   if (dropItems.first{$0.sourceIndexPath! == destinationIndexPath} != nil && dropItems.count > 1)
   {
    performMergeIntoFolder(collectionView, performDropWith: coordinator)
   }
   else
   {
    performItemsMove(collectionView, performDropWith: coordinator)
   }
 }//func movePhotosInsideCollectionView (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:-------------------------- MOVING DRAGED PHOTO FROM ANOTHER APP ------------------------------------
//---------------------------------------------------------------------------------------------------------
 func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                              performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {
    
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
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
  session.localContext = self //getting strong reference to the current VC with current CV...
 }//func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
   
    
//MARK:----------------------- MOVING DRAGED PHOTO ITEMS BETWEEN CVs --------------------------------------
//---------------------------------------------------------------------------------------------------------
 func movePhotosBetweenCVs (_ collectionView: UICollectionView, from dragSessionVC: PhotoSnippetViewController,
                              performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {
    
   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
   if dragSessionVC.photoSnippet === photoSnippet
   {
    dragSessionVC.photoItems2D.reduce([], {$0 + $1.filter({$0.isSelected})}).forEach
    {movedItem in
     let sourceIndexPath = photoItemIndexPath(photoItem: movedItem)
     let photoCV = collectionView as! PhotoSnippetCollectionView
     photoCV.movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
 
    }
   }
   else
   {
    let movedPhotoItems: [PhotoItemProtocol] = PhotoItem.movePhotos(from: dragSessionVC.photoSnippet, to: photoSnippet) ?? []
    let movedFolderItems: [PhotoItemProtocol] = PhotoItem.moveFolders(from: dragSessionVC.photoSnippet, to: photoSnippet) ?? []
    
    (movedPhotoItems + movedFolderItems).forEach
    { movedItem in
      photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
      if photoCollectionView.photoGroupType == .makeGroups
      {
       movedItem.priorityFlag = sectionTitles?[destinationIndexPath.section]
      }
      (collectionView as! PhotoSnippetCollectionView).insertItems(at: [destinationIndexPath])
    }
   }
 
   coordinator.items.forEach{coordinator.drop($0.dragItem, toItemAt: destinationIndexPath)}
 
 }//func movePhotosBetweenCollectionViews (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
    
//MARK:-------------------------------- PERFORM DROP DELEGATE METHOD --------------------------------------
//---------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//---------------------------------------------------------------------------------------------------------
 {
   switch (coordinator.proposal.operation)
   {
    case .move:
     if let dragSessionVC = coordinator.session.localDragSession?.localContext as? PhotoSnippetViewController, dragSessionVC !== self
     {
      movePhotosBetweenCVs (collectionView, from: dragSessionVC, performDropWith: coordinator)
      coordinator.session.localDragSession?.localContext = nil
     }
     else
     {
      movePhotosInsideCV (collectionView, performDropWith: coordinator)
     }
    
    case .copy:
      copyPhotosFromSideApp (collectionView, performDropWith: coordinator)
    
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
