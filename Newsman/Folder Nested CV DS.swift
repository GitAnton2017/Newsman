
import UIKit

extension PhotoFolderCell:  UICollectionViewDataSource
{
 
 var imageSize: CGFloat
 {
  let width = frameSize
  let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  let leftInset = fl.sectionInset.left
  let rightInset = fl.sectionInset.right
  let space = fl.minimumInteritemSpacing
  let size = (width - leftInset - rightInset - space * CGFloat(nphoto - 1)) / CGFloat(nphoto)
  return trunc(size)
 }//var imageSize: CGFloat...
 
 
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
 {
  return photoItems?.count ?? 0
 }//func collectionView(_ collectionView: UICollectionView...
 
 
 final var cellCornerRadius: CGFloat { ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5))) }
 
 func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 {
  
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCollectionViewCell",
                                                for: indexPath) as! PhotoFolderCollectionViewCell
  
  guard indexPath.row < (photoItems?.count ?? 0) else { return cell }
  guard let photoItem = photoItems?[indexPath.row] else { return cell }
  cell.hostedItem = photoItem
  cell.owner = self
  cell.photoSnippetVC = self.photoSnippetVC
  cell.photoSnippet = self.photoSnippetVC?.photoSnippet
  cell.cornerRadius = cellCornerRadius
  
  if ( collectionView.hasActiveDrag || collectionView.hasActiveDrop ) {
   collectionView.subviews.compactMap{ $0 as? PhotoFolderCollectionViewCell }
    .filter{ $0 !== cell && $0.hostedItem === photoItem && $0.frame == cell.frame }
    .forEach{ $0.removeFromSuperview() }
  }
  
  
  return cell
  
 }//func collectionView(_ collectionView: UICollectionView...
 

 
}//extension PhotoFolderCell
