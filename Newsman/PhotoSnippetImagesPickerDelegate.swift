
import Foundation
import UIKit

extension PhotoSnippetViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
    let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage

    let ratio: CGFloat = 1.0/3.0

    if let image = pickedImage.resized(withPercentage: ratio)
    {
     let newPhotoItem  = PhotoItem(photoSnippet: photoSnippet, image: image, cachedImageWidth: imageSize)
     if photoCollectionView.photoGroupType == .makeGroups
     {
      photoItems2D = sectionedPhotoItems()
     }
     else
     {
      photoItems2D[0].append(newPhotoItem)
     }
    }
    
    if UIImagePickerController.isSourceTypeAvailable(.camera)
    {
     imagePickerTakeButton.isEnabled = true
     imagePickerCnxxButton.isEnabled = true
    }
    else
    {
     dismiss(animated: true, completion: nil)
    }
  }
    
}
