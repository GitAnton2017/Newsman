
import UIKit
import Foundation

class PhotoFolderCell: UICollectionViewCell
{
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let ds = PhotoFolderCollectionViewDataSource()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        photoCollectionView.dataSource = ds
        ds.photoCollectionView = photoCollectionView
        photoCollectionView.reloadData()
    }
    
    override func prepareForReuse()
    {
       super.prepareForReuse()
    }
}

class PhotoFolderCollectionView: UICollectionView
{
}

class PhotoFolderCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        spinner.startAnimating()
        super.awakeFromNib()
        photoIconView.image = nil
        imageRoundClip()
    }
    
    override func prepareForReuse()
    {
        spinner.startAnimating()
        super.prepareForReuse()
        photoIconView.image = nil
        imageRoundClip()
    }
    
    func imageRoundClip()
    {
        photoIconView.clearsContextBeforeDrawing = true
        photoIconView.layer.cornerRadius = 10.0
        photoIconView.layer.borderWidth = 1.0
        photoIconView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
        photoIconView.layer.masksToBounds = true
        
    }
    
}

class PhotoFolderCollectionViewDataSource: NSObject, UICollectionViewDataSource
{
    var photoItems: [PhotoItem]!
    weak var photoCollectionView: UICollectionView!
    var nphoto: Int = 3
    var imageSize: CGFloat
    {
     get
     {
      let width = photoCollectionView.frame.width
      let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
      let size = (width - fl.sectionInset.left - fl.sectionInset.right - fl.minimumInteritemSpacing * CGFloat(nphoto - 1)) / CGFloat(nphoto)
            
      return size
     }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCollectionViewCell", for: indexPath) as! PhotoFolderCollectionViewCell
        let photoItem = photoItems[indexPath.row]
        cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
        
        photoItem.getImage(requiredImageWidth:  imageSize)
        {(image) in
            cell.photoIconView.image = image
            cell.photoIconView.layer.contentsGravity = kCAGravityResizeAspect
            
            if let img = image
            {
                if img.size.height > img.size.width
                {
                    let r = img.size.width/img.size.height
                    cell.photoIconView.layer.contentsRect = CGRect(x: 0, y: (1 - r)/2, width: 1, height: r)
                }
                else
                {
                    let r = img.size.height/img.size.width
                    cell.photoIconView.layer.contentsRect = CGRect(x: (1 - r)/2, y: 0, width: r, height: 1)
                }
            }
            
            cell.spinner.stopAnimating()
        }
        
        
        return cell
    }
    
}
