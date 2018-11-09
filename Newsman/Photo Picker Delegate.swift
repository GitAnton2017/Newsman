
import Foundation
import UIKit

extension PhotoSnippetViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
  @objc func pickImageButtonPress()
  {
   imagePickerTakeButton.isEnabled = false
   imagePickerCnxxButton.isEnabled = false
   imagePicker.takePicture()
  }
 
  @objc func cancelImageButtonPress()
  {
   dismiss(animated: true)
   {
    guard let ip = self.currentFRC?[self.photoSnippet] else {return}
    self.currentFRC?.tableView.reloadRows(at: [ip], with: .automatic)
    self.currentFRC?.activateDelegate()
   }
  }
 
 
  @IBAction func takePhotoBarButtonPress(_ sender: UIBarButtonItem)
  {
   isEditingMode = false
   
   if SnippetType(rawValue: photoSnippet.type!)! == .video
   {
    showVideoShootingController ()
    return
   }
   
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
   
   present(imagePicker, animated: true) {self.currentFRC?.deactivateDelegate()}
   
  }
 
 
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
   guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
   
   PhotoItem.createNewPhoto(in: photoSnippet, with: pickedImage, ofRequiredSize: imageSize)
   {photoItem in
    guard let newPhotoItem = photoItem else {return}
    self.insertNewPhotoItem(newPhotoItem)
   }
   
   imagePickerTakeButton.isEnabled = true
   imagePickerCnxxButton.isEnabled = true
   
  }
    
//MARK:------------------------------- CREATING PHOTO PICKER CUSTOM MENU -----------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
 func createImagePickerCustomView(imagePickerView: UIView)
//----------------------------------------------------------------------------------------------------------------------
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
 }//func createImagePickerCustomView(imagePickerView: UIView)...
//----------------------------------------------------------------------------------------------------------------------------
//MARK: -
}
