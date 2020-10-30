
class SingleCellZoomViewDropDelegate: SingleCellDropViewDelegate
{
 weak var zoomView: ZoomView?
 
 override var hosted: PhotoItemProtocol? { zoomView?.zoomedPhotoItem }
 
 init(owner: ZoomView)
 {
  
  let zoomedCell = owner.zoomedPhotoItem?.hostingCollectionViewCell as? PhotoSnippetCell
  self.zoomView = owner
  super.init(ownerCell: zoomedCell)
 }
 

}
