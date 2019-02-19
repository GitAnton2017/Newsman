
import UIKit

class SingleCellZoomViewDropDelegate: SingleCellDropViewDelegate
{
 weak var zoomView: ZoomView?
 
 override var photoSnippetVC: PhotoSnippetViewController?
 {
  return zoomView?.photoSnippetVC
 }
 
 override var hosted: PhotoItemProtocol?
 {
  return zoomView?.zoomedPhotoItem
 }
 
 init(owner: ZoomView)
 {
  
  let cell = owner.zoomedPhotoItem?.hostingCollectionViewCell as? PhotoSnippetCell
  self.zoomView = owner
  super.init(owner: cell)
 }
 
 override func updateMergedCell()
 {
  
  guard let vc = photoSnippetVC else { return }
  guard let cv = vc.photoCollectionView else { return }
  
  guard let newMergedFolder = (zoomView?.zoomedPhotoItem as? PhotoItem)?.folder else { return }
  
  let newFolderItem = PhotoFolderItem(folder: newMergedFolder)
  
  defer { zoomView?.zoomedPhotoItem = newFolderItem }
  
  let zoomCV = zoomView?.openWithCV(in: vc.view)
  zoomView?.photoItems = newFolderItem.singlePhotoItems
  zoomCV?.reloadData()
  
  guard let hostedItem = self.hosted else { return }
  guard let indexPath = photoSnippetVC?.photoItemIndexPath(photoItem: hostedItem) else { return }
  vc.photoItems2D[indexPath.section][indexPath.row] = newFolderItem
  cv.reloadItems(at: [indexPath])

  
 }
 
}
