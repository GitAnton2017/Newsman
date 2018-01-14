import Foundation
import UIKit
import CoreData


class PhotoSnippetViewController: UIViewController
{
    
 var isEditingMode = true
 var isEditingPhotos = false
 var currentToolBarItems: [UIBarButtonItem]!
   
 override func didReceiveMemoryWarning()
 {
    super.didReceiveMemoryWarning()
    print ("out of memory")
 }
 
 func sectionedPhotoItems() -> [[PhotoItem]]
 {
   var photoItems = [[PhotoItem]]()
   if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
   {
    let sections = Set(allPhotos.map{$0.priorityFlag ?? ""}).sorted
    {
     (PhotoPriorityFlags(rawValue: $0)?.rateIndex ?? -1) <= (PhotoPriorityFlags(rawValue: $1)?.rateIndex ?? -1)
    }
    
    sections.forEach
    { title in
      photoItems.append(allPhotos.filter{($0.priorityFlag ?? "") == title}.map({PhotoItem(photo: $0)}))
    }
    
    sectionTitles = sections
    
   }
    
   return photoItems
 }

 func desectionedPhotoItems() -> [[PhotoItem]]
 {
  var photoItems = [[PhotoItem]]()
  if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
  {
   photoItems.append(allPhotos.map({PhotoItem(photo: $0)}))
  }
  sectionTitles = nil
  return photoItems
 }

 var sectionTitles: [String]? = nil
    
 lazy var photoItems2D: [[PhotoItem]] =
 {
  var photoItems = [[PhotoItem]]()
  if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
  {
    if let sortPred = GroupPhotos(rawValue: photoSnippet.grouping!)?.sortPredicate
    {
     photoItems.append(allPhotos.map({PhotoItem(photo: $0)}).sorted(by: sortPred))
    }
    else
    {
     photoItems = sectionedPhotoItems()
    }
  }
  return photoItems
 }()
    
 var photoSnippet: PhotoSnippet!
 {
  didSet
  {
    navigationItem.title = photoSnippet.tag
  }
 }
    
 @objc func doneButtonPressed ()
 {
  if photoSnippetTitle.isFirstResponder
  {
    photoSnippetTitle.resignFirstResponder()
}
 }
    
 func createKeyBoardToolBar() -> UIToolbar
 {
  let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: photoSnippetToolBar.bounds.width, height: 44))
  keyboardToolbar.backgroundColor = photoSnippetToolBar.backgroundColor
  let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
  keyboardToolbar.setItems([flexSpace,doneButton,flexSpace], animated: false)
  return keyboardToolbar
 }
    
 func savePhotoSnippetData()
 {
  photoSnippet.tag = photoSnippetTitle.text
    
  (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
 }
    
 @IBAction func editPhotosPress(_ sender: UIBarButtonItem)
 {
  togglePhotoEditingMode()
 }
 
 var allPhotosSelected = false
    
 var selectBarButton: UIBarButtonItem!
    
 @objc func toggleAllPhotosSelection()
 {
   if allPhotosSelected
   {
    allPhotosSelected = false
    selectBarButton.title = "★★★"
    if let selectedItemsPaths = photoCollectionView.indexPathsForSelectedItems
    {
     for itemIndexPath in selectedItemsPaths
     {
      photoCollectionView.deselectItem(at: itemIndexPath, animated: true)
      photoItems2D[itemIndexPath.section][itemIndexPath.row].photo.isSelected = false
      if let cell = photoCollectionView.cellForItem(at: itemIndexPath) as? PhotoSnippetCell
      {
        cell.photoIconView.alpha = 1
      }
     }
    }
   }
   else
   {
    allPhotosSelected = true
    selectBarButton.title = "☆☆☆"
    for i in 0..<photoCollectionView.numberOfSections
    {
      for j in 0..<photoCollectionView.numberOfItems(inSection: i)
      {
        photoItems2D[i][j].photo.isSelected = true
        let itemIndexPath = IndexPath(item: j, section: i)
        photoCollectionView.selectItem(at: itemIndexPath, animated: true, scrollPosition: .top)
        if let cell = photoCollectionView.cellForItem(at: itemIndexPath) as? PhotoSnippetCell
        {
          cell.photoIconView.alpha = 0.5
        }
      }
    }
    
   }
 }
 func togglePhotoEditingMode()
 {
   if isEditingPhotos
   {
    if let selectedItemsPaths = photoCollectionView.indexPathsForSelectedItems
    {
     for itemIndexPath in selectedItemsPaths
     {
      photoCollectionView.deselectItem(at: itemIndexPath, animated: true)
      photoItems2D[itemIndexPath.section][itemIndexPath.row].photo.isSelected = false
      if let cell = photoCollectionView.cellForItem(at: itemIndexPath) as? PhotoSnippetCell
      {
       cell.photoIconView.alpha = 1
      }
     }
    }
    allPhotosSelected = false
    isEditingPhotos = false
    photoCollectionView.isPhotoEditing = false
    photoCollectionView.menuTapGR.isEnabled = true
    photoCollectionView.menuArrowSize = CGSize(width: 20.0, height: 50.0)
    photoCollectionView.menuItemSize = CGSize(width: 50.0, height: 50.0)
    
    photoSnippetToolBar.setItems(currentToolBarItems, animated: true)
   }
   else
   {
    isEditingPhotos = true
    photoCollectionView.isPhotoEditing = true
    photoCollectionView.menuTapGR.isEnabled = false
    photoCollectionView.menuArrowSize = CGSize.zero
    photoCollectionView.menuItemSize = CGSize(width: 64.0, height: 64.0)
    photoCollectionView.dismissCellMenu()
    
    let doneItem = UIBarButtonItem(title: "⏎", style: .done, target: self, action: #selector(editPhotosPress))
    doneItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .selected)
    doneItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 33)], for: .normal)
    
    let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhotosBarButtonPress))
    
    let selectItem = UIBarButtonItem(title: "★★★", style: .plain, target: self, action: #selector(toggleAllPhotosSelection))
    selectItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    selectItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
    selectBarButton = selectItem
    
    let flagItem = UIBarButtonItem(title: "⚑", style: .plain, target: self, action: #selector(flagPhoto))
    flagItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    flagItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
    let groupItem = UIBarButtonItem(title: "❐", style: .plain, target: self, action: #selector(groupPhoto))
    groupItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 33)], for: .selected)
    groupItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 35)], for: .normal)
    
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
    let loc_title = NSLocalizedString("Group Photos", comment: "Group Photos Alerts Title")
    let loc_message = NSLocalizedString("Please select photo grouping type", comment: "Group Photos Alerts Message")
    let groupAC = UIAlertController(title: loc_title, message: loc_message, preferredStyle: .alert)
    
    for grouping in GroupPhotos.groupingTypes
    {
        let loc_gr_title = NSLocalizedString(grouping.rawValue, comment: grouping.rawValue)
        let action = UIAlertAction(title: loc_gr_title, style: .default)
        { _ in
            self.photoCollectionView.photoGroupType = grouping
    
        }
        groupAC.addAction(action)
    }
    
    let loc_cnx_title = NSLocalizedString("CANCEL",comment: "Cancel Alert Action")
    let cancel = UIAlertAction(title: loc_cnx_title, style: .cancel, handler: nil)
    
    groupAC.addAction(cancel)
    
    self.present(groupAC, animated: true, completion: nil)
 }
    
 @IBOutlet weak var photoCollectionView: PhotoSnippetCollectionView!
  
 var menuTapGR: UITapGestureRecognizer!
    
 override func viewDidLoad()
 {
  super.viewDidLoad()
  navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
  nphoto = Int(photoSnippet.nphoto)
  photoCollectionView.dataSource = self
  photoCollectionView.delegate = self
  photoCollectionView.allowsMultipleSelection = true
  imagePicker.delegate = self
  photoSnippetTitle.inputAccessoryView = createKeyBoardToolBar()
  currentToolBarItems = photoSnippetToolBar.items
  photoScaleStepper.value = Double(nphoto)
  photoScaleStepper.minimumValue = Double(minPhotosInRow)
  photoScaleStepper.maximumValue = Double(maxPhotosInRow)
  photoScaleStepper.stepValue = 1.0
  photoScaleStepper.wraps = true
  menuFrameSize = view.frame.size
    
 }

 override func viewWillAppear(_ animated: Bool)
 {
  super.viewWillAppear(animated)
  
  if isEditingMode
  {
   photoSnippetTitle.text = photoSnippet.tag
  }
  else
  {
   isEditingMode = true
  }
    
  photoCollectionView.reloadData()

 }
    
 override func viewWillDisappear(_ animated: Bool)
 {
  super.viewWillDisappear(animated)
  if photoSnippetTitle.isFirstResponder
  {
   photoSnippetTitle.resignFirstResponder()
  }
  if isEditingMode
  {
   savePhotoSnippetData()
  }

 }
 
 var maxPhotosInRow = 10; var minPhotosInRow = 1
    
 @IBOutlet var photoScaleStepper: UIStepper!
    
 @IBAction func photoScaleStepperChanged(_ sender: UIStepper)
 {
  nphoto = Int(sender.value)
 }
    
 @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer)
 {
  if (sender.scale > 1 && nphoto < maxPhotosInRow) {nphoto += 1}
  if (sender.scale < 1 && nphoto > minPhotosInRow) {nphoto -= 1}
 }

    
 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
 {

    super.viewWillTransition(to: size, with: coordinator)
    if !isEditingPhotos
    {
     photoCollectionView.locateCellMenu()
    }
    else if let menu = menuView
    {
      menuFrameSize = size
      menu.removeFromSuperview()
      menuView = nil
      showFlagPhotoMenu()
    }
    
    photoCollectionView.reloadData()
 }

 
    
 var imageSize: CGFloat
 {
    get
    {
      let width = photoCollectionView.frame.width
      let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
      let size = (width - fl.sectionInset.left - fl.sectionInset.right - fl.minimumInteritemSpacing * CGFloat(nphoto - 1)) / CGFloat(nphoto)
        
      return size
    }
 }

 static var menuIndexPath: IndexPath? = nil
 static var menuShift = CGPoint.zero
    
 var nphoto: Int = 3
 {
  didSet
  {
    if nphoto != oldValue
    {
     if isEditingPhotos
     {
        photoCollectionView.cancellUnfinishedMove()
     }
     else
     {
        photoCollectionView.locateCellMenu()
     }
     photoSnippet.nphoto = Int32(nphoto)
     photoCollectionView.reloadItems(at: photoCollectionView.indexPathsForVisibleItems)
     
    }
  }
 }
 
    
 @IBOutlet var photoSnippetTitle: UITextField!
    
 @IBOutlet var photoSnippetToolBar: UIToolbar!
    
 @IBOutlet var saveBarButton: UIBarButtonItem!
 @IBAction func saveBarButtonPress(_ sender: UIBarButtonItem)
 {
   if photoSnippetTitle.isFirstResponder
   {
    photoSnippetTitle.resignFirstResponder()
   }
   savePhotoSnippetData()
 }
    
 @IBOutlet var datePickerBarButton: UIBarButtonItem!
    
 @IBOutlet var takePhotoBarButton: UIBarButtonItem!

 let imagePicker = UIImagePickerController()
 var imagePickerTakeButton: UIButton!
 var imagePickerCnxxButton: UIButton!
    
    
    
 @objc func pickImageButtonPress()
 {
  imagePickerTakeButton.isEnabled = false
  imagePickerCnxxButton.isEnabled = false
  imagePicker.takePicture()
 }
  
 @objc func cancelImageButtonPress()
 {
  dismiss(animated: true, completion: nil)
 }
  
 func createImagePickerCustomView(imagePickerView: UIView)
 {
    let pickerViewHeight: CGFloat = 100.0
    let pickerView = UIView()
    pickerView.backgroundColor = UIColor.lightGray
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    imagePickerView.addSubview(pickerView)
    
    let pickerViewTopCon = pickerView.bottomAnchor.constraint(equalTo: imagePickerView.bottomAnchor)
    let pickerViewLeadingCon = pickerView.leadingAnchor.constraint(equalTo: imagePickerView.leadingAnchor)
    let pickerViewTrailingCon = pickerView.trailingAnchor.constraint(equalTo: imagePickerView.trailingAnchor)
    let pickerViewHeightCon = pickerView.heightAnchor.constraint(equalToConstant: pickerViewHeight)
    pickerViewTopCon.isActive = true
    pickerViewLeadingCon.isActive = true
    pickerViewTrailingCon.isActive = true
    pickerViewHeightCon.isActive = true
    
    let takePictureButton = UIButton()
    takePictureButton.addTarget(self, action: #selector(pickImageButtonPress), for: .touchDown)
    takePictureButton.backgroundColor = UIColor(red: 0.0, green: 0.563, blue: 0.319, alpha: 1.00)
    takePictureButton.contentMode = .center
    let titleAttrNormal =
    [
      NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 25),
      NSAttributedStringKey.foregroundColor: UIColor.black
    ]
    let takeLocal = NSLocalizedString("TAKE", comment: "Take Photo Button Title")
    let titleNormal = NSAttributedString(string: takeLocal, attributes: titleAttrNormal)
    takePictureButton.setAttributedTitle(titleNormal, for: .normal)
    let titleAttrPressed =
    [
      NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 28),
      NSAttributedStringKey.foregroundColor: UIColor.white
    ]
    let titlePressed = NSAttributedString(string: takeLocal, attributes: titleAttrPressed)
    takePictureButton.setAttributedTitle(titlePressed, for: .highlighted)

    takePictureButton.showsTouchWhenHighlighted = true
    takePictureButton.translatesAutoresizingMaskIntoConstraints = false
    pickerView.addSubview(takePictureButton)
    
    let takePictureButtonTopCon = takePictureButton.topAnchor.constraint(equalTo: pickerView.topAnchor, constant: 5)
    let takePictureButtonLeadingCon = takePictureButton.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor, constant: 5)
    let takePictureButtonBottomCon = takePictureButton.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: -5)
    let takePictureButtonWidthCon = takePictureButton.widthAnchor.constraint(equalTo: pickerView.widthAnchor, multiplier: 0.5, constant: -7.5)
    
    takePictureButtonTopCon.isActive = true
    takePictureButtonLeadingCon.isActive = true
    takePictureButtonBottomCon.isActive = true
    takePictureButtonWidthCon.isActive = true
    
    let cnxButton = UIButton()
    cnxButton.addTarget(self, action: #selector(cancelImageButtonPress), for: .touchDown)
    cnxButton.backgroundColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 0.80)
    cnxButton.contentMode = .center
    let cnxTitleAttrNormal =
    [
      NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 25),
      NSAttributedStringKey.foregroundColor: UIColor.black
    ]
    let cnxLocal = NSLocalizedString("CANCEL", comment: "Cancel Photo Button Title")
    let cnxTitleNormal = NSAttributedString(string: cnxLocal, attributes: cnxTitleAttrNormal)
    cnxButton.setAttributedTitle(cnxTitleNormal, for: .normal)
    
    let cnxTitleAttrPressed =
    [
      NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 28),
      NSAttributedStringKey.foregroundColor: UIColor.white
    ]
    let cnxTitlePressed = NSAttributedString(string: cnxLocal, attributes: cnxTitleAttrPressed)
    cnxButton.setAttributedTitle(cnxTitlePressed, for: .highlighted)
    
    cnxButton.showsTouchWhenHighlighted = true
    cnxButton.translatesAutoresizingMaskIntoConstraints = false
    pickerView.addSubview(cnxButton)
    
    let cnxButtonTopCon = cnxButton.topAnchor.constraint(equalTo: pickerView.topAnchor, constant: 5)
    let cnxButtonLeadingCon = cnxButton.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: -5)
    let cnxButtonBottomCon = cnxButton.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: -5)
    let cnxButtonWidthCon = cnxButton.widthAnchor.constraint(equalTo: pickerView.widthAnchor, multiplier: 0.5, constant: -7.5)
    
    cnxButtonTopCon.isActive = true
    cnxButtonLeadingCon.isActive = true
    cnxButtonBottomCon.isActive = true
    cnxButtonWidthCon.isActive = true

    imagePickerTakeButton = takePictureButton
    imagePickerCnxxButton = cnxButton
 }
    
 @IBAction func takePhotoBarButtonPress(_ sender: UIBarButtonItem)
 {
   isEditingMode = false
   //let imagePicker = UIImagePickerController()
   if UIImagePickerController.isSourceTypeAvailable(.camera)
   {
    imagePicker.sourceType = .camera
    imagePicker.showsCameraControls = false
    createImagePickerCustomView(imagePickerView: imagePicker.view)

   }
   else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
   {
    imagePicker.sourceType = .photoLibrary
   }
   else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
   {
    imagePicker.sourceType = .savedPhotosAlbum
   }
   else
   {
    return
   }

   present(imagePicker, animated: true, completion: nil)

 }
 
 @IBOutlet var priorityPickerBarButton: UIBarButtonItem!
    
 func deleteSelectedPhotos()
 {
  for (sectionIndex, section) in photoItems2D.enumerated().filter({$0.element.first(where: {$0.photo.isSelected}) != nil}).sorted(by: {$0.offset > $1.offset})
  {
   for (itemIndex, _) in section.enumerated().filter({$0.element.photo.isSelected}).sorted(by: {$0.offset > $1.offset})
   {
    let deletedItem = photoItems2D[sectionIndex].remove(at: itemIndex)
    deletedItem.deleteImage()
    let itemIndexPath = IndexPath(row: itemIndex, section: sectionIndex)
    photoCollectionView.deleteItems(at: [itemIndexPath])
   }
   if photoCollectionView.photoGroupType == .makeGroups
   {
    photoCollectionView.reloadSections([sectionIndex])
   }
  }
    
  for section in photoItems2D.enumerated().filter({$0.element.count == 0}).sorted(by: {$0.offset > $1.offset})
  {
    photoItems2D.remove(at: section.offset)
    sectionTitles?.remove(at: section.offset)
    photoCollectionView.deleteSections([section.offset])
  }
    
  togglePhotoEditingMode()

 }
  
 func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath
 {
  let path = photoItems2D.enumerated().lazy.map({($0.offset, $0.element.index(of: photoItem))}).first(where: {$0.1 != nil})
  return IndexPath(row: path!.1!, section: path!.0)
 }
    
 func flagGroupedSelectedPhotos(with flagStr: String?)
 {
  for item in photoItems2D.reduce([], {$0 + $1.filter({$0.photo.isSelected})})
  {
    item.photo.isSelected = false
    let itemIndexPath = photoItemIndexPath(photoItem: item)
    photoCollectionView.movePhoto(at: itemIndexPath, with: flagStr)
  }
 }
    
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
  deleteSelectedPhotos()
 }
  
 var menuView: UIView? = nil
 var menuFrameSize: CGSize!
 var menuViewOrigin: CGPoint
 {
  get
  {
    let x = (menuFrameSize.width - CGFloat(photoCollectionView.itemsInRow) * photoCollectionView.menuItemSize.width)/2
    let y = (menuFrameSize.height - ceil(CGFloat(editMenuItems.count) / CGFloat(photoCollectionView.itemsInRow)) * photoCollectionView.menuItemSize.height) / 2
    return CGPoint(x: x, y: y)
  }
 }
    
 func showFlagPhotoMenu()
 {
   if menuView != nil
   {
    closeMenuAni()
    return
   }
    
   photoCollectionView.dismissCellMenu()
   photoCollectionView.drawCellMenu(menuColor: #colorLiteral(red: 0.8855290292, green: 0.8220692608, blue: 0.755911735, alpha: 1), touchPoint: CGPoint.zero, menuItems: editMenuItems)
    
   if let menuLayer = photoCollectionView.layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer
   {
    let menuFrame = CGRect(origin: menuViewOrigin, size: menuLayer.frame.size)
    menuView = UIView(frame: menuFrame)
    let flagMenuGR = UITapGestureRecognizer(target: self, action: #selector(tapPhotoEditMenu))
    let panMenuGR =  UIPanGestureRecognizer(target: self, action: #selector(panPhotoEditMenu))
    menuView!.addGestureRecognizer(flagMenuGR)
    menuView!.addGestureRecognizer(panMenuGR)
    view.addSubview(menuView!)
    menuView!.layer.addSublayer(menuLayer)
    openMenuAni()
   }
 }
 
 var menuTouchPoint: CGPoint = CGPoint.zero
    
 @objc func panPhotoEditMenu (gr: UIPanGestureRecognizer)
 {
  guard let menu = menuView else {return}
    
  switch (gr.state)
  {
   case .began: menuTouchPoint = gr.location(in: menu)
   
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {menu.alpha = 0.85}, completion: nil)
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn, .`repeat`, .autoreverse],
                   animations:
                   {
                     menu.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                   },
                   completion: nil)
   case .changed:
    let touchPoint = gr.location(in: menu)
    let translation = gr.translation(in: menu)
    if (touchPoint.x > menuTouchPoint.x - 30  && touchPoint.y > menuTouchPoint.y - 30  &&
        touchPoint.x < menuTouchPoint.x + 30  && touchPoint.y < menuTouchPoint.y + 30)
    {
     menu.center.x += translation.x
     menu.center.y += translation.y
    }
    
    gr.setTranslation(CGPoint.zero, in: menu)
   
   default:
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut],
                   animations:
                   {
                     menu.transform = CGAffineTransform.identity
                     menu.alpha = 1.0
                   },
                   completion: nil)
   }

  }
 
  func openMenuAni()
  {
        menuView!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        menuView!.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                       animations:
                       {
                        self.menuView!.transform = CGAffineTransform.identity
                        self.menuView!.alpha = 1
                       },
                       completion: nil)
        
  }
 
 func closeMenuAni()
 {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                       animations:
                       {
                        self.menuView!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        self.menuView!.alpha = 0
                       },
                       completion:
                       {_ in
                        self.menuView!.removeFromSuperview()
                        self.menuView = nil
                       })

 }

    
 @objc func tapPhotoEditMenu (gr: UITapGestureRecognizer)
 {
  let touchPoint = gr.location(in: menuView)
  if let menuLayer = menuView!.layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer,
     let buttonLayer = menuLayer.hitTest(touchPoint)
  {
    switch (buttonLayer.name)
    {
     case "flagLayer"?:
      let flagColor = (buttonLayer as! FlagItemLayer).flagColor
      let flagStr = PhotoPriorityFlags.priorityColorMap.first(where: {$0.value == flagColor})?.key.rawValue
      if photoCollectionView.photoGroupType != .makeGroups
      {
        photoItems2D[0].enumerated().filter({$0.element.photo.isSelected}).forEach
        {
         $0.element.photo.priorityFlag = flagStr
         if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
         {
          cell.drawFlag(flagColor: flagColor!)
         }
        }
      }
      else
      {
       flagGroupedSelectedPhotos(with: flagStr)
      }
      
      togglePhotoEditingMode()
      closeMenuAni()

        
     case "unflagLayer"?:
      for section in photoItems2D
      {
       section.enumerated().filter({$0.element.photo.isSelected}).forEach
       {
        $0.element.photo.priorityFlag = nil
         if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
         {
          cell.clearFlag()
         }
       }
      }
      
      togglePhotoEditingMode()
      closeMenuAni()
    
        
     case "cnxLayer"?: closeMenuAni()
        
     default: break
        
    }
   }
 }
    
 @objc func flagPhoto (_ sender: UIBarButtonItem)
 {
    showFlagPhotoMenu()
 }
    
 override func prepare(for segue: UIStoryboardSegue, sender: Any?)
 {
  if let segueID = segue.identifier, segueID == "PhotoSnippetDatePicker"
  {
    (segue.destination as! DatePickerViewController).editedSnippet = photoSnippet
  }
  if let segueID = segue.identifier, segueID == "PhotoSnippetPriorityPicker"
  {
    (segue.destination as! PriorityPickerViewController).editedSnippet = photoSnippet
  }
        
 }
    
}
