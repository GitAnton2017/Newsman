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
       if let flag = photoItems[itemIndexPath.row].photo.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
       {
         cell.drawFlag(flagColor: color)
       }
      }
     }
    }
    allPhotosSelected = false
    isEditingPhotos = false
    
    photoSnippetToolBar.setItems(currentToolBarItems, animated: true)
   }
   else
   {
    isEditingPhotos = true
    
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
 @IBOutlet weak var photoCollectionView: UICollectionView!
    
 override func viewDidLoad()
 {
  super.viewDidLoad()
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
  if (sender.scale > 1 && nphoto < maxPhotosInRow)
  {
    nphoto += 1
  }
    
  if (sender.scale < 1 && nphoto > minPhotosInRow)
  {
    nphoto -= 1
  }
 }

 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
 {
    super.viewWillTransition(to: size, with: coordinator)
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
    
 var nphoto: Int = 3
 {
  didSet
  {
    if nphoto != oldValue
    {
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
    
    
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
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
   
 func setPhotoPriorityFlags(NFlags: Int)
 {
  let flagStr = PhotoPriorityFlags.priorities[NFlags].rawValue
  photoItems.filter({$0.photo.isSelected}).forEach
  {
    $0.photo.priorityFlag = flagStr
  }
 }
    
    
 @objc func flagPhoto (_ sender: UIBarButtonItem)
 {
    let loc_title = NSLocalizedString("Photo Priority Flag", comment: "Setting Photo Priority Flags")
    let loc_message = NSLocalizedString("Please set photo priority flag!", comment: "Priority Flag Selection Alerts")
    let prioritySelect = UIAlertController(title: loc_title, message: loc_message, preferredStyle: .alert)
    let maxFlags = PhotoPriorityFlags.priorities.count
    
    for i in 0..<maxFlags
    {
     let action = UIAlertAction(title: String(repeating: "🚩", count: maxFlags - i), style: .default)
        { _ in
            self.setPhotoPriorityFlags(NFlags: i)
            self.togglePhotoEditingMode()
        }
        prioritySelect.addAction(action)
    }
    
    let loc_cnx_title = NSLocalizedString("CANCEL", comment: "Cancel Alert Action")
    let cancelAction = UIAlertAction(title: loc_cnx_title , style: .cancel, handler: nil)
    
    prioritySelect.addAction(cancelAction)
    
    self.present(prioritySelect, animated: true, completion: nil)
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
