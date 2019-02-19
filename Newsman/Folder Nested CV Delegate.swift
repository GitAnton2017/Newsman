
import Foundation
import UIKit
import AVKit

extension PhotoFolderCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
 {
  return CGSize(width: imageSize, height: imageSize)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  guard let nestedCell = cell as? PhotoFolderCollectionViewCell else { return }
  nestedCell.cancelImageOperations()
  //(nestedCell.hostedItem as? PhotoItem)?.hostingCollectionViewCell = nil
 }
 
}
