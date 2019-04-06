import UIKit

class PhotoFolderCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
 
 private lazy var dropper: UIDropInteraction? =
 {
  guard let dropDelegate = self.owner?.dropDelegate else { return nil }
  let dropper = UIDropInteraction(delegate: dropDelegate)
  hostedView.addInteraction(dropper)
  return dropper
 }()
 
 
 var hostedViewSelectedAlpha: CGFloat = 0.5
 
 weak var owner: PhotoFolderCell? // weak ref to FolderCell which hosts he nested CV.
 {
  didSet
  {
   guard dropper != nil else { return }
   hostedView.isUserInteractionEnabled = owner!.isDraggable
  }
 }
 
 var hostedView: UIView { return photoIconView }
 var hostedAccessoryView: UIView? { return spinner }
 
 weak var hostedItem: PhotoItemProtocol?
 //The sigle PhotoItem wrapper instance that is currently hosted and visualized by this type of UICollectionViewCell...
 {
  didSet
  {
   guard let hosted = self.hostedItem as? PhotoItem else { return }
  
   
   self.updateImage()
   
   hosted.hostingCollectionViewCell = self
   //weak reference to this cell that will display this PhotoItem until updated and dequed in nested CV!
   
   photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   self.isDragAnimating = hosted.isDragAnimating
   //if cell drag waggle animation deleted and hosted item is in selected state recover animation...
   
   //updateDraggableHostingCell()
   /* when dragging photo items around the dragged items ([Draggables]) hosting cells (hostingCollectionViewCell weak item
    property) may change due to cells updates in CVs so we have to update references to the dragged animated cells to
    animate drag clearances with the proper cells in "Draggable.clear(...)" method!  */
   
 
  }
  
 }//weak var hostedItem: PhotoItemProtocol?...
 
 func cancelImageOperations()
 {
  hostedItem?.cancelImageOperations()
 }
 
 var photoItemView: UIView {return self.contentView}
 
 var cellFrame: CGRect     {return self.frame}
 
 private var _selected = false
 var isPhotoItemSelected: Bool
 {
  set
  {
   _selected = newValue
   photoIconView.alpha = newValue ? hostedViewSelectedAlpha : 1
   touchSpring()
  }
  
  get {return _selected}
 }
 
 @IBOutlet weak var photoIconView: UIImageView!
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 
 override func awakeFromNib()
 {
  super.awakeFromNib()

  
  spinner.startAnimating()
  self.hostedItem = nil
  photoIconView.image = nil
  imageRoundClip(cornerRadius: 5)
 }
 
 override func prepareForReuse()
 {
  super.prepareForReuse()
  self.hostedItem = nil
  spinner.startAnimating()
  photoIconView.image = nil
  imageRoundClip(cornerRadius: 5)
 }
 
 
 
 
}
