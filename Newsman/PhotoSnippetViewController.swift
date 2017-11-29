import Foundation
import UIKit
import CoreData

class PhotoSnippetViewController: UIViewController
{
    
 var isEditingMode = true
    
 let cache = (UIApplication.shared.delegate as! AppDelegate).photoCache

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
 
 @IBOutlet var photoCollectionView: UICollectionView!
    
 override func viewDidLoad()
 {
  super.viewDidLoad()
  photoCollectionView.dataSource = self
  photoCollectionView.delegate = self
  photoCollectionView.allowsSelection = true
  photoCollectionView.allowsMultipleSelection = true
  photoSnippetTitle.inputAccessoryView = createKeyBoardToolBar()
 
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
    
 @IBOutlet var deletePhotosBarButton: UIBarButtonItem!
 @IBAction func deletePhotosBarButtonPress(_ sender: UIBarButtonItem)
 {
    
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
