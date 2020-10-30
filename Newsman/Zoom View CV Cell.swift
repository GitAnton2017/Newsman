
import Foundation
import UIKit
import class RxSwift.DisposeBag

import class Combine.AnyCancellable

class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
 weak var photoSnippet: PhotoSnippet?
 weak var photoSnippetVC: PhotoSnippetViewController?
 {
  didSet{
   configueInterfaceRotationSubscription()
  }
 }
 
 var isDraggable: Bool { true }
 
 var cancellables = Set<AnyCancellable>()
 
 weak var arrowMenuSearchTag: UIAlertController?
 weak var arrowMenuView: PointedMenuView?
 {
  didSet
  {
   guard let zoomViewCellMenu = self.arrowMenuView else { return }
   guard let folderItem = self.zoomView?.zoomedPhotoItem as? PhotoFolderItem else { return }
   guard let folderCell = folderItem.hostingCollectionViewCell as? PhotoFolderCell else { return }
   guard let photo = (self.hostedItem as? PhotoItem)?.photo else { return }
   guard let nestedCell = folderCell.cellWithPhoto(photo: photo) else { return }
   guard let nestedCellMenu = nestedCell.arrowMenuView else { return }
   
   zoomViewCellMenu.baseView.isMenuPanning = nestedCellMenu.baseView.isMenuPanning
   
   var zoomCellPan: AnyCancellable?
   var nestedCellPan: AnyCancellable?
   
   zoomCellPan = zoomViewCellMenu
    .publisher(for: \.baseView.isMenuPanning, options: [])
    .print("zoomViewCellMenu")
    .handleEvents(receiveOutput: { _ in nestedCellPan?.cancel() })
    .assign(to:     \.baseView.isMenuPanning, on: nestedCellMenu)
   
    zoomCellPan?.store(in: &zoomViewCellMenu.cancellables)
   
    nestedCellPan = nestedCellMenu
    .publisher(for: \.baseView.isMenuPanning, options: [])
    .print("nestedCellMenu")
    .handleEvents(receiveOutput: { _ in zoomCellPan?.cancel() })
    .assign(to:     \.baseView.isMenuPanning, on: zoomViewCellMenu)
   
    nestedCellPan?.store(in: &nestedCellMenu.cancellables)
   
   zoomViewCellMenu.$menuShift.filter{$0 != .zero}.sink
   {[weak nestedCellMenu] in
    guard let menu = nestedCellMenu else { return }
    menu.activitySubject.onNext(())
    menu.move(dx: $0.x * menu.bounds.width, dy: $0.y * menu.bounds.height)
   }.store(in: &zoomViewCellMenu.cancellables)
   
   nestedCellMenu.$menuShift.filter{$0 != .zero}.sink
   {[weak zoomViewCellMenu] in
    guard let menu = zoomViewCellMenu else { return }
    menu.activitySubject.onNext(())
    menu.move(dx: $0.x * menu.bounds.width, dy: $0.y * menu.bounds.height)
   }.store(in: &nestedCellMenu.cancellables)
   
   zoomViewCellMenu.$menuScale.filter{$0 != .zero}.sink
   {[weak nestedCellMenu] in
    guard let menu = nestedCellMenu else { return }
    menu.activitySubject.onNext(())
    menu.baseView.transform = menu.baseView.transform.scaledBy(x: $0, y: $0)
   }.store(in: &zoomViewCellMenu.cancellables)
   
   nestedCellMenu.$menuScale.filter{$0 != .zero}.sink
   {[weak zoomViewCellMenu] in
    guard let menu = zoomViewCellMenu else { return }
    menu.activitySubject.onNext(())
    menu.baseView.transform = menu.baseView.transform.scaledBy(x: $0, y: $0)
   }.store(in: &nestedCellMenu.cancellables)
  }
  
 }

 
 weak var zoomView: ZoomView?
 
 let disposeBag = DisposeBag()
 
 var hostedViewSelectedAlpha: CGFloat = 0.5
 
 var hostedView: UIView { photoIconView }
 var hostedAccessoryView: UIView? { spinner }
 
 @IBOutlet weak var photoIconView: UIImageView!
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 @IBOutlet weak var mainView: UIView!
 
 weak var hostedItem: PhotoItemProtocol?
 {
  didSet
  {
   guard let hosted = self.hostedItem as? PhotoItem else
   {
    (oldValue as? PhotoItem)?.hostingZoomedCollectionViewCell = nil
    cleanup()
    return
   }
   

   updateAllCellStatesSubscriptions()
   
   hosted.hostingZoomedCollectionViewCell = self
   
   photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   isDragAnimating = hosted.isDragAnimating
   
  }
  
 }//weak var hostedItem: PhotoItemProtocol?...

 func cancelImageOperations()
 {
  hostedItem?.cancelImageOperations()
 }

 var photoItemView: UIView { contentView }

 var cellFrame: CGRect { frame }

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

 private final func configue()
 {
  photoIconView.isOpaque = true
  configueArrowMenu()
  cleanup()
 }
 
 override func awakeFromNib()
 {
  super.awakeFromNib()
  configue()
 }
 
 
 func cleanup()
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
  clearRowPosition(false)
  clearVideoDuration()
  imageRoundClip(cornerRadius: 5)
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
 
}//class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol...
