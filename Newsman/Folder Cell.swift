import UIKit
import Foundation
import CoreData

import RxSwift

import class Combine.AnyCancellable

class PhotoFolderCell: UICollectionViewCell,
                       PhotoSnippetCellProtocol,
                       DropViewProvidable,
                       PhotoManagedObjectsContextChangeObservable,
                       SnippetItemsDraggable
{
  var cancellables =  Set<AnyCancellable> ()
 
  @objc dynamic weak var arrowMenuView: PointedMenuView?
  weak var arrowMenuSearchTag: UIAlertController?
 
  var isDropPerformed = false
 
  var ddPublish = PublishSubject<Void>()
 
  let disposeBag = DisposeBag()
 
  deinit
  {
   //print ("<<<< FOLDER ITEM CELL IS DESTROYED >>>> \(self)")
   photoItems = []
   removeContextObservers()
  }
 
  lazy var dropView = setDropView()
 
  lazy var dropDelegate: UIDropInteractionDelegate =
  {
    let dropDelegate = FolderCellDropViewDelegate(ownerCell: self)
    return dropDelegate
  }()
 
  lazy var moc: NSManagedObjectContext =
  {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let moc = appDelegate.viewContext
    return moc
  }()
 
  var contextChangeObservers = Set<NSObject>()
 
  var groupTaskCount: Int = 0

 var hostedView: UIView { photoCollectionView.isHidden ? folderView : photoCollectionView }
 
  var hostedAccessoryView: UIView?
 
  var dragAndDropDelegate: FolderNestedCollectionViewDragAndDropDelegate?
 
  weak var photoSnippet: PhotoSnippet?
 
  weak var photoSnippetVC: PhotoSnippetViewController?
  {
   didSet
   {
    dropView.isHidden = isContentDraggable  //Delegate object must be retained strongly first-off!
    dragAndDropDelegate = FolderNestedCollectionViewDragAndDropDelegate(folderCell: self)
    photoCollectionView.dragDelegate = dragAndDropDelegate
    photoCollectionView.dropDelegate = dragAndDropDelegate
    configueInterfaceRotationSubscription()
   }
  }
 
  @IBOutlet var photoCollectionView: UICollectionView! //hosted folder cells internal CV...
  @IBOutlet weak var mainView: UIView!
 
  @Masked(maskShape: .star(points: 50, innerRatio: 0.75))
  @Constrained(anchors: .centerY(2, .top()), .trailing(3), .heightR(0.18), .widthR(0.27))
  final var childrenCounterTagView = DigitalTag()
 

 
  weak var hostedItem: PhotoItemProtocol?
  //The PhotoFolderItem that is currently hosted and visualized by this type of UICollectionViewCell...
  {
   didSet
   {
    guard let hosted = hostedItem as? PhotoFolderItem else
    {
     oldValue?.hostingCollectionViewCell = nil
     cleanup()
     return
    }
    
    updateAllCellStatesSubscriptions()
    
    // if zoomView is open and dispays this folder cell we will use [PhotoItems] of ZoomView to preserve ordering
    if let zv = photoSnippetVC?.photoCollectionView.zoomView, zv.zoomedPhotoItem === hosted
    {
     photoItems = zv.photoItems
    }
    else //otherwise construct new PhotoItems and assign them to the dequed FolderCell [PhotoItems]...
    {
     photoItems = hosted.singlePhotoItems.sorted{ $0.rowPosition < $1.rowPosition }
    }
   
    //photoCollectionView?.reloadData()
    //reloadFolderCell()

    hosted.hostingCollectionViewCell = self
    //weak reference to this folder cell that will display this PhotoFolderItem...
    
    photoCollectionView.alpha = hosted.isSelected ? 0.5 : 1
    
    isDragAnimating = hosted.isDragAnimating //|| hosted.isDropAnimating
    //if cell drag waggle animation deleted and hosted item is in selected state recover animation...
    
    //updateDraggableHostingCell()
    
    photoFolder = hosted //???
    groupTaskCount = 0   //???
    
   }
  }//weak var hostedItem: PhotoItemProtocol?...
 

  final private func reloadPhotoItems()
  {
   photoCollectionView?.reloadData()
   
   UIView.transition(from: folderView, to: photoCollectionView,
                     duration: 0.3,
                     options: [.transitionCrossDissolve, .showHideTransitionViews],
                     completion: nil)

  }
 
  private final var didEndDecelerating: Disposable?
  private final var didEndDragging: Disposable?
 
 
  final  func reloadFolderCell()
  {
   guard let photoItems = self.photoItems, !photoItems.isEmpty else
   {
    photoCollectionView?.isHidden = false
    return
    
   }
   guard let mainCV = photoSnippetVC?.photoCollectionView else { return }
   
   
   if mainCV.isDragging
   {
    didEndDecelerating = mainCV.rx.didEndDecelerating
     .subscribe{ [ weak self ] _ in
       self?.didEndDecelerating?.dispose()
       self?.didEndDragging?.dispose()
       self?.reloadPhotoItems()
      
    }
    
    didEndDragging = mainCV.rx.didEndDragging.filter{ !$0 }
     .subscribe{ [ weak self ] _ in
      self?.didEndDecelerating?.dispose()
      self?.didEndDragging?.dispose()
      self?.reloadPhotoItems()
      
    }
   }
   else
   {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000))
    {[ weak self ] in
     self?.reloadPhotoItems()
    }
   }
   
  }
 
  final var hostedCells: [PhotoFolderCollectionViewCell]
  {
   photoItems?.compactMap{ photoItemIndexPath(photoItem: $0)}
              .compactMap{ photoCollectionView.cellForItem(at: $0) as? PhotoFolderCollectionViewCell} ?? []
  }

  
  func cancelImageOperations() { photoItems?.forEach{ $0.cancelImageOperations() } }

  weak var photoFolder: PhotoFolderItem!

  let hostedViewSelectedAlpha: CGFloat = 0.5
 
  private var _selected = false
 
  var isPhotoItemSelected: Bool
  {
   set
   {
    _selected = newValue
    photoCollectionView.alpha = newValue ? hostedViewSelectedAlpha : 1
    touchSpring
    {
     self.photoCollectionView.visibleCells.compactMap{$0 as? PhotoFolderCollectionViewCell}.forEach{$0.touchSpring()}
    }
   }
   
   get { _selected }
  }

  var photoItemView: UIView    { contentView }
  var cellFrame: CGRect        { frame }

  var photoItems: [PhotoItem]!
  {
   didSet
   {
    
    guard let photoItems = self.photoItems, !photoItems.isEmpty else { return }
    childrenCounterTagView.cardinal = photoItems.count
    
   }
  }
 
  var photoItemsIndexPaths: [IndexPath]
  {
   photoItems?.enumerated().map{ IndexPath(row: $0.offset, section: 0)} ?? []
  }

  var nphoto: Int = 3

  var frameSize: CGFloat = 0
  
  private final func configueChildrenCounterTag()
  {
   addSubviews(childrenCounterTagView)
  }
 
  @Constrained() private final var folderView = UIImageView()
 
  private final func configueFolderView()
  {
   photoCollectionView?.isHidden = true
   guard let mainView = mainView as? PhotoSnippetCellMainView else { return }
   mainView.insertSubview(folderView, at: 0)

  }

 
  override func layoutSubviews()
  {
   super.layoutSubviews()
   updateNestedCollectionViewLayout()
   guard arrowMenuView == nil else { return }
   superview?.bringSubviewToFront(self)
   recoverCellOverlapping()
  }
 
  private final func updateNestedCollectionViewLayout()
  {
    guard bounds != .zero else { return }
    guard photoItems != nil else { return }
    guard let photoSnippetVC = photoSnippetVC else { return }
   
    nphoto = photoSnippetVC.folderCellPhotosInRow
    cornerRadius = photoSnippetVC.cellCornerRadius
    frameSize = photoSnippetVC.imageSize
    dropView.isHidden = isContentDraggable
  
    DispatchQueue.main.async
    {
     self.photoCollectionView?.collectionViewLayout.invalidateLayout()
    }
 
    refreshRowPositionMarker(false)
  }
 
  private final func configue()
  {
   addContextObservers() //gets this by virtue of PhotoManagedObjectsContextChangeObservable...
   configueArrowMenu()
   configueChildrenCounterTag()
   configueFolderView()
   
   let dropper = UIDropInteraction(delegate: dropDelegate)
   dropView.addInteraction(dropper)
   
   photoCollectionView.dragInteractionEnabled = true
   
   photoCollectionView.dataSource = self
   photoCollectionView.delegate = self
   
   cleanup()
  }
 
  override func awakeFromNib()
  {
   super.awakeFromNib()
   configue()
  }

 final func cleanup()
 {
  dismissArrowMenu(animated: false)
  
  _selected = false
  
  //photoItems?.forEach{$0.cancellAllStateSubscriptions()}
  photoItems = nil
  
  didEndDecelerating?.dispose()
  didEndDragging?.dispose()
  
  photoCollectionView?.isHidden = true
  folderView.image = nil
  folderView.isHidden = false
  
  
  //photoCollectionView?.alpha = 1
  contentView.alpha = 1
  contentView.backgroundColor = .clear
  groupTaskCount = 0
  
  clearMainView()
  clearFlagMarker()
  clearRowPosition(false)
  imageRoundClip(cornerRadius: 10)
  
  showNestedCollectionViewAfterRotation()
 }

 
 private final weak var nestedCollectionViewSnapShot: UIView?
 
 final func hideNestedCollectionViewBeforeRotation()
 {
  guard let snapShot = photoCollectionView?.snapshotView(afterScreenUpdates: false) else { return }
  mainView?.addSubview(snapShot)
  nestedCollectionViewSnapShot = snapShot
  snapShot.translatesAutoresizingMaskIntoConstraints = false
  mainView?.topAnchor.constraint(equalTo: snapShot.topAnchor).isActive = true
  mainView?.leadingAnchor.constraint(equalTo: snapShot.leadingAnchor).isActive = true
  mainView?.trailingAnchor.constraint(equalTo: snapShot.trailingAnchor).isActive = true
  mainView?.bottomAnchor.constraint(equalTo: snapShot.bottomAnchor).isActive = true
  photoCollectionView?.removeFromSuperview()
 }
 
 final func showNestedCollectionViewAfterRotation()
 {
  guard let cv = photoCollectionView else { return }
  guard !(mainView.subviews.contains{ $0 === cv }) else { return }
  guard let snapShot = nestedCollectionViewSnapShot else { return }

  snapShot.removeFromSuperview()
  nestedCollectionViewSnapShot = nil
  mainView?.addSubview(cv)
  mainView?.sendSubviewToBack(cv)
  cv.translatesAutoresizingMaskIntoConstraints = false
  mainView?.topAnchor.constraint(equalTo: cv.topAnchor).isActive = true
  mainView?.leadingAnchor.constraint(equalTo: cv.leadingAnchor).isActive = true
  mainView?.trailingAnchor.constraint(equalTo: cv.trailingAnchor).isActive = true
  mainView?.bottomAnchor.constraint(equalTo: cv.bottomAnchor).isActive = true
  mainView?.layoutIfNeeded()
  
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
 
} //class PhotoFolderCell: UICollectionViewCell, PhotoSnippetCellProtocol...





