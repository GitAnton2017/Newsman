
import Foundation
import UIKit

class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
 func updateDraggableHostingCell()
 {
  AppDelegate.globalDragDropItems.compactMap{$0 as? PhotoItem}
             .first{$0 == hostedItem}?
             .hostingZoomedCollectionViewCell = self
 }
 
 
 var hostedViewSelectedAlpha: CGFloat = 0.5
 
 var hostedView: UIView {return photoIconView}
 var hostedAccessoryView: UIView? {return spinner}
 
 @IBOutlet weak var photoIconView: UIImageView!
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 
 weak var hostedItem: PhotoItemProtocol?
 {
  didSet
  {
   guard let hosted = self.hostedItem as? PhotoItem else {return}
   
   updateImage()
   
   hosted.hostingZoomedCollectionViewCell = self
   
   self.photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   self.isDragAnimating = hosted.isDragAnimating
   
   //updateDraggableHostingCell()
  }
  
 }//weak var hostedItem: PhotoItemProtocol?...

 func cancelImageOperations()
 {
  hostedItem?.cancelImageOperations()
 }

 var photoItemView: UIView {return self.contentView}

 var cellFrame: CGRect {return self.frame}

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

 
 override func awakeFromNib()
 {
     super.awakeFromNib()
     self.hostedItem = nil
     spinner.startAnimating()
     photoIconView.image = nil
     imageRoundClip(cornerRadius: 10)

 }
 
 override func prepareForReuse()
 {
     super.prepareForReuse()
     self.hostedItem = nil
     spinner.startAnimating()
     photoIconView.image = nil
     imageRoundClip(cornerRadius: 10)
 }
}//class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol...
