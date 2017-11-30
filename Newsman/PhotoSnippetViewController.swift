import Foundation
import UIKit
import CoreData

class PhotoSnippetViewController: UIViewController
{
    
 var isEditingMode = true
 var isEditingPhotos = false
    
 var currentToolBarItems: [UIBarButtonItem]!
    
 let cache = (UIApplication.shared.delegate as! AppDelegate).photoCache
    
 var photos: [PhotoPair]
 {
  get
  {
    return cache.getPhotos(photoSnippet: photoSnippet)
  }
 }

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
    selectBarButton.title = "Select"
    if let selectedItemsPaths = photoCollectionView.indexPathsForSelectedItems
    {
     for itemIndexPath in selectedItemsPaths
     {
      photoCollectionView.deselectItem(at: itemIndexPath, animated: true)
     (photoCollectionView.cellForItem(at: itemIndexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
     }
    }
   }
   else
   {
    allPhotosSelected = true
    selectBarButton.title = "Unselect"
    for i in 0..<photoCollectionView.numberOfSections
    {
      for j in 0..<photoCollectionView.numberOfItems(inSection: i)
      {
        let itemIndexPath = IndexPath(item: j, section: i)
        photoCollectionView.selectItem(at: itemIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        (photoCollectionView.cellForItem(at: itemIndexPath) as! PhotoSnippetCell).photoIconView.alpha = 0.5
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
      (photoCollectionView.cellForItem(at: itemIndexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
     }
    }
    allPhotosSelected = false
    isEditingPhotos = false
    photoCollectionView.allowsMultipleSelection = false
    
    photoSnippetToolBar.setItems(currentToolBarItems, animated: true)
   }
   else
   {
    isEditingPhotos = true
    photoCollectionView.allowsMultipleSelection = true
    let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editPhotosPress))
    let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhotosBarButtonPress))
    let selectItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(toggleAllPhotosSelection))
    selectBarButton = selectItem
    //let priorityItem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(changeSelectedSnippetsPriority))
    //let priorityItem = UIBarButtonItem(image: UIImage(named: "priority.tab.icon"), style: .plain, target: self, action: #selector(changeSelectedSnippetsPriority))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    photoSnippetToolBar.setItems([deleteItem, flexSpace, selectItem, flexSpace, doneItem], animated: true)
    
   }
 }
 @IBOutlet var photoCollectionView: UICollectionView!
    
 override func viewDidLoad()
 {
  super.viewDidLoad()
  photoCollectionView.dataSource = self
  photoCollectionView.delegate = self
  photoSnippetTitle.inputAccessoryView = createKeyBoardToolBar()
  currentToolBarItems = photoSnippetToolBar.items
 
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
 
 func updateLayout()
 {
  let width = photoCollectionView.collectionViewLayout.collectionViewContentSize.width
  let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  let size = (width - fl.sectionInset.left - fl.sectionInset.right - fl.minimumInteritemSpacing * CGFloat(nphoto - 1)) / CGFloat(nphoto)
        
  fl.itemSize.width = size
  fl.itemSize.height = size
        
 }
    
 var maxPhotosInRow = 10
 var minPhotosInRow = 1
    
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
    
 var nphoto: Int = 3
 {
  didSet
  {
    updateLayout()
  }
 }
 override func viewDidLayoutSubviews()
 {
  super.viewDidLayoutSubviews()
  updateLayout()
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
    
 @IBAction func takePhotoBarButtonPress(_ sender: UIBarButtonItem)
 {
   isEditingMode = false
   let imagePicker = UIImagePickerController()
   if UIImagePickerController.isSourceTypeAvailable(.camera)
   {
    imagePicker.sourceType = .camera
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
   imagePicker.delegate = self

   present(imagePicker, animated: true, completion: nil)

 }
 
 @IBOutlet var priorityPickerBarButton: UIBarButtonItem!
    
    
 @objc func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
    if let selectedItemsPaths = photoCollectionView.indexPathsForSelectedItems
    {
        for itemIndexPath in selectedItemsPaths.sorted(by: {$0.row > $1.row})
        {
          let photoToDelete = photos[itemIndexPath.row]
          cache.deletePhoto(photoSnippet: photoSnippet, photo: photoToDelete)
          photoCollectionView.deleteItems(at: [itemIndexPath])
        }
        
        togglePhotoEditingMode()
    }
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
