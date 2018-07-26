
import Foundation
import UIKit

class SnippetsViewCell: UITableViewCell
{
 
 
    @IBOutlet var snippetTextTag: UILabel!
    @IBOutlet var snippetDateTag: UILabel!
    @IBOutlet var snippetImage: UIImageView!
    @IBOutlet var imageSpinner: UIActivityIndicatorView!
 
 
    override func awakeFromNib()
    {
     snippetImage.layer.cornerRadius = 3.5
     snippetImage.layer.borderWidth = 1.25
     snippetImage.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
     snippetImage.layer.masksToBounds = true
     
    }
    override func prepareForReuse()
    {
     super.prepareForReuse()
     snippetImage.layer.removeAllAnimations()
     imageSpinner.startAnimating()
     snippetImage.image = nil
   
    }
}
