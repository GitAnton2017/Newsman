import UIKit
import Foundation
import AVKit

class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol, PhotoItemsDraggable, DropViewProvidable
{
 
 lazy var dropView: UIView = self.setDropView()
 
 lazy var dropDelegate: UIDropInteractionDelegate =
 {
  let dropDelegate = SingleCellDropViewDelegate(owner: self)
  return dropDelegate
 }()
 

 var hostedView: UIView {return photoIconView}
 var hostedAccessoryView: UIView? {return spinner}

 weak var photoSnippet: PhotoSnippet!
 weak var photoSnippetVC: PhotoSnippetViewController!
 
 @IBOutlet weak var photoIconView: UIImageView!        //hosted photo UIImageView...
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 
 func cancelImageOperations()
 {
  hostedItem?.cancelImageOperations()
 }

 weak var hostedItem: PhotoItemProtocol?
 //The sigle PhotoItem that is currently hosted and visualized by this type of UICollectionViewCell...
 {
  didSet
  {
   guard let hosted = self.hostedItem as? PhotoItem else {return}
  
   updateImage()
   
   hosted.hostingCollectionViewCell = self
   //weak reference to this cell that will display this PhotoItem...
   
   photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   self.isDragAnimating = hosted.isDragAnimating //|| hosted.isDropAnimating

   //if cell drag waggle animation deleted and hosted item is in selected state recover animation...
  }
  
 }//weak var hostedItem: PhotoItemProtocol?...

 let hostedViewSelectedAlpha: CGFloat = 0.5
 
 
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
  _selected = false
  
  let dropper = UIDropInteraction(delegate: dropDelegate)
  dropper.allowsSimultaneousDropSessions = true
  dropView.addInteraction(dropper)
  
  spinner.startAnimating()
  photoIconView.image = nil
  photoIconView.alpha = 1
  clearFlagMarker()
  clearVideoDuration()
  hidePlayIcon()
  imageRoundClip(cornerRadius: 10)
  
 }
 
 override func prepareForReuse()
 {
  super.prepareForReuse()

  self.hostedItem = nil
  spinner.startAnimating()
  photoIconView.image = nil
  photoIconView.alpha = 1
  _selected = false
  clearFlagMarker()
  clearVideoDuration()
  hidePlayIcon()
  imageRoundClip(cornerRadius: 10)
  
 }
 
 
}//class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol...


