
import Foundation
import UIKit

extension ZoomView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
 {
    return CGSize(width: imageSize, height: imageSize)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat
 {
     let fl = collectionViewLayout as! UICollectionViewFlowLayout
     let w = collectionView.bounds.width
     let li = fl.sectionInset.left
     let ri = fl.sectionInset.right
     let s  = fl.minimumInteritemSpacing
  
     let wr = (w - li - ri - s * CGFloat(nphoto - 1)).truncatingRemainder(dividingBy: CGFloat(nphoto)) / CGFloat(nphoto - 1)
  
     return s + wr
  
 }

 func collectionView(_ collectionView: UICollectionView,
                     willDisplay cell: UICollectionViewCell,
                     forItemAt indexPath: IndexPath)
 {
  guard let zoomedPhotoCell = cell as? ZoomViewCollectionViewCell else { return }
  
  zoomedPhotoCell.refreshCellView()
  
  if zoomedPhotoCell.hostedItem?.isArrowMenuShowing ?? false
  {
   zoomedPhotoCell.showArrowMenu(animated: false)
  }
  else
  {
   collectionView.sendSubviewToBack(zoomedPhotoCell as UIView)
  }
 
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  guard let zoomedPhotoCell = cell as? ZoomViewCollectionViewCell else { return }
  zoomedPhotoCell.clearMainView()
  zoomedPhotoCell.cancelImageOperations()
  zoomedPhotoCell.hostedItem?.isArrowMenuShowing = false
 }
 
 
 func toggleCellSelection(_ collectionView: UICollectionView, at indexPath: IndexPath)
 {
  guard let vc = photoSnippetVC else { return }
  guard vc.isEditingPhotos else {return}
  photoItems[indexPath.row].toggleSelection()
 }
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
 {
  toggleCellSelection(collectionView, at: indexPath)
 }
 

 
 
}
