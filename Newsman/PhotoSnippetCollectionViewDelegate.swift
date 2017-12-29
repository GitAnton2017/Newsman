
import Foundation
import UIKit

extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    

    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize
    {
      return CGSize(width: imageSize, height: imageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
      if isEditingPhotos
      {
        if (!photoItems[indexPath.row].photo.isSelected)
        {
         print ("SELECT NOT SELECTED")
         (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 0.5
         photoItems[indexPath.row].photo.isSelected = true
         allPhotosSelected = true
         selectBarButton.title = "☆☆☆"
        }
        else
        {
         print ("SELECT SELECTED")
         (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
          photoItems[indexPath.row].photo.isSelected = false
          
          if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
          {
           selectBarButton.title = "★★★"
          }
        }
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
      if isEditingPhotos
      {
        if (photoItems[indexPath.row].photo.isSelected)
        {
         print ("DESELECT SELECTED")
         (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
         photoItems[indexPath.row].photo.isSelected = false
         if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
         {
          selectBarButton.title = "★★★"
         }
        }
        else
        {
          print ("DESELECT DESELECTED")
          (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 0.5
          photoItems[indexPath.row].photo.isSelected = true
          allPhotosSelected = true
          selectBarButton.title = "☆☆☆"
        }
      }
    }
}
