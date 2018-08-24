
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
                       willDisplay cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  
//  if isHidden || photoItems.isEmpty {return}
  
  let photoItem = photoItems[indexPath.row]
  
  photoItem.getImageOperation(requiredImageWidth:  imageSize)
  {[weak self] (image) in
   
   guard let dataSource = self,
         let ip = dataSource.photoItemIndexPath(photoItem: photoItem),
         let cell = collectionView.cellForItem(at: ip) as? PhotoFolderCollectionViewCell else {return}
   
   cell.spinner.stopAnimating()
   
   UIView.transition(with: cell.photoIconView, duration: 0.5,
                     options: [.transitionCrossDissolve,.curveEaseInOut],
                     animations: {cell.photoIconView.image = image},
                     completion:
                     {_ in
                      if (photoItem.type == .video)
                      {
                       cell.showPlayIcon(iconColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.65))
                       cell.showVideoDuration(textColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), duration: AVURLAsset(url: photoItem.url).duration)
                      }
                      
                      cell.photoItemView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                      UIView.animate(withDuration: 0.25, delay: 0.03,
                                     usingSpringWithDamping: 3000,
                                     initialSpringVelocity: 0,
                                     options: [.curveEaseInOut],
                                     animations: {cell.photoItemView.transform = .identity},
                                     completion:
                                     { _ in
                                      
                                      dataSource.groupTaskCount += 1
                                      
                                      if (dataSource.groupTaskCount == collectionView.visibleCells.count)
                                      {
                                       dataSource.groupTaskCount = 0
                                       if let flag = dataSource.photoFolder?.priorityFlag,
                                          let color = PhotoPriorityFlags(rawValue: flag)?.color
                                       {
                                        self!.drawFlagMarker(flagColor: color)
                                       }
                                       else
                                       {
                                        self!.clearFlagMarker()
                                       }
                                      }
                                     })
                    })
  }
   
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  if isHidden {return}
  let photoItem = photoItems[indexPath.row]
  photoItem.cQ.cancelAllOperations()
 }
 
}
