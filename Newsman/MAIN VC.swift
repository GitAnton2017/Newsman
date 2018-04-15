
import Foundation
import UIKit
import CoreData

class PhotoSnippetViewController: UIViewController
{
    
    
//MARK: ===================== CALCULATED PROPERTIES =========================
    
//---------------------------------------------------------------------------
 var photoSnippet: PhotoSnippet!
//---------------------------------------------------------------------------
 {
  didSet {navigationItem.title = photoSnippet.tag}
 }
//---------------------------------------------------------------------------
 var imageSize: CGFloat
//---------------------------------------------------------------------------
 {
  let width = photoCollectionView.frame.width
  let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  let lelfInset =  fl.sectionInset.left
  let rightInset = fl.sectionInset.right
  let itemSpace =  fl.minimumInteritemSpacing
  let size = (width - lelfInset - rightInset - itemSpace * CGFloat(nphoto - 1)) / CGFloat(nphoto)
  return trunc (size) 
 }
//---------------------------------------------------------------------------
 var nphoto: Int = 3
//---------------------------------------------------------------------------
 {
  didSet
  {

     if isEditingPhotos
     {
      //photoCollectionView.cancellUnfinishedMove()
     }
     else
     {
      photoCollectionView.locateCellMenu()
     }
     
     photoSnippet.nphoto = Int32(nphoto)
     //let visibleCells = photoCollectionView.indexPathsForVisibleItems
     //photoCollectionView.reloadItems(at: visibleCells)
   
     photoCollectionView.reloadData()
    
    /*photoCollectionView.visibleCells.filter{$0 is PhotoFolderCell}.forEach
    {
        ($0 as! PhotoFolderCell).photoCollectionView.reloadData()
    }*/
     
    
   }
 }
    
//---------------------------------------------------------------------------------
    
//MARK: ========================== STORED PROPERTIES ==============================
    
 var isEditingMode = true
 var isEditingPhotos = false
 var currentToolBarItems: [UIBarButtonItem]!
 var allPhotosSelected = false
 var selectBarButton: UIBarButtonItem!
 var menuTapGR: UITapGestureRecognizer!
 var maxPhotosInRow = 10
 var minPhotosInRow = 1
 let nPhotoFolderMap = [10: 2, 9: 2, 8: 2, 7: 2, 6: 2, 5: 2, 4: 3, 3: 4, 2: 5, 1: 6]
 var sectionTitles: [String]? = nil //section titles for sectioned photo collection view if any...
    
 var menuView: UIView? = nil
 var menuFrameSize: CGSize!
 var menuTouchPoint: CGPoint = CGPoint.zero
    
 static var menuIndexPath: IndexPath? = nil // CV index path where small photo item menu appeares...
 static var menuShift = CGPoint.zero


 let imagePicker = UIImagePickerController()
 var imagePickerTakeButton: UIButton!
 var imagePickerCnxxButton: UIButton!
    
 lazy var photoItems2D: [[PhotoItemProtocol]] = createPhotoItems2D()
    
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
 
//---------------------------------------------------------------------------------
//MARK: -
    
    
//MARK: =============== LOAD PHOTO SNIPPET VIEW CONTROLLER VIEW ===================
//=================================================================================
 override func viewDidLoad()
//=================================================================================
 {
   super.viewDidLoad()
   navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
   nphoto = Int(photoSnippet.nphoto)
   photoCollectionView.dataSource = self
   photoCollectionView.delegate = self
   
   photoCollectionView.dragDelegate = self
   photoCollectionView.dropDelegate = self
   photoCollectionView.dragInteractionEnabled = true
   
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
//==========================================================================================
//MARK:-
    
    
//MARK: ------------------------- VIEW WILL APPEAR --------------------------
//---------------------------------------------------------------------------
 override func viewWillAppear(_ animated: Bool)
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
//MARK:-
    
    
//MARK: ------------------------- VIEW WILL DISAPPEAR -----------------------
//---------------------------------------------------------------------------
 override func viewWillDisappear(_ animated: Bool)
//---------------------------------------------------------------------------
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

  /*if !photoCollectionView.hasActiveDrag
   {
    deselectSelectedItems(in: photoCollectionView)
   }*/
    
   //PhotoItem.imageCacheDict.values.forEach{$0.removeAllObjects()}
 }
//---------------------------------------------------------------------------
//MARK:-
    
//MARK:======================== ACTIONS OUTLETS =============================
//---------------------------------------------------------------------------
 @IBAction func photoScaleStepperChanged(_ sender: UIStepper)
//---------------------------------------------------------------------------
 {
  nphoto = Int(sender.value)
 }
//---------------------------------------------------------------------------
 @IBAction func editPhotosPress(_ sender: UIBarButtonItem)
//---------------------------------------------------------------------------
{
 togglePhotoEditingMode()
}
//---------------------------------------------------------------------------
 @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer)
//---------------------------------------------------------------------------
{
 if (sender.scale > 1 && nphoto < maxPhotosInRow) {nphoto += 1}
 if (sender.scale < 1 && nphoto > minPhotosInRow) {nphoto -= 1}
}
//---------------------------------------------------------------------------
 @IBAction func saveBarButtonPress(_ sender: UIBarButtonItem)
//---------------------------------------------------------------------------
 {
    if photoSnippetTitle.isFirstResponder
    {
        photoSnippetTitle.resignFirstResponder()
    }
    
    savePhotoSnippetData()
 }
//---------------------------------------------------------------------------
 @IBAction func takePhotoBarButtonPress(_ sender: UIBarButtonItem)
//---------------------------------------------------------------------------
 {
    isEditingMode = false
    
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
//---------------------------------------------------------------------------
//MARK: -
    
 deinit
 {
  print ("VC DESTROYED WITH PHOTO SNIPPET \(photoSnippet.tag ?? "no tag")")
 }
    
//MARK: ----------------- MEMORY WARNING PROCESSING -------------------------
//---------------------------------------------------------------------------
 override func didReceiveMemoryWarning()
//---------------------------------------------------------------------------
 {
    super.didReceiveMemoryWarning()
    PhotoItem.imageCacheDict.values.forEach{$0.removeAllObjects()}
    print ("MEMORY LOW!")
 }
//---------------------------------------------------------------------------
//MARK:-
    
//MARK: ------------- Dismiss Title Edit Key Board --------------------------
//---------------------------------------------------------------------------
 @objc func doneButtonPressed ()
//---------------------------------------------------------------------------
 {
  if photoSnippetTitle.isFirstResponder
  {
    photoSnippetTitle.resignFirstResponder()
  }
 }
//---------------------------------------------------------------------------
//MARK: -

    
//MARK: ------------- PREPARING PHOTO SNIPPET TOOLBAR -----------------------
//---------------------------------------------------------------------------
 func createKeyBoardToolBar() -> UIToolbar
//---------------------------------------------------------------------------
 {
  let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: photoSnippetToolBar.bounds.width, height: 44))
  keyboardToolbar.backgroundColor = photoSnippetToolBar.backgroundColor
  let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
  keyboardToolbar.setItems([flexSpace,doneButton,flexSpace], animated: false)
  return keyboardToolbar
 }
//---------------------------------------------------------------------------
//MARK: -

    
//MARK: -------------- Saving Current Managed Context -----------------------
//---------------------------------------------------------------------------
 func savePhotoSnippetData()
//---------------------------------------------------------------------------
 {
  photoSnippet.tag = photoSnippetTitle.text
  (UIApplication.shared.delegate as! AppDelegate).saveContext()
 }
//---------------------------------------------------------------------------
//MARK: -

    
//MARK: -------------- Toggle All Photos Selection Mode ----------------------
//---------------------------------------------------------------------------
 @objc func toggleAllPhotosSelection()
//---------------------------------------------------------------------------
 {
   if allPhotosSelected
   {
    allPhotosSelected = false
    selectBarButton.title = "★★★"
    deselectSelectedItems(in: photoCollectionView)
   }
   else
   {
    allPhotosSelected = true
    selectBarButton.title = "☆☆☆"
    selectAllPhotoItems(in: photoCollectionView)
   }
 }
//---------------------------------------------------------------------------
//MARK: -
    
    
//MARK: -------------- Toggle Photo Items Editing Mode ----------------------
//---------------------------------------------------------------------------
 func togglePhotoEditingMode()
//---------------------------------------------------------------------------
 {
   if isEditingPhotos
   {
    deselectSelectedItems(in: photoCollectionView)
    allPhotosSelected = false
    isEditingPhotos = false
    photoCollectionView.isPhotoEditing = false
    photoCollectionView.menuTapGR.isEnabled = true
    photoCollectionView.cellPanGR.isEnabled = false
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
    photoCollectionView.cellPanGR.isEnabled = true
    photoCollectionView.menuArrowSize = CGSize.zero
    photoCollectionView.menuItemSize = CGSize(width: 64.0, height: 64.0)
    photoCollectionView.dismissCellMenu()
    
    photoCollectionView.visibleCells.filter{$0 is PhotoFolderCell}.forEach
    {
      ($0 as! PhotoFolderCell).photoCollectionView.isUserInteractionEnabled = false
    }
    
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
    
//---------------------------------------------------------------------------
//MARK: -
 
    
//MARK: --------------------------- GROUP PHOTO  ----------------------------
//---------------------------------------------------------------------------
 @objc func groupPhoto()
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
//MARK: -

//MARK: --------------------------- VC TRANSITIONS  -------------------------
//---------------------------------------------------------------------------
 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
//---------------------------------------------------------------------------
 {

    print ("NEW SIZE \(size)")
    print ("NEW VC VIEW \(view.frame)")
    
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
    
    /*if traitCollection.userInterfaceIdiom == .pad,
       let zv = photoCollectionView.zoomView
    {
        zv.center = CGPoint (x: size.width/2 , y: size.height/2 - view.frame.origin.x)
    }*/
    
    photoCollectionView.reloadData()
 }
//---------------------------------------------------------------------------
//MARK: -
 
   
    
     
//MARK: ---------------- IMAGE PICKER CONTROLLER PREPARE --------------------
//---------------------------------------------------------------------------
 @objc func pickImageButtonPress()
//---------------------------------------------------------------------------
 {
  imagePickerTakeButton.isEnabled = false
  imagePickerCnxxButton.isEnabled = false
  imagePicker.takePicture()
 }
//---------------------------------------------------------------------------
 @objc func cancelImageButtonPress()
//---------------------------------------------------------------------------
 {
  dismiss(animated: true, completion: nil)
 }
//---------------------------------------------------------------------------

    
 /*func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath
 {
  let path = photoItems2D.enumerated().lazy.map{($0.offset, $0.element.index(of: photoItem))}.first {$0.1 != nil}
  return IndexPath(row: path!.1!, section: path!.0)
 }*/

    
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
  deleteSelectedPhotos()
  togglePhotoEditingMode()
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
    
 var isInvisiblePhotosDraged = false

 
    
}
