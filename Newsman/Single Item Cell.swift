import UIKit
import Foundation

class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    func cancelImageOperations()
    {
     hostedPhotoItem?.cancelImageOperation()
    }
 
    weak var hostedPhotoItem: PhotoItem?
 
    var isPhotoItemSelected: Bool
    {
      set {photoIconView.alpha = newValue ? 0.5 : 1}
      get {return photoIconView.alpha == 0.5       }
    }
 
    var photoItemView: UIView {return self.contentView}
    var cellFrame: CGRect     {return self.frame}
 
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        hostedPhotoItem = nil
     
        spinner.startAnimating()
        photoIconView.image = nil
        clearFlagMarker()
        clearVideoDuration()
        hidePlayIcon()
        imageRoundClip(cornerRadius: 10)
        addObserver(self, forKeyPath: #keyPath(PhotoSnippetCell.bounds), options: [.new], context: nil)
        
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
       
        hostedPhotoItem = nil
        spinner.startAnimating()
        photoIconView.image = nil
        clearFlagMarker()
        clearVideoDuration()
        hidePlayIcon()
        imageRoundClip(cornerRadius: 10)
     
    }
 
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
      if keyPath == #keyPath(PhotoSnippetCell.bounds)
      {
      }
    }
 
    deinit
    {
     removeObserver(self, forKeyPath: #keyPath(PhotoSnippetCell.bounds))
    }
    
    
}


