
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
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  guard let zoomCell = cell as? ZoomViewCollectionViewCell else { return }
  zoomCell.cancelImageOperations()
  //(zoomCell.hostedItem as? PhotoItem)?.hostingZoomedCollectionViewCell = nil
 }
 
}
