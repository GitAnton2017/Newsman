
import Foundation
import CoreData
import UIKit


extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
    
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCell, let image = cell.photoIconView.image
        {
            let itemProvider = NSItemProvider(object: image)
            return [UIDragItem(itemProvider: itemProvider)]
        }
        else
        {
          return []
        }
    }
    
  
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
      return UICollectionViewDropProposal(operation: .move)  ////!!!!!!!!!???
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
     if let destinationIndexPath = coordinator.destinationIndexPath, let item = coordinator.items.first,
        let sourceIndexPath = item.sourceIndexPath
     {
      (collectionView as! PhotoSnippetCollectionView).movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
            
      coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
     
     }
        
        
    }
    
    
}
