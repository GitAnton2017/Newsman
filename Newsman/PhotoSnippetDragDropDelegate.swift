
import Foundation
import CoreData
import UIKit


extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView,
                          itemsForBeginning session: UIDragSession,
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
   
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
    {
        
    }
  
    func collectionView(_ collectionView: UICollectionView,
                          dropSessionDidUpdate session: UIDropSession,
                          withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
      return UICollectionViewDropProposal(operation: .move)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
     if let destinationIndexPath = coordinator.destinationIndexPath
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
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession)
    {
      self.navigationController?.popViewController(animated: true)
    
    }
    
    /*func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem]
    
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCell,
           let image = cell.photoIconView.image,
           collectionView.indexPathsForVisibleItems.first(where: {$0 == indexPath}) == nil,
           photoItems2D[indexPath.section][indexPath.row].photo.isSelected
           
        {
            let itemProvider = NSItemProvider(object: image)
            return [UIDragItem(itemProvider: itemProvider)]
        }
        else
        {
            return []
        }
    }*/
}
