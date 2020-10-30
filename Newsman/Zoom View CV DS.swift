
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
 
 func collectionView(_ collectionView: UICollectionView,
                     cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 {
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomCollectionViewCell",
                                                for: indexPath) as! ZoomViewCollectionViewCell

  let photoItem = photoItems?[indexPath.row]
  cell.zoomView = self
  cell.photoSnippetVC = self.photoSnippetVC
  cell.photoSnippet = self.photoSnippetVC.photoSnippet
  cell.hostedItem = photoItem
  cell.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
  
  if ( collectionView.hasActiveDrag || collectionView.hasActiveDrop ) {
   collectionView.subviews.compactMap{ $0 as? ZoomViewCollectionViewCell }
    .filter{ $0 !== cell && $0.hostedItem === photoItem && $0.frame == cell.frame }
    .forEach{ $0.removeFromSuperview() }
  }
  
  return cell
 }
 

 
}
