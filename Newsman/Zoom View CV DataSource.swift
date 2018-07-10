
import Foundation
import UIKit
import AVKit

extension ZoomView:  UICollectionViewDataSource
{
 
    var imageSize: CGFloat
    {
        let w = self.bounds.width
        let cv = self.subviews.first as! UICollectionView
        let fl = cv.collectionViewLayout as! UICollectionViewFlowLayout
        let li = fl.sectionInset.left
        let ri = fl.sectionInset.right
        let s = fl.minimumInteritemSpacing
        
        let size = (w - li - ri - s * CGFloat(nphoto - 1)) / CGFloat(nphoto)
        
        return trunc(size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
  
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomCollectionViewCell", for: indexPath) as! ZoomViewCollectionViewCell
        
        let photoItem = photoItems[indexPath.row]
     
        cell.photoIconView.layer.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
     
        if (photoItem.type == .video)
        {
          cell.showPlayIcon(iconColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.65))
          cell.drawVideoDuration(textColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), duration: AVURLAsset(url: photoItem.url).duration)
        }
        
        photoItem.getImage(requiredImageWidth:  imageSize)
        {(image) in
        
         cell.spinner.stopAnimating()
         
         UIView.transition(with: cell.photoIconView,
                           duration: 0.75,
                           options: .transitionCrossDissolve,
                           animations: {cell.photoIconView.image = image},
                           completion:
                           {_ in
                            cell.photoIconView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                            UIView.animate(withDuration: 0.15,
                                           delay: 0,
                                           usingSpringWithDamping: 2500,
                                           initialSpringVelocity: 0,
                                           options: .curveEaseInOut,
                                           animations: {cell.photoIconView.transform = .identity},
                                           completion: nil)
                           })
        }
     
        if globalDragItems.contains(where: {item in
         if let dragPhotoItem = item as? PhotoItem, photoItem.id == dragPhotoItem.id {return true}
         return false})
        {
         PhotoSnippetViewController.startCellDragAnimation(cell: cell)
        }
        
        return cell
    }
    

    func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath?
    {
     guard let photoItems = photoItems,
      let path = photoItems.enumerated().lazy.first(where: {$0.element.id == photoItem.id})
      else {return nil}
     return IndexPath(row: path.offset, section: 0)
    }
    
}
