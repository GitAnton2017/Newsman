
import Foundation
import UIKit

extension PhotoSnippetViewController: UICollectionViewDelegate
{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
      if isEditingPhotos
      {
        (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 0.5
        allPhotosSelected = true
        selectBarButton.title = "Unselect"
      }
      else
      {
        
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
      if isEditingPhotos
      {
        (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
      }
    }
}
