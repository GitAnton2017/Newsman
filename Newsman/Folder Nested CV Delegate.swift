
import Foundation
import UIKit
import AVKit

extension PhotoFolderCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
 {
  CGSize(width: imageSize, height: imageSize)
 }
 
 
 func collectionView(_ collectionView: UICollectionView,
                     willDisplay cell: UICollectionViewCell,
                     forItemAt indexPath: IndexPath)
 {
  guard let nestedPhotoCell = cell as? PhotoFolderCollectionViewCell else { return }
  
  nestedPhotoCell.refreshCellView()
  
  if nestedPhotoCell.hostedItem?.isArrowMenuShowing ?? false
  {
   nestedPhotoCell.showArrowMenu(animated: false)
  }
  else
  {
   collectionView.sendSubviewToBack(nestedPhotoCell as UIView)
  }
 
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  guard let nestedPhotoCell = cell as? PhotoFolderCollectionViewCell else { return }
  nestedPhotoCell.clearMainView()
  nestedPhotoCell.cancelImageOperations()
  nestedPhotoCell.hostedItem?.isArrowMenuShowing = false
 }
 
 func toggleCellSelection(_ collectionView: UICollectionView, at indexPath: IndexPath)
 {
  guard let vc = photoSnippetVC else { return }
  guard vc.isEditingPhotos else { return }
  photoItems[indexPath.row].toggleSelection()
 }
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
 {
  toggleCellSelection(collectionView, at: indexPath)
 }
 
 func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
 {
  toggleCellSelection(collectionView, at: indexPath)
 }
 
}
