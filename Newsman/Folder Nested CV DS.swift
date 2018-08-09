
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
  // print ("LOADING FOLDER CELL WITH IP - \(indexPath)")
  // print ("VISIBLE CELLS: \(collectionView.visibleCells.count)")
  
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCollectionViewCell", for: indexPath) as! PhotoFolderCollectionViewCell
  
  let photoItem = photoItems[indexPath.row]
  
  cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
  
  cell.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
 
  photoItem.getImage(requiredImageWidth:  imageSize)
  {(image) in
   
   cell.spinner.stopAnimating()
   
   UIView.transition(with: cell.photoIconView, duration: 0.5, options: [.transitionCrossDissolve,.curveEaseInOut],
                     animations: {cell.photoIconView.image = image},
                     completion:
                     {_ in
                      if (photoItem.type == .video)
                      {
                       cell.showPlayIcon(iconColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.65))
                       cell.showVideoDuration(textColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), duration: AVURLAsset(url: photoItem.url).duration)
                      }
                      
                      cell.photoItemView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                      UIView.animate(withDuration: 0.25, delay: 0.03, usingSpringWithDamping: 3000, initialSpringVelocity: 0,
                                     options: [.curveEaseInOut],
                                     animations: {cell.photoItemView.transform = .identity},
                                     completion:
                                     {[weak self] _ in
                                      guard self != nil else {return}
                                      
                                      self!.groupTaskCount += 1
                                      
                                      if (self!.groupTaskCount == collectionView.visibleCells.count)
                                      {
                                       self!.groupTaskCount = 0
                                       if let flag = self!.photoFolder?.priorityFlag,
                                          let color = PhotoPriorityFlags(rawValue: flag)?.color
                                       {
                                        self!.drawFlagMarker(flagColor: color)
                                       }
                                       else
                                       {
                                        self!.clearFlagMarker()
                                       }
                                      }
                                     }
                      )
   })
  }
  
  
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