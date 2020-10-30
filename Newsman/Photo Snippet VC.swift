
import UIKit
import CoreData
import RxSwift
import RxCocoa
import Combine
import CloudKit

class PhotoSnippetViewController: UIViewController,
                                  NCSnippetsScrollProtocol,
                                  SnippetsRepresentable,
                                  ManagedObjectContextSavable,
                                  PhotoManagedObjectsContextChangeObservable,
                                  SnippetItemsDraggable,
                                  UIScrollViewDelegate
                              

{
 
 lazy var moc: NSManagedObjectContext =
 {
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let moc = appDelegate.viewContext
  return moc
 }()
 
 
 //var ddDelegateSubject = PublishSubject<DragAndDropDelegateStates>()
 
 var isDropPerformed = false
 //var ddPublish = PublishSubject<Void>()
 let disposeBag = DisposeBag()
 var cancellables = Set<AnyCancellable>()
 
 var takePictureButtonDisposable: Disposable?
 
 deinit
 {
  print ("VC DESTROYED WITH PHOTO SNIPPET \(String(describing: photoSnippet?.snippetName))")
  
  removeContextObservers()
  cancellAllStateSubscriptions()
  
  
 }
 
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
  addContextObservers() //gets this by virtue of PhotoManagedObjectsContextChangeObservable...
 }
 
 var photoSnippetVC: PhotoSnippetViewController! { self }
 
 static var storyBoardID = "PhotoSnippetVC"
 
 var currentSnippet: BaseSnippet
 {
  get { photoSnippet }
  set { photoSnippet = newValue as? PhotoSnippet }
 }
 
 var contextChangeObservers = Set<NSObject>()
 
 weak var currentFRC: SnippetsFetchController?
 {
  didSet { currentSnippet.currentFRC = self.currentFRC }
 }
 
 weak var snippetsTableView: UITableView?
 
 var currentViewController: UIViewController { self }
 
    
//MARK: ===================== CALCULATED PROPERTIES =========================
 
 var photoSnippet: PhotoSnippet!
 {
  didSet
  {
   guard photoSnippet != nil else { return }
   navigationItem.title = photoSnippet.snippetName
   allPhotosSelected = photoSnippet.allPhotosSelected
  }
 }
 
 override var prefersStatusBarHidden: Bool { false }
 
 var imageSize: CGFloat
 {
  guard photoCollectionView != nil else { return 0 }
  let N = self.photosInRow
  let width = photoCollectionView.frame.width
  let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  let lelfInset =  fl.sectionInset.left
  let rightInset = fl.sectionInset.right
  let itemSpace =  fl.minimumInteritemSpacing
  let size = (width - lelfInset - rightInset - itemSpace * CGFloat(N - 1)) / CGFloat(N)
  return trunc (size) 
 }
 
 struct PhotoCollectionViewScrollPosition
 {
  let rows: Int
  let topInsets: Int
  let bottomInsets: Int
  let lineSpaces: Int
  let footers: Int
  let headers: Int
  
  static let zero = Self(rows: 0, topInsets: 0, bottomInsets: 0, lineSpaces: 0, footers: 0, headers: 0)
 }
 
 private final var scrollPosition: PhotoCollectionViewScrollPosition = .zero
 
 private final var scrollOffsetY: CGFloat
 {
  guard let cv = photoCollectionView else { return .zero }
  let fl = cv.collectionViewLayout as! UICollectionViewFlowLayout
  let ti = fl.sectionInset.top
  let bi = fl.sectionInset.bottom
  let ls = fl.minimumLineSpacing
  let hh = collectionView(cv, layout: fl, referenceSizeForHeaderInSection: 0).height
  let fh = collectionView(cv, layout: fl, referenceSizeForFooterInSection: 0).height
  
  return CGFloat(scrollPosition.rows) * imageSize +
         CGFloat(scrollPosition.topInsets) * ti +
         CGFloat(scrollPosition.bottomInsets) * bi +
         CGFloat(scrollPosition.lineSpaces) * ls +
         CGFloat(scrollPosition.headers) * hh +
         CGFloat(scrollPosition.footers) * fh
  
  
 }
 
 //private final var photoCollectionViewRowIndex: Int = 0

 
 func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                withVelocity velocity: CGPoint,
                                targetContentOffset: UnsafeMutablePointer<CGPoint>)
 {
  guard let cv = photoCollectionView else { return }
  
  let offsetY = targetContentOffset.pointee.y
  let fl = cv.collectionViewLayout as! UICollectionViewFlowLayout
  let ti = fl.sectionInset.top
  let bi = fl.sectionInset.bottom
  let ls = fl.minimumLineSpacing
  let hh = collectionView(cv, layout: fl, referenceSizeForHeaderInSection: 0).height
  let fh = collectionView(cv, layout: fl, referenceSizeForFooterInSection: 0).height
  let sections = cv.numberOfSections
  var footerCount = 0, headerCount = 0, rowsCount = 0
  var topInsetCount = 0, bottomInsetCount = 0, lineSpaceCount = 0
  var offset: CGFloat = .zero
  
  for section in 0..<sections
  {
   if offset <= offsetY { offset += hh; headerCount += 1      } else { break }
   if offset <= offsetY { offset += ti; topInsetCount += 1    } else { break }
   
   let rows = Int((CGFloat(cv.numberOfItems(inSection: section)) / CGFloat(photosInRow)).rounded(.up))
   
   for row in 0..<rows where offset <= offsetY
   {
    offset += imageSize; rowsCount += 1
    if row < rows - 1 { offset += ls; lineSpaceCount += 1 }
   }
  
   if offset <= offsetY { offset += bi; bottomInsetCount += 1 } else { break }
   if offset <= offsetY { offset += fh; footerCount += 1      } else { break }
  }
  
  
  scrollPosition = PhotoCollectionViewScrollPosition(rows: rowsCount,
                                                     topInsets: topInsetCount,
                                                     bottomInsets: bottomInsetCount,
                                                     lineSpaces: lineSpaceCount,
                                                     footers: footerCount,
                                                     headers: headerCount)
  
 // photoCollectionViewRowIndex = Int (offsetY / imageSize)
 }
 
 var photosInRow: Int
 {
  get { Int(photoSnippet?.nphoto ?? 3) }
  set
  {
  
   if newValue > maxPhotosInRow
   {
    photoSnippet?.nphoto = Int32(minPhotosInRow)
   }
   else if newValue < minPhotosInRow
   {
    photoSnippet?.nphoto = Int32(maxPhotosInRow)
   }
   else
   {
    photoSnippet?.nphoto = Int32(newValue)
   }
  
   photoCollectionViewSnapShotTransition(1.25)
  
  }
 }
 
 private final func showHideTopBottomElements(hidden: Bool, completion: ((Bool) -> Void)? = nil )
 {
  UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations:
  {[ weak self ] in
   guard let self = self else { return }
   self.photoSnippetTitle?.clearButtonMode = hidden ? .never : .always
   self.photoSnippetTitleTextEditTop?.constant = hidden ? -(self.titleTextHeightConst + 1) : 16
   self.photoSnippetToolBarBottom?.constant = hidden ? self.toolBarHeightConst - 4 : 0
   self.photoSnippetTitle?.superview?.layoutIfNeeded()
  }, completion: completion)
 }
 
 private final func photoCollectionViewSnapShotTransition(_ duration: TimeInterval)
 {
  
  guard let cv = photoCollectionView else { return }
  cv.collectionViewLayout.invalidateLayout()
  
  guard let snapShot = cv.snapshotView(afterScreenUpdates: false) else { return }
  
  view.addSubview(snapShot)
  snapShot.isUserInteractionEnabled = false
  snapShot.frame = cv.frame
  cv.isHidden = true

  UIView.transition(from: snapShot, to: cv, duration: duration,
                    options: [.transitionCrossDissolve, .showHideTransitionViews])
                    { [weak snapShot] _ in snapShot?.removeFromSuperview() }
  
 }
 
 final var visibleFolderCells: [PhotoFolderCell]
 {
  photoCollectionView?.visibleCells.compactMap{ $0 as? PhotoFolderCell } ?? []
 }
 
 final func stopPhotoCollectionViewScrolling()
 {
  guard let cv = photoCollectionView else { return }
  cv.isScrollEnabled = false
  cv.setContentOffset(cv.contentOffset, animated: false)
  cv.isScrollEnabled = true
 }
 
 final func hideFolderCellsNestedCollectionViewsBeforeRotation()
 {
  visibleFolderCells.forEach { $0.hideNestedCollectionViewBeforeRotation() }
 }
 
 final func showFolderCellsNestedCollectionViewsAfterRotation()
 {
  visibleFolderCells.forEach { $0.showNestedCollectionViewAfterRotation() }
 }
 
 
 @Published var interfaceWillRotate = false
 lazy var rotationStates = BehaviorSubject<CGSize>(value: view.bounds.size)
 
 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
 {
  super.viewWillTransition(to: size, with: coordinator)
  
  interfaceWillRotate = true
  
  stopPhotoCollectionViewScrolling()
  
  hideFolderCellsNestedCollectionViewsBeforeRotation()
  
  photoCollectionView?.collectionViewLayout.invalidateLayout()
  
  if photoSnippetTitle?.isFirstResponder ?? false { photoSnippetTitle?.resignFirstResponder() }
  
  DispatchQueue.main.async { [ weak self ] in
   guard let self = self else { return }
   let offsetPoint = CGPoint(x: 0, y: self.scrollOffsetY)
   self.photoCollectionView?.setContentOffset(offsetPoint, animated: false)
   
  }
 
  coordinator.animateAlongsideTransition(in: photoCollectionView, animation:
  { [ weak self ] context in
    self?.photoScaleStepper?.transform = (size.width > size.height) ? .init(scaleX: 1.25, y: 1.25) : .identity
  })
  { [ weak self ] context in
   
   self?.showFolderCellsNestedCollectionViewsAfterRotation()
   self?.rotationStates.onNext(size)
   self?.interfaceWillRotate = false

  }
 }
 
 

 
//MARK: ========================== STORED PROPERTIES ==============================
    
 var isTakePictureReady = true
 var isEditingMode = true
 var isEditingPhotos = false
 var currentToolBarItems: [UIBarButtonItem]!
 
 var allPhotosSelected = false
 {
  didSet { selectBarButton?.title = allPhotosSelected ? "☆☆☆" : "★★★" }
 }
 
 var selectBarButton: UIBarButtonItem!
 var menuTapGR: UITapGestureRecognizer!
 
 let maxPhotosInRow = 10
 let minPhotosInRow = 1
 
 let nPhotoFolderMap = [10: 2, 9: 2, 8: 2, 7: 2, 6: 2, 5: 2, 4: 3, 3: 4, 2: 5, 1: 6]
 
    
 var menuView: UIView? = nil
 var menuFrameSize: CGSize!
 var menuTouchPoint: CGPoint = CGPoint.zero
    
 static var menuIndexPath: IndexPath? = nil // CV index path where small photo item menu appeares...
 static var menuShift = CGPoint.zero

 let imagePicker = UIImagePickerController()
 let imagePickerTransitionDelegate = VCTransitionsDelegate(animator: SpringDoorAnimator(with: 0.6))
 var imagePickerTakeButton: UIButton!
 var imagePickerCnxxButton: UIButton!
 
 lazy var sectionTitles: [String]? = //section titles for sectioned photo collection view if any...
 {
   guard photoSnippet.isSectioned else { return nil }
   let titles = photoSnippet.sortedSectionTitles
   return titles.isEmpty ? nil : titles
 }()
 
 lazy var photoItems2D: [[PhotoItemProtocol]] = { photoSnippet?.photoItems2D ?? [] }()
 
 var photoSnippetRestorationID: String?
 var photoSnippetVideoID: UUID?
    
//---------------------------------------------------------------------------------
//MARK:-
    
//MARK: ============================ OUTLETS ======================================
    
 @IBOutlet weak var photoCollectionView: PhotoSnippetCollectionView!
 @IBOutlet weak var photoScaleStepper: UIStepper!
 @IBOutlet weak var photoSnippetTitle: UITextField!
 @IBOutlet weak var photoSnippetToolBar: UIToolbar!
    
 //--------------------- VC Tool Bar Menu Buttons ---------------------------------
 
 @IBOutlet weak var saveBarButton: UIBarButtonItem!
 @IBOutlet weak var datePickerBarButton: UIBarButtonItem!
 @IBOutlet weak var takePhotoBarButton: UIBarButtonItem!
 @IBOutlet weak var priorityPickerBarButton: UIBarButtonItem!
 
 
 
 //--------------------------------------------------------------------------------
 @IBOutlet weak var photoSnippetTitleTextEditLeading: NSLayoutConstraint!
 lazy var titleTextLeadingConst: CGFloat = photoSnippetTitleTextEditLeading?.constant ?? 0
 
 @IBOutlet weak var photoSnippetToolBarLeading: NSLayoutConstraint!
 lazy var toolBarLeadingConst: CGFloat = photoSnippetToolBarLeading?.constant ?? 0
 
 @IBOutlet weak var photoScaleStepperBottom: NSLayoutConstraint!
 lazy var stepperBottomConst: CGFloat = photoScaleStepperBottom?.constant ?? 0
 
 @IBOutlet weak var photoSnippetToolBarHeight: NSLayoutConstraint!
 lazy var toolBarHeightConst: CGFloat = photoSnippetToolBarHeight?.constant ?? 0
 
 @IBOutlet weak var photoSnippetTitleTextEditHeight: NSLayoutConstraint!
 lazy var titleTextHeightConst: CGFloat = photoSnippetTitleTextEditHeight?.constant ?? 0
 
 @IBOutlet weak var photoSnippetTitleTextEditTrailing: NSLayoutConstraint!
 lazy var titleTextTrailingConst: CGFloat = photoSnippetTitleTextEditTrailing?.constant ?? 0
 
 @IBOutlet weak var photoSnippetToolBarBottom: NSLayoutConstraint!
 lazy var toolBarBottomConst: CGFloat = photoSnippetToolBarBottom?.constant ?? 0
 
 @IBOutlet weak var photoSnippetTitleTextEditTop: NSLayoutConstraint!
 
 
 var dragAndDropStates: Observable<DragAndDropDelegateStates>
 {
  (UIApplication.shared.delegate as! AppDelegate).dragAndDropDelegatesStatesSubject.share()
 }


 lazy var photoSnippetBlurView: UIVisualEffectView? = {
  guard let cv = photoCollectionView else { return nil }
  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
  visualEffectView.translatesAutoresizingMaskIntoConstraints = false
  visualEffectView.isUserInteractionEnabled = false
  cv.addSubview(visualEffectView)

  let cvflg = cv.frameLayoutGuide
  visualEffectView.topAnchor.constraint(equalTo: cvflg.topAnchor).isActive = true
  visualEffectView.bottomAnchor.constraint(equalTo: cvflg.bottomAnchor).isActive = true
  visualEffectView.trailingAnchor.constraint(equalTo: cvflg.trailingAnchor).isActive = true
  visualEffectView.leadingAnchor.constraint(equalTo: cvflg.leadingAnchor).isActive = true

  //visualEffectView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
  return visualEffectView
 }()
 
 private func configueDragAndDropStateAmimation()
 {
  
  photoSnippetBlurView?.alpha = 0

  dragAndDropStates.map { [weak self] state -> CGFloat in
   switch state
   {
    case let .exit(view: view?, at: point?)
     where view === self?.photoCollectionView && !view.bounds.contains(point): return 0.5
    default: return 0
   }
  }
  .subscribe(onNext: { [ weak self ] alpha in
    guard let blurView = self?.photoSnippetBlurView else { return }
    self?.photoCollectionView.bringSubviewToFront(blurView)
    UIView.animate(withDuration: 0.5){ blurView.alpha = alpha }
  }).disposed(by: disposeBag)

  
   
  let ddState = dragAndDropStates.filter{ $0 == .begin || $0 == .end || $0 == .initial }.map{ $0 == .begin }

  let rotateState = rotationStates.filter { $0 != .zero }.map { $0.width > $0.height }

  Observable.combineLatest(ddState, rotateState)
   .skip(1)
   .map{ $0 || $1 }
   .distinctUntilChanged()//.debug("HIDDEN TOP BOTTOM")
   .subscribe(onNext: {[weak self] in self?.showHideTopBottomElements(hidden: $0)})
   .disposed(by: disposeBag)
  
 }
 
 private final func showHidePhotoScaleStepper( _ hidden: Bool)
 {
  let bottomConst = stepperBottomConst
  guard let sv = photoScaleStepper?.superview else { return }
  guard let bottom = photoScaleStepperBottom else { return }
  
  switch (hidden, bottom.constant)
  {
   case (true, bottomConst) : bottom.constant = -100
   case (false,       -100) : bottom.constant = bottomConst
   default: return
  }
 
  UIView.animate(withDuration: 0.5) { sv.layoutIfNeeded() }
 }
 
 
 
 private final func animatePhotoScaleStepper(scrolling: Bool)
 {
  photoScaleStepper.transform = scrolling ? .identity : CGAffineTransform(translationX: -view.bounds.width, y: 0)
  UIView.animate(withDuration: 0.3, delay: 0,
                 options: [.curveEaseInOut],
                 animations:  {[ weak self ] in
                   guard let self = self else { return }
                   self.photoScaleStepper.transform =
                     scrolling ? CGAffineTransform(translationX: self.view.bounds.width, y: 0) : .identity
                   self.photoScaleStepper.alpha = scrolling ? 0 : 1
                 }, completion: nil)
  
 }
 
  

 func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
 {
  //print (#function)
  
  animatePhotoScaleStepper(scrolling: true)
 }

 func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
 {
  //print (#function, decelerate)
  if decelerate { return }
  animatePhotoScaleStepper(scrolling: false)
 
 }

 func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
 {
  animatePhotoScaleStepper(scrolling: false)
 }

 private func configuePhotoScaleStepperRx()
 {
  photoScaleStepper.value = Double(photosInRow)
  photoScaleStepper.minimumValue = Double(minPhotosInRow)
  photoScaleStepper.maximumValue = Double(maxPhotosInRow)
  photoScaleStepper.stepValue = 1.0
  photoScaleStepper.wraps = true
  
  let min = self.minPhotosInRow
  let max = self.maxPhotosInRow

  Observable.zip(photoScaleStepper.rx.value.map{Int($0)},
                 photoScaleStepper.rx.value.skip(1).map{Int($0)}).map {
                   switch $0
                   {
                    case (min, max): return -1
                    case (max, min): return  1
                    default: return $0.1 - $0.0
                   }
                  }
                 .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                 .debug("STEPPER INC")
                 .subscribe(onNext: { [unowned self] in self.photosInRow += $0 })
                 .disposed(by: disposeBag)

  
  dragAndDropStates.filter { $0 == .begin }
   .subscribe(onNext: { [ weak self ] _ in self?.showHidePhotoScaleStepper(true) })
   .disposed(by: disposeBag)
  
  dragAndDropStates.filter { $0 == .end }
   .debounce(.seconds(3), scheduler: MainScheduler.instance)
   .subscribe(onNext: { [ weak self ] _ in self?.showHidePhotoScaleStepper(false) })
   .disposed(by: disposeBag)
 
 }
 
 private func configueSnippetTitleRx()
 {
 
 }
 
 lazy var dragAndDropDelegate: PhotoSnippetCollectionViewDragAndDropDelegate? =
 {
  guard let photoSnippet = self.photoSnippet else { return nil }
  let ddd = PhotoSnippetCollectionViewDragAndDropDelegate(photoSnippet: photoSnippet, viewController: self)
  return ddd
 }()
 
 
 private func configuePhotoCollectionViewDragAndDropDelegate()
 {
  // D & D Delegate object must be retained strongly first-off!
  photoCollectionView.dragDelegate = dragAndDropDelegate//self
  photoCollectionView.dropDelegate = dragAndDropDelegate//self
 }
 
 private func configuePhotoCollectionView()
 {
  photoCollectionView.dataSource = self
  photoCollectionView.delegate = self
 
  //observeDragAndDropStates()
 
  photoCollectionView.dragInteractionEnabled = true
  photoCollectionView.allowsMultipleSelection = false
  //<didDeselect> will be called automaticaly if implemented in delegate!!!
 }
 

 
 
 override func viewDidLoad()
 {
  super.viewDidLoad()
 
  navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)

  configuePhotoCollectionView()
 
  imagePicker.delegate = self
  imagePicker.transitioningDelegate = imagePickerTransitionDelegate
 
  photoSnippetTitle.inputAccessoryView = createKeyBoardToolBar()
  currentToolBarItems = photoSnippetToolBar.items
  
  menuFrameSize = view.frame.size
 
  photoSnippetTitle.delegate = self

  configuePhotoScaleStepperRx()
  configueDragAndDropStateAmimation()
        
 }//override func viewDidLoad()...

 override func viewWillAppear(_ animated: Bool)
 {
   super.viewWillAppear(animated)
   updatePhotoSnippet()
 }


 func updateDateLabel()
 {

  let dateLabel  = UILabel()
  dateLabel.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
  dateLabel.font = UIFont(name: "Avenir", size: 20)
  dateLabel.text = DateFormatters.short.string(from: photoSnippet.date! as Date)
  navigationItem.titleView = dateLabel
  
 }
 
 func updatePhotoSnippet()
 {
  guard isEditingMode else { isEditingMode = true; return }
  
  guard photoSnippet != nil else { return }
  
  configuePhotoCollectionViewDragAndDropDelegate()
  
  photoCollectionView.reloadData()
  
  updateDateLabel()
  
  photoSnippetTitle.text = (photoSnippet.snippetName == Localized.unnamedSnippet ? "" : photoSnippet.snippetName)
   
  switch photoSnippet.snippetType
  {
   case .video : takePhotoBarButton.image = UIImage(named: "video.tab.icon")
   default: break
  }
   
 
 
 }

 override func viewDidAppear(_ animated: Bool)
 {
  super.viewDidAppear(animated)
  guard photoSnippet != nil else { return }
  updateDateLabel()
  showHideTopBottomElements(hidden: view.bounds.width > view.bounds.height)
 }
 
 
 override func viewWillDisappear(_ animated: Bool)
 {
 
  super.viewWillDisappear(animated)
  moc.saveIfNeeded()
  
//  photoCollectionView.visibleCells
//   .compactMap{ $0 as? PhotoSnippetCellProtocol }
//   .forEach {$0.cancelImageOperations()}
 }

 
 
 @IBAction func photoScaleStepperUpIn(_ sender: UIStepper)
 {
  //savePhotoSnippetData()
 }

 @IBAction func photoScaleStepperChanged(_ sender: UIStepper)
 {
 // nphoto = Int(sender.value)
 }

 @IBAction func editPhotosPress(_ sender: UIBarButtonItem)
 {
  togglePhotoEditingMode()
 }

 @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer)
 {
  if (sender.scale > 1 && photosInRow < maxPhotosInRow) { photosInRow += 1 }
  if (sender.scale < 1 && photosInRow > minPhotosInRow) { photosInRow -= 1 }
 }
 

 @IBAction func saveBarButtonPress(_ sender: UIBarButtonItem)
 {
    if photoSnippetTitle.isFirstResponder
    {
        photoSnippetTitle.resignFirstResponder()
    }
    
    savePhotoSnippetData()
 }
 
 @IBAction func itemUpBarButtonPress(_ sender: UIBarButtonItem)
 
 {
  if photoSnippetTitle.isFirstResponder {photoSnippetTitle.resignFirstResponder()}
  moveToNextSnippet(in: -1)
 }
 
 @IBAction func itemDownBarButtonPress(_ sender: UIBarButtonItem)

 {
  if photoSnippetTitle.isFirstResponder {photoSnippetTitle.resignFirstResponder()}
  moveToNextSnippet(in: 1)
 }
 
 

    
 

 override func didReceiveMemoryWarning()
 {
    super.didReceiveMemoryWarning()
    PhotoItem.imageCacheDict.values.forEach{$0.removeAllObjects()}
    print ("MEMORY LOW!")
 }

 
 
 @objc func doneButtonPressed ()
 {
  if photoSnippetTitle.isFirstResponder
  {
    photoSnippetTitle.resignFirstResponder()
  }
 }

 

 
 func savePhotoSnippetData()
 {
  moc.persistAndWait
  {
    guard let text = photoSnippetTitle.text else {return}
    guard text != Localized.unnamedSnippet else {return}
    photoSnippet?.snippetName = text
  }
 }

 
 
 @objc func toggleAllPhotosSelection()
 {
  photoSnippet.allPhotosSelected.toggle()
 }

 
 
 func togglePhotoEditingMode()
 {
   if isEditingPhotos
   {
    //deselectAllSelectedItems()
    //allPhotosSelected = false
    
    isEditingPhotos = false
    photoCollectionView.isPhotoEditing = false
    photoCollectionView.menuTapGR.isEnabled = true
    //photoCollectionView.cellPanGR.isEnabled = false
    photoCollectionView.menuArrowSize = CGSize(width: 20.0, height: 50.0)
    photoCollectionView.menuItemSize = CGSize(width: 50.0, height: 50.0)
    
    photoCollectionView.visibleCells.filter{$0 is PhotoFolderCell}.forEach
    {
     ($0 as! PhotoFolderCell).photoCollectionView.isUserInteractionEnabled = true
    }
    
    photoSnippetToolBar.setItems(currentToolBarItems, animated: true)
   }
   else
   {
    isEditingPhotos = true
    photoCollectionView.isPhotoEditing = true
    photoCollectionView.menuTapGR.isEnabled = false
    //photoCollectionView.cellPanGR.isEnabled = true
    photoCollectionView.menuArrowSize = CGSize.zero
    photoCollectionView.menuItemSize = CGSize(width: 64.0, height: 64.0)
    photoCollectionView.dismissCellMenu()
    
    photoCollectionView.visibleCells.filter{$0 is PhotoFolderCell}.forEach
    {
      ($0 as! PhotoFolderCell).photoCollectionView.isUserInteractionEnabled = false
    }
    
    let doneItem = UIBarButtonItem(title: "⏎", style: .done, target: self, action: #selector(editPhotosPress))
    doneItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)], for: .selected)
    doneItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 33)], for: .normal)
    
    let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhotosBarButtonPress))
    
    let selectItem = UIBarButtonItem(title: allPhotosSelected ? "☆☆☆" : "★★★",
                                     style: .plain, target: self,
                                     action: #selector(toggleAllPhotosSelection))
    
    selectItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    selectItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
    selectBarButton = selectItem
    
    let flagItem = UIBarButtonItem(title: "⚑", style: .plain, target: self, action: #selector(flagPhoto))
    flagItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    flagItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
    let groupItem = UIBarButtonItem(title: "❐", style: .plain, target: self, action: #selector(groupPhoto))
    groupItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    groupItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    photoSnippetToolBar.setItems([deleteItem, flexSpace,
                                  selectItem, flexSpace,
                                  flagItem, flexSpace,
                                  groupItem, flexSpace,
                                  doneItem], animated: true)
    
   }
 }
    

 
 
 @objc func groupPhoto()
 {
  
  let ac = GroupPhotos.caseSelectorController(title: Localized.groupPhotoTitle,
                                              message: Localized.groupPhotoSelect,
                                              style: .alert) {self.photoCollectionView.photoGroupType = $0}
  
  self.present(ac, animated: true, completion: nil)
 }
 
 @IBOutlet weak var undoManagerBarButton: UIBarButtonItem!

 @IBAction func undoManagerPress(_ sender: UIBarButtonItem)
 {
  let canUndo = photoSnippet.canUndoMain
  let canRedo = photoSnippet.canRedoMain
  
  for var action in UndoManagerActions.allCases
  {
   switch action
   {
    case .undo, .undoAll, .undoTimes: action.isCaseEnabled = canUndo
    case .redo, .redoAll, .redoTimes: action.isCaseEnabled = canRedo
   }
  }
  
  
  let ac = UndoManagerActions.caseSelectorController(title: Localized.undoManagerTitle,
                                                     message: Localized.undoManagerSelect,
                                                     style: .alert)
  {
   switch $0
   {
    case .undo:        self.photoSnippet.undo()
    case .redo:        self.photoSnippet.redo()
    case .undoAll:     self.photoSnippet.undoAll()
    case .redoAll:     self.photoSnippet.redoAll()
    case .undoTimes:   self.photoSnippet.undo(3)
    case .redoTimes:   self.photoSnippet.redo(3)
   }
  }
  
  self.present(ac, animated: true, completion: nil)
  
 }
 
 
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
  photoSnippet.removeSelectedItems()
  togglePhotoEditingMode()
 }
 
    
 @objc func flagPhoto (_ sender: UIBarButtonItem)
 {
  showFlagPhotoMenu()
 }
     
 
 #if swift(>=5.1)
 
 //new segue processing style as of iOS 13 SDK
 @IBSegueAction func datePickerShow(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController?
 {
  DatePickerViewController(coder: coder, snippet: photoSnippet)
 }
 
 @IBSegueAction func priorityPickerShow(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController?
 {
  PriorityPickerViewController(coder: coder, snippet: photoSnippet)
 }

 #endif
 
 
 
 #if swift(<5.1)
 override func prepare(for segue: UIStoryboardSegue, sender: Any?)
 {
  switch segue.identifier
  {
   case "PhotoSnippetDatePicker":
    (segue.destination as! DatePickerViewController    ).editedSnippet = photoSnippet
   
   case "PhotoSnippetPriorityPicker":
    (segue.destination as! PriorityPickerViewController).editedSnippet = photoSnippet
   
   default: break
  }
 }
 #endif
    
 var isInvisiblePhotosDraged = false

}
