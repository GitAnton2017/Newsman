import UIKit
import Foundation
import AVKit

import class RxSwift.DisposeBag
import Combine

class PhotoSnippetCell: UICollectionViewCell,
                        PhotoSnippetCellProtocol,                 
                        DropViewProvidable,
                        SnippetItemsDraggable
 
{

 
 //deinit { print ("SINGLE ITEM CELL IS DESTROYED \(self)") }
 
 static let menuLongPressName = "ArrowMenuLongPress"
 
 @objc dynamic weak var arrowMenuView: PointedMenuView?
 
 
 weak var arrowMenuSearchTag: UIAlertController?
 
 var cancellables =  Set<AnyCancellable> ()
 
 let disposeBag = DisposeBag()
 
 var isDraggable: Bool { true }
 
 lazy var dropView: UIView = setDropView()
 
 lazy var dropDelegate: UIDropInteractionDelegate =
 {[ weak self ] in
  let dropDelegate = SingleCellDropViewDelegate(ownerCell: self)
  return dropDelegate
 }()
 

 var hostedView: UIView           { photoIconView }
 var hostedAccessoryView: UIView? { spinner       }

 weak var photoSnippet: PhotoSnippet?
 
 weak var photoSnippetVC: PhotoSnippetViewController?
 {
  didSet
  {
   dropView.isHidden = isContentDraggable
   configueInterfaceRotationSubscription()
  }
 }
 
 @IBOutlet weak var photoIconView: UIImageView!        //hosted photo UIImageView...
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 @IBOutlet weak var mainView: UIView!
 
 
 
 func cancelImageOperations() { hostedItem?.cancelImageOperations() }
 
 var rowPositionSubscription: AnyCancellable?
 
 weak var hostedItem: PhotoItemProtocol?
 //The sigle PhotoItem that is currently hosted and visualized by this type of UICollectionViewCell...
 {
  didSet
  {
   guard let hosted = hostedItem as? PhotoItem else
   {
    oldValue?.hostingCollectionViewCell = nil
    cleanup()
    return
   }
  
   
   hosted.hostingCollectionViewCell = self //weak reference to this cell that will display this PhotoItem...
   
   updateAllCellStatesSubscriptions()
   
   
   
   hosted.zoomView?.dropDelegate.ownerCell = self
 
   photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   isDragAnimating = hosted.isDragAnimating //|| hosted.isDropAnimating
   
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
  
   get { _selected }
 }
 
 final func cleanup()
 {
  dismissArrowMenu(animated: false)
  spinner.startAnimating()
  //photoIconView.image = nil
  photoIconView.alpha = 1
  contentView.alpha = 1
  contentView.backgroundColor = .clear
  
  _selected = false
  
  clearMainView()
  clearFlagMarker()
  clearVideoDuration()
  clearRowPosition(false)
  hidePlayIcon()
  imageRoundClip(cornerRadius: 10)
 }
 
 
 final private func configue()
 {
 
  photoIconView.isOpaque = true
  configueArrowMenu()
  
  let dropper = UIDropInteraction(delegate: dropDelegate)
  dropView.addInteraction(dropper)
  
  
  mainView?.publisher(for: \.bounds, options: [.prior])
   .collect(2)
   .filter{ $0[0] != $0[1] }
   .sink {[ weak self ] rects in
     guard let self = self else { return }
     guard let photoSnippetVC = self.photoSnippetVC else { return }
     self.dropView.isHidden = self.isContentDraggable
     self.cornerRadius = photoSnippetVC.cellCornerRadius
     if rects[1].contains(rects[0]) { self.updateImage(false) }
     
  }.store(in: &cancellables)
  
  cleanup()
 }
 
 override func awakeFromNib()
 {
  super.awakeFromNib()
  configue()

 }
 
 override func prepareForReuse()
 {
  super.prepareForReuse()
  cleanup()
 }
 
 override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
 {
  if let target = super.hitTest(point, with: event) { return target }

  for subview in subviews.reversed()
  {
   let tp = convert(point, to: subview)
   if let menuItemButton = subview.hitTest(tp, with: event) as? MenuItemButton
   {
    return menuItemButton
   }
  }
  return nil
 }
 
}//class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol...





