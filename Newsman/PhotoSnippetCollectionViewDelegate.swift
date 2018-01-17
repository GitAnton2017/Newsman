
import Foundation
import UIKit

extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if photoCollectionView.photoGroupType == .makeGroups //&& photoItems2D[section].count > 0
        {
            return CGSize(width: 0, height: 50)
        }
        else
        {
            
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize
    {
        if photoCollectionView.photoGroupType == .makeGroups //&& photoItems2D[section].count > 0
        {
            return CGSize(width: 0, height: 50)
        }
        else
        {
            return CGSize.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize
    {
      return CGSize(width: imageSize, height: imageSize)
    }
    
    
    func cellTouchAnimation(view: UIImageView)
    {
      let downAni = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn)
      {
       view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      }
        
      let upAni = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut)
      {
        view.transform = CGAffineTransform.identity
      }
      downAni.addCompletion
      {_ in
        upAni.startAnimation()
      }
     
      downAni.startAnimation()
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
      let iconView = (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView
      let photoItem = photoItems2D[indexPath.section][indexPath.row]
        
      cellTouchAnimation(view: iconView!)
        
      if isEditingPhotos
      {
        if (!photoItem.photo.isSelected)
        {
         print ("SELECT NOT SELECTED")
         iconView!.alpha = 0.5
         photoItem.photo.isSelected = true
         allPhotosSelected = true
         selectBarButton.title = "☆☆☆"
        }
        else
        {
         print ("SELECT SELECTED")
         iconView!.alpha = 1
         photoItem.photo.isSelected = false
          
          if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
          {
           selectBarButton.title = "★★★"
          }
        }
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
      let iconView = (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView
      let photoItem = photoItems2D[indexPath.section][indexPath.row]
        
      cellTouchAnimation(view: iconView!)
        
      if isEditingPhotos
      {
        if (photoItem.photo.isSelected)
        {
         print ("DESELECT SELECTED")
         iconView!.alpha = 1
         photoItem.photo.isSelected = false
         if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
         {
          selectBarButton.title = "★★★"
         }
        }
        else
        {
          print ("DESELECT DESELECTED")
          iconView!.alpha = 0.5
          photoItem.photo.isSelected = true
          allPhotosSelected = true
          selectBarButton.title = "☆☆☆"
        }
      }
    }
}
