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
    
 lazy var photoItems: [PhotoItem] =
 {
    var photoItems = [PhotoItem]()
    let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
    if let allPhotos = photoSnippet.photos?.sortedArray(using: [sort]) as? [Photo]
    {
     for photo in allPhotos
     {
      let newPhotoItem = PhotoItem(photo: photo)
      photoItems.append(newPhotoItem)
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
  if photoSnippetTitle.isFirstResponder {photoSnippetTitle.resignFirstResponder()}
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
      photoItems[itemIndexPath.row].photo.isSelected = false
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
        photoItems[j].photo.isSelected = true
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
      photoItems[itemIndexPath.row].photo.isSelected = false
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
    
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    photoSnippetToolBar.setItems([deleteItem, flexSpace, selectItem, flexSpace, flagItem, flexSpace, doneItem], animated: true)
    
   }
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
    else
    {
      menuFrameSize = size
      menuView?.removeFromSuperview()
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
     if !isEditingPhotos {photoCollectionView.locateCellMenu()}
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
    for item in photoItems.filter({$0.photo.isSelected})
    {
        let index = photoItems.index(of: item)
        let deletedItem = photoItems.remove(at: index!)
        deletedItem.deleteImage()
        let itemIndexPath = IndexPath(row: index!, section: 0)
        photoCollectionView.deleteItems(at: [itemIndexPath])
    }
    
    togglePhotoEditingMode()
 }
    
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
  deleteSelectedPhotos()
 }

 func setPhotoPriorityFlags(NFlags: Int)
 {
  let flagStr = PhotoPriorityFlags.priorities[NFlags].rawValue
  photoItems.filter({$0.photo.isSelected}).forEach
  {
    $0.photo.priorityFlag = flagStr
  }
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
    menuView?.removeFromSuperview()
    menuView = nil
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
   }
 }
 
 var menuTouchPoint: CGPoint = CGPoint.zero
    
 @objc func panPhotoEditMenu (gr: UIPanGestureRecognizer)
 {
  guard let menu = menuView else {return}
    
  switch (gr.state)
  {
   case .began: menuTouchPoint = gr.location(in: menu)
   case .changed:
    let touchPoint = gr.location(in: menu)
    let translation = gr.translation(in: menu)
    if (touchPoint.x > menuTouchPoint.x - 20  && touchPoint.y > menuTouchPoint.y - 20  &&
        touchPoint.x < menuTouchPoint.x + 20  && touchPoint.y < menuTouchPoint.y + 20)
    {
     menu.center.x += translation.x
     menu.center.y += translation.y
    }
    
    gr.setTranslation(CGPoint.zero, in: menu)
   
    default: break
   }

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
      photoItems.enumerated().filter({$0.element.photo.isSelected}).forEach
      {
        $0.element.photo.priorityFlag = flagStr
        if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
        {
         cell.drawFlag(flagColor: flagColor!)
        }
      }
      
      togglePhotoEditingMode()
      menuView!.removeFromSuperview()
      menuView = nil
        
     case "unflagLayer"?:
      photoItems.enumerated().filter({$0.element.photo.isSelected}).forEach
      {
        $0.element.photo.priorityFlag = nil
         if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
         {
          cell.clearFlag()
         }
      }
      
      togglePhotoEditingMode()
      menuView!.removeFromSuperview()
      menuView = nil
        
     case "cnxLayer"?:
      menuView!.removeFromSuperview()
      menuView = nil
        
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
