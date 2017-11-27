
import Foundation
import UIKit

extension PhotoSnippetViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
    let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    newPhotos.append(pickedImage)
    dismiss(animated: true, completion: nil)
  }
    
}
