import UIKit

class PhotoFolderCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
 
 weak var hostedPhotoItem: PhotoItem?
 
 func cancelImageOperations()
 {
  hostedPhotoItem?.cancelImageOperation()
 }
 
 var photoItemView: UIView {return self.contentView}
 
 var cellFrame: CGRect     {return self.frame}
 
 var isPhotoItemSelected: Bool = false
 
 @IBOutlet weak var photoIconView: UIImageView!
 @IBOutlet weak var spinner: UIActivityIndicatorView!
 
 override func awakeFromNib()
 {
  super.awakeFromNib()
  
  spinner.startAnimating()
  hostedPhotoItem = nil
  photoIconView.image = nil
  imageRoundClip(cornerRadius: 5)
 }
 
 override func prepareForReuse()
 {
  super.prepareForReuse()
  hostedPhotoItem = nil
  spinner.startAnimating()
  photoIconView.image = nil
  imageRoundClip(cornerRadius: 5)
 }
 
 
 
 
}
