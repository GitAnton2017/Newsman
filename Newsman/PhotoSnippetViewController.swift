import Foundation
import UIKit
import CoreData

class PhotoSnippetViewController: UIViewController
{
    
 var newPhotos: [UIImage]!
 var oldPhotos: [UIImage]!
 var photos:    [UIImage]
 {
  get
  {
    return oldPhotos + newPhotos
  }
 }

 var snippetsVC: SnippetsViewController!
    
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
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let moc = appDelegate.persistentContainer.viewContext
  photoSnippet.tag = photoSnippetTitle.text
  for photo in newPhotos
  {
    let newPhoto = Photo(context: moc)
    let newPhotoID = UUID()
    if let photosURL = photoSnippet.photosURL, let photoURL = photosURL.appendingPathComponent(newPhotoID.uuidString)
    {
     newPhoto.url = photoURL as NSURL
    }
    newPhoto.date = Date() as NSDate
    newPhoto.photoSnippet = photoSnippet
    newPhoto.id = newPhotoID
    if let location = snippetsVC.snippetLocation
    {
     newPhoto.longitude = location.coordinate.longitude
     newPhoto.latitude  = location.coordinate.latitude
    }
    
    snippetsVC.getLocationString {location in newPhoto.location = location}
    
    photoSnippet.addToPhotos(newPhoto)
    
    if let photoData = UIImagePNGRepresentation(photo), let photoURL = newPhoto.url
    {
      try? photoData.write(to: photoURL as URL, options: [.atomic])
    }
  }
  
  appDelegate.saveContext()
        
 }
 
 @IBOutlet var photoCollectionView: UICollectionView!
    
 override func viewDidLoad()
 {
  super.viewDidLoad()
  photoCollectionView.dataSource = self
  photoSnippetTitle.inputAccessoryView = createKeyBoardToolBar()
 }
    
 override func viewWillAppear(_ animated: Bool)
 {
  super.viewWillAppear(animated)
  photoSnippetTitle.text = photoSnippet.tag
  photoCollectionView.reloadData()
    
 }
    
 override func viewWillDisappear(_ animated: Bool)
 {
  super.viewWillDisappear(animated)
  if photoSnippetTitle.isFirstResponder
  {
   photoSnippetTitle.resignFirstResponder()
  }
  savePhotoSnippetData()
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
