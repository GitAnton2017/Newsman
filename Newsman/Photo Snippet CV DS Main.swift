
import UIKit

extension PhotoSnippetViewController: UICollectionViewDataSource
{
 
 func numberOfSections(in collectionView: UICollectionView) -> Int
 {
  photoItems2D.count
 }
    
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
 {
  photoItems2D[section].count //the size of each vector in 2D model array...
 }

 
 final var cellCornerRadius: CGFloat { ceil(10 * (1 - 1/exp(CGFloat(11 - photosInRow) / 4))) }
 final var folderCellPhotosInRow: Int { nPhotoFolderMap[photosInRow]! }
 
 func getPhotoCell (_ collectionView: UICollectionView,
                      at indexPath: IndexPath,
                      with photoItem: PhotoItem) -> PhotoSnippetCell
  
 {
  
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell",
                                                for: indexPath) as! PhotoSnippetCell
  
  //print (#function, indexPath, cell.frame)
  
 
  cell.photoSnippetVC = self
  cell.photoSnippet = self.photoSnippet //weak ref must be initialized prior to call of hostedItem observer!!
  cell.hostedItem = photoItem
  cell.cornerRadius = cellCornerRadius
  return cell
    
 }
 
 
 
 func getFolderCell (_ collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with photoFolder: PhotoFolderItem) -> PhotoFolderCell

 {
  
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCell",
                                                for: indexPath) as! PhotoFolderCell
  
  //print (#function, indexPath, cell.frame)
 
  cell.photoSnippetVC = self
  cell.photoSnippet = self.photoSnippet //weak ref must be initialized prior to call of hostedItem observer!
  cell.hostedItem = photoFolder
  cell.photoCollectionView.isUserInteractionEnabled = !isEditingPhotos
  cell.cornerRadius = cellCornerRadius
  cell.nphoto = folderCellPhotosInRow
  cell.frameSize = imageSize
 

  return cell
    
 }
 
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell

 {
  
  
  var cell: UICollectionViewCell!
  
  let photoItem = photoItems2D[indexPath.section][indexPath.row]
 
  switch (photoItem)
  {
   case let item as PhotoItem:
    cell = getPhotoCell  (collectionView, at: indexPath, with: item)
   
   case let item as PhotoFolderItem:
    cell = getFolderCell (collectionView, at: indexPath, with: item)
   
   default: break
  }
 
  let cellInter = UISpringLoadedInteraction { [unowned self] inter, context in
   self.photoCollectionView.zoomView = self.photoCollectionView.cellSpringInt(context)
  }
   
  cell.addInteraction(cellInter)
  
  if ( collectionView.hasActiveDrag || collectionView.hasActiveDrop ) {
   collectionView.subviews.compactMap{ $0 as? PhotoSnippetCellProtocol }
    .filter{ $0 !== cell && $0.hostedItem === photoItem && $0.frame == cell.frame }
    .forEach{ $0.removeFromSuperview() }
  }
  
  return cell
 }
 
}
