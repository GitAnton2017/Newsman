
import Foundation
import UIKit

class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    func cancelImageOperations()
    {
     
    }
 
 
    var photoItemView: UIView {return self.contentView}
 
    var cellFrame: CGRect {return self.frame}
 
    var isPhotoItemSelected: Bool = false
 
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
     
        spinner.startAnimating()
        photoIconView.image = nil
        imageRoundClip(cornerRadius: 10)
 
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
     
        spinner.startAnimating()
        photoIconView.image = nil
        imageRoundClip(cornerRadius: 10)
    }
}
