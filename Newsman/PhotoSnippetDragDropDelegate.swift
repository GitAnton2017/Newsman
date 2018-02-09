
import Foundation
import CoreData
import UIKit


extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath) -> [UIDragItem]
    {
    
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCell, let image = cell.photoIconView.image
        {
    
            let itemProvider = NSItemProvider(object: image)
            if isInvisiblePhotosDraged
            {
             if !cell.isSelected
             {
                photoItems2D[indexPath.section][indexPath.row].photo.isSelected = true
             }
             return [UIDragItem(itemProvider: itemProvider)]
                
            }
            else
            {
              isInvisiblePhotosDraged = true
              var dragItems = [UIDragItem(itemProvider: itemProvider)]
              for item in photoItems2D.reduce([], {$0 + $1.filter({$0.photo.isSelected})})
              {
                let itemIndexPath = photoItemIndexPath(photoItem: item)
                guard itemIndexPath != indexPath else {continue}
                if collectionView.indexPathsForVisibleItems.first(where: {$0 == itemIndexPath}) == nil ||
                   collectionView.indexPathsForSelectedItems?.first(where: {$0 == itemIndexPath}) == nil
                {
                  let itemProvider = NSItemProvider(object: UIImage(named: "photo.main")!)
                  let dragItem = UIDragItem(itemProvider: itemProvider)
                  dragItem.localObject = itemIndexPath
                    
                  dragItems.append(dragItem)
                  
                }
              }
                
              if !cell.isSelected
              {
                photoItems2D[indexPath.section][indexPath.row].photo.isSelected = true
              }
              return dragItems
            }
        }
        else
        {
          return []
        }

    }
   
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
        
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCell, let image = cell.photoIconView.image
        {
            let itemProvider = NSItemProvider(object: image)
            
            if !cell.isSelected
            {
                photoItems2D[indexPath.section][indexPath.row].photo.isSelected = true
            }
            
            return [UIDragItem(itemProvider: itemProvider)]
        }
        else
        {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
    {
     session.localContext = self
    }
  
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
    }
    
    func movePhotosInsideCollectionView (_ collectionView: UICollectionView,
                                           performDropWith coordinator: UICollectionViewDropCoordinator,
                                           to destinationIndexPath: IndexPath)
    {
      isInvisiblePhotosDraged = false
      var dropPhotoItems = [(PhotoItem, UICollectionViewDropItem)]()
      for dropItem in coordinator.items
      {
       if let indexPath = dropItem.dragItem.localObject as? IndexPath
       {
        let photoItem = photoItems2D[indexPath.section][indexPath.row]
        dropPhotoItems.append((photoItem, dropItem))
       }
       else if let indexPath = dropItem.sourceIndexPath
       {
        let photoItem = photoItems2D[indexPath.section][indexPath.row]
        dropPhotoItems.append((photoItem, dropItem))
       }
      }
      
      dropPhotoItems.forEach
      {
        $0.0.photo.isSelected = false
        let sourceIndexPath = photoItemIndexPath(photoItem: $0.0)
        (collectionView as! PhotoSnippetCollectionView).movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
                
        coordinator.drop($0.1.dragItem, toItemAt: destinationIndexPath)
      }
    }
    
    func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                                 performDropWith coordinator: UICollectionViewDropCoordinator,
                                 to destinationIndexPath: IndexPath)
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
    }
    
    func movePhotosBetweenCollectionViews (_ collectionView: UICollectionView,
                                             from dragSessionVC: PhotoSnippetViewController,
                                             performDropWith coordinator: UICollectionViewDropCoordinator,
                                             to destinationIndexPath: IndexPath)
    {
      if dragSessionVC.photoSnippet === photoSnippet
      {
       dragSessionVC.photoItems2D.reduce([], {$0 + $1.filter({$0.photo.isSelected})}).forEach
       {
        let sourceIndexPath = photoIdentityItemIndexPath(photoItem: $0)
        $0.photo.isSelected = false
        (collectionView as! PhotoSnippetCollectionView).movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    
       }
      }
      else
      {
        
        let movedPhotoItems = PhotoItem.movePhotos(from: dragSessionVC.photoSnippet, to: photoSnippet)
        
        movedPhotoItems?.forEach
        {
         photoItems2D[destinationIndexPath.section].insert($0, at: destinationIndexPath.row)
         if photoCollectionView.photoGroupType == .makeGroups
         {
          $0.photo.priorityFlag = sectionTitles?[destinationIndexPath.section]
         }
         (collectionView as! PhotoSnippetCollectionView).insertItems(at: [destinationIndexPath])
        }
        
        
      }
    
      coordinator.session.items.forEach{coordinator.drop($0, toItemAt: destinationIndexPath)}
    
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
     
      let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
      switch (coordinator.proposal.operation)
      {
       case .move:
        if let dragSessionVC = coordinator.session.localDragSession?.localContext as? PhotoSnippetViewController,
               dragSessionVC !== self
        {
         movePhotosBetweenCollectionViews (collectionView, from: dragSessionVC, performDropWith: coordinator, to: destinationIndexPath)
            
         coordinator.session.localDragSession?.localContext = nil
        }
        else
        {
         movePhotosInsideCollectionView (collectionView, performDropWith: coordinator, to: destinationIndexPath)
        }
       case .copy: copyPhotosFromSideApp (collectionView, performDropWith: coordinator, to: destinationIndexPath)
       default: return
      }
     
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession)
    {
      //self.navigationController?.popViewController(animated: true)
    }
    
    
}
