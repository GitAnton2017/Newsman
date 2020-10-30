
import Foundation
import UIKit
import RxCocoa
import RxSwift

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
   imagePickerCnxxButton = nil
   takePictureButtonDisposable?.dispose()
   
   dismiss(animated: true)
   {
    self.photoItems2D
     .flatMap{$0}
     .filter{ $0.isJustCreated }
     .compactMap{ $0.hostingCollectionViewCell?.mainView as?  PhotoSnippetCellMainView }
     .forEach { $0.animateNewPhoto() }
     
    guard let ip = self.currentFRC?[self.photoSnippet] else { return }
    self.currentFRC?.tableView.reloadRows(at: [ip], with: .automatic)
    self.currentFRC?.activateDelegate()
   }
  }
 
 
  @IBAction func takePhotoBarButtonPress(_ sender: UIBarButtonItem)
  {
   isEditingMode = false
   isTakePictureReady = true
   
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
   
   present(imagePicker, animated: true)
   {
    self.currentFRC?.deactivateDelegate()
   }
   
  }
 
 
  func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
  {
   defer
   {
    isTakePictureReady = true
    imagePickerTakeButton.isEnabled = true
    imagePickerCnxxButton.isEnabled = true
   }
   
   // Local variable inserted by Swift 4.2 migrator.
   let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

   guard let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {return}
   
   
   PhotoItem.createNewPhoto(in: photoSnippet, with: pickedImage, ofRequiredSize: imageSize)
   {[ weak self ] photoItem in
    guard let newPhotoItem = photoItem else { return }
    self?.insertNewPhotoItem(newPhotoItem, with: BatchAnimationOptions.withSmallJump(0.35))
    
    var cnxxButtonDisposable: Disposable?
    let unselectObservable = Observable.just(newPhotoItem)
     .delay(.seconds(15), scheduler: MainScheduler.instance)
     .do(onNext: {
      $0.isSelected = false
      $0.isJustCreated = false
      cnxxButtonDisposable?.dispose()
     })
    
    guard let cnxxButton = self?.imagePickerCnxxButton else
    {
     cnxxButtonDisposable = unselectObservable
      .debug("<<< IMAGE PICKER CNXX AFTER PRESS >>>")
      .subscribe()
     return
    }
    
    cnxxButtonDisposable = cnxxButton.rx
     .controlEvent([.touchDown])
     .flatMap{ _ in unselectObservable }
     .debug("<<< IMAGE PICKER CNXX BUTTON PRESSED >>>")
     .subscribe()
     
   }
   
  
   
  }
    

 private final func takePhoto()
 {
  guard isTakePictureReady else { return }
  imagePickerTakeButton.isEnabled = false
  imagePickerCnxxButton.isEnabled = false
  isTakePictureReady = false
  imagePicker.takePicture()
  
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
  
    takePictureButtonDisposable = takePictureButton.rx
     .controlEvent([.touchDown])
     .do(onNext: { [ weak self ] _ in self?.takePhoto()})
     .flatMap{ _ in
      Observable<Int>.interval(.milliseconds(250), scheduler: MainScheduler.instance)
       .filter{[ weak self ] _ in self?.isTakePictureReady ?? false }
       .takeUntil(takePictureButton.rx.controlEvent([ .touchUpInside, .touchCancel ]))
       .do(onNext: {[ weak self ] _ in self?.takePhoto()})
    }.subscribe()
  
   
//    takePictureButton.addTarget(self, action: #selector(pickImageButtonPress), for: .touchDown)
    takePictureButton.backgroundColor = UIColor(red: 0.0, green: 0.563, blue: 0.319, alpha: 1.00)
    takePictureButton.contentMode = .center
    let titleAttrNormal =
    [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25),
            NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    let takeLocal = NSLocalizedString("TAKE", comment: "Take Photo Button Title")
    let titleNormal = NSAttributedString(string: takeLocal, attributes: titleAttrNormal)
    takePictureButton.setAttributedTitle(titleNormal, for: .normal)
    let titleAttrPressed =
        [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 28),
            NSAttributedString.Key.foregroundColor: UIColor.white
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
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25),
            NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    let cnxLocal = NSLocalizedString("CANCEL", comment: "Cancel Photo Button Title")
    let cnxTitleNormal = NSAttributedString(string: cnxLocal, attributes: cnxTitleAttrNormal)
    cnxButton.setAttributedTitle(cnxTitleNormal, for: .normal)
    
    let cnxTitleAttrPressed =
    [
      NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 28),
      NSAttributedString.Key.foregroundColor: UIColor.white
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
