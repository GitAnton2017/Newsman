
import Foundation
import UIKit

class ZoomViewCollectionViewCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
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
        imageRoundClip()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        spinner.startAnimating()
        photoIconView.image = nil
        imageRoundClip()
    }
    
    
    
    func imageRoundClip()
    {
        photoIconView.clearsContextBeforeDrawing = true
        photoIconView.layer.cornerRadius = 2
        photoIconView.layer.borderWidth = 1.0
        photoIconView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
        photoIconView.layer.masksToBounds = true
        
    }
    
}
