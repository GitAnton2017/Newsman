import UIKit
import Foundation
import CoreData

class PhotoSnippetCell: UICollectionViewCell
{
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        spinner.startAnimating()
        super.awakeFromNib()
    }
    
    override func prepareForReuse()
    {
        spinner.startAnimating()
        super.prepareForReuse()
    }
}
