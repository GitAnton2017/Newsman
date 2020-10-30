import UIKit
import class RxSwift.DisposeBag
import class Combine.AnyCancellable

class PhotoFolderCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
 weak var photoSnippet: PhotoSnippet?
 weak var photoSnippetVC: PhotoSnippetViewController?
 {
  didSet{
   configueInterfaceRotationSubscription()
  }
 }
 
 var isDraggable: Bool { true }
 

 var cancellables =  Set<AnyCancellable> ()
 
 weak var arrowMenuSearchTag: UIAlertController?
 weak var arrowMenuView: PointedMenuView?
 {
  didSet
  {
   guard let nestedCellMenu = arrowMenuView else { return }
   guard let folderCell = owner else { return }
   guard let photo = (hostedItem as? PhotoItem)?.photo else { return }
   guard let zoomView = folderCell.photoSnippetVC?.photoCollectionView.zoomView else { return }
   guard let zoomViewCell = zoomView.cellWithPhoto(photo: photo) else { return }
   guard let zoomViewCellMenu = zoomViewCell.arrowMenuView else { return }
   
   nestedCellMenu.baseView.isMenuPanning = zoomViewCellMenu.baseView.isMenuPanning
   
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
 

 let disposeBag = DisposeBag()
 

 
 var hostedViewSelectedAlpha: CGFloat = 0.5
 
 weak var owner: PhotoFolderCell? // weak ref to FolderCell which hosts he nested CV.
 
 var hostedView: UIView { photoIconView }
 var hostedAccessoryView: UIView? { spinner }
 
 weak var hostedItem: PhotoItemProtocol?
 {
  didSet
  {
   guard let hosted = hostedItem as? PhotoItem else
   {
    oldValue?.hostingCollectionViewCell = nil
    cleanup()
    return
   }
 
   updateAllCellStatesSubscriptions()
   
   hosted.hostingCollectionViewCell = self
   //weak reference to this cell that will display this PhotoItem until updated and dequed in nested CV!
   
   photoIconView.alpha = hosted.isSelected ? 0.5 : 1
   
   isDragAnimating = hosted.isDragAnimating
 
 
  }
  
 }//weak var hostedItem: PhotoItemProtocol?...
 
 func cancelImageOperations()
 {
  hostedItem?.cancelImageOperations()
 }
 
 var photoItemView: UIView { contentView }
 
 var cellFrame: CGRect     { frame }
 
 private var _selected = false
 var isPhotoItemSelected: Bool
 {
  get { _selected }
  set
  {
   _selected = newValue
   photoIconView.alpha = newValue ? hostedViewSelectedAlpha : 1
   touchSpring()
  }
  
  
 }
 
 @IBOutlet weak var photoIconView: UIImageView!
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 @IBOutlet weak var mainView: UIView!
 
 
 private final func configue()
 {
  photoIconView.isOpaque = true
  configueArrowMenu()
  
  mainView?.publisher(for: \.bounds, options: [.prior])
   .collect(2)
   .filter{ $0[0] != $0[1] }
   .sink { [ weak self ] rects in
     guard let self = self else { return }
     guard let folderCell = self.owner else { return }
     self.cornerRadius = folderCell.cellCornerRadius
//     self.refreshRowPositionMarker(false)
     if rects[1].contains(rects[0]) { self.updateImage(false) }
   }.store(in: &cancellables)
  
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
 
}
