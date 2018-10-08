
import UIKit
import Foundation
import AVKit

extension PhotoFolderCell:  UICollectionViewDataSource
{
 var globalDragItems: [Any]
 {
  return (UIApplication.shared.delegate as! AppDelegate).globalDragItems
 }
 
 var imageSize: CGFloat
 {
  get
  {
   let width = frameSize
   //print ("width =\(width)" )
   let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
   let leftInset = fl.sectionInset.left
   let rightInset = fl.sectionInset.right
   let space = fl.minimumInteritemSpacing
   let size = (width - leftInset - rightInset - space * CGFloat(nphoto - 1)) / CGFloat(nphoto)
   return trunc(size)
  }
 }
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
 {
  return photoItems.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 {
  
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCollectionViewCell",
                                                for: indexPath) as! PhotoFolderCollectionViewCell
  
  let photoItem = photoItems[indexPath.row]
  
  cell.hostedPhotoItem = photoItem
  
  cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
  
  cell.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
 
  
  if globalDragItems.contains(where: {($0 as! PhotoItemProtocol).id == photoItem.id})
  {
   PhotoSnippetViewController.startCellDragAnimation(cell: cell)
  }
  
  return cell
 }
 
 func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath?
 {
  guard let path = photoItems.enumerated().lazy.first(where: {$0.element.id == photoItem.id}) else {return nil}
  return IndexPath(row: path.offset, section: 0)
 }
 
}
