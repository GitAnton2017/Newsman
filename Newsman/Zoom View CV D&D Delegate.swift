

import Foundation
import CoreData
import UIKit


//MARK: -

//MARK: =============================== CV ITEMS DRAG AND DROP DELEGATE =================================
extension ZoomView: UICollectionViewDragDelegate, UICollectionViewDropDelegate
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
            let photoItem = photoItems[indexPath.row]
            photoItem.isSelected = true
            let itemProvider = NSItemProvider(object: photoItem)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = photoItem
            hasNoDraggedSubviews = false
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
        //deselectSelectedItems(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
    {
        //deselectSelectedItems(in: collectionView)
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
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        else
        {
            return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
        }
    }//func collectionView(_ collectionView: UICollectionView,dropSessionDidUpdate...
    //-------------------------------------------------------------------------------------------------------
    //MARK: -
    
    func movePhotoItemsInsideVC (_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        for dropItem in coordinator.items
        {
          if let sourceIndexPath = dropItem.sourceIndexPath
          {
            let photoItem = photoItems[sourceIndexPath.row]
            let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
            let moved = photoItems.remove(at: sourceIndexPath.row)
            photoItems.insert(moved, at: destinationIndexPath.row)
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
          }
          
        }
       
        /*let selected = photoSnippetVC.photoItems2D.reduce([], {$0 + $1.filter({$0.isSelected})})
        photoSnippetVC.performMergeIntoFolder(photoSnippetVC.photoCollectionView, from: selected, into: zoomedCellIndexPath)
        let newFolderCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedCellIndexPath) as! PhotoFolderCell
        photoItems = newFolderCell.photoItems*/
        
    }
    
    
    //MARK:------------------------- MOVE OF DRAGED PHOTO ITEMS TO DESTINATION IP -----------------------------
    //---------------------------------------------------------------------------------------------------------
    func performItemsMove (_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    //---------------------------------------------------------------------------------------------------------
    {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        coordinator.items.filter{$0.sourceIndexPath != nil}.map
        {photoItems[$0.sourceIndexPath!.row]}.forEach
        {item in

           let sourceIndexPath = photoItemIndexPath(photoItem: item)
           let moved = photoItems.remove(at: sourceIndexPath.row)
           photoItems.insert(moved, at: destinationIndexPath.row)
           collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
           
        }
        
        coordinator.items.forEach{coordinator.drop($0.dragItem, toItemAt: destinationIndexPath)}
        
    
    }//func performItemsMove (_ collectionView: UICollectionView...
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
            let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "ZoomCollectionViewCell")
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
        
       /* let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
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
        
        coordinator.items.forEach{coordinator.drop($0.dragItem, toItemAt: destinationIndexPath)}*/
        
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
    
            //performItemsMove(collectionView, performDropWith: coordinator)
            movePhotoItemsInsideVC (collectionView, performDropWith: coordinator)
            
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
