import UIKit
import Foundation

class PhotoFolderCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    let dsGroup = DispatchGroup()
 
    var groupBusy = false
 
    var groupTaskCount: Int = 0
 
    weak var photoFolder: PhotoFolderItem!
 
    var isPhotoItemSelected: Bool = false
    {
        didSet
        {
          photoCollectionView.reloadData()
        }
    }
    var photoItemView: UIView    {return self.contentView}
    var cellFrame: CGRect     {return frame}
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var photoItems: [PhotoItem]!
 
    var nphoto: Int = 3
    
    var frameSize: CGFloat = 0
    {
        didSet
        {
          photoCollectionView.reloadData()
        }
    }
    
 
    override func awakeFromNib()
    {
    
        super.awakeFromNib()
        clearFlagMarker()
        imageRoundClip(cornerRadius: 10)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.reloadData()
     
   
    }
    
    override func prepareForReuse()
    {
    
       super.prepareForReuse()
       groupTaskCount = 0
       clearFlagMarker()
       imageRoundClip(cornerRadius: 10)
     
    
    }
 
    
}





