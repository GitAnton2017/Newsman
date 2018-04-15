
import UIKit
import Foundation

class PhotoFolderCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    var isPhotoItemSelected: Bool = false
    {
        didSet
        {
          photoCollectionView.reloadData()
        }
    }
    var photoItemView: UIView {return photoCollectionView}
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
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        imageRoundClip()
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.reloadData()
    
    
    }
    
    override func prepareForReuse()
    {
       super.prepareForReuse()
       imageRoundClip()
    
    }
    
    
    
}

extension PhotoFolderCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 //MARK:------------------------------------- SETTING CV CELLS SIZES -------------------------------------------
 //-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                     sizeForItemAt indexPath: IndexPath) -> CGSize
     //-------------------------------------------------------------------------------------------------------------
 {
    
     return CGSize(width: imageSize, height: imageSize)
    
 }//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:...
 //-------------------------------------------------------------------------------------------------------------
 //MARK: -
    
    
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

extension PhotoFolderCell:  UICollectionViewDataSource
{
    var globalDragItems: [Any]
    {
     return (UIApplication.shared.delegate as! AppDelegate).globalDragItems
    }
 
 
    var imageSize: CGFloat
    {
     get
     {
      
      let width = frameSize
      //print ("width =\(width)" )
      let fl = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
      let leftInset = fl.sectionInset.left
      let rightInset = fl.sectionInset.right
      let space = fl.minimumInteritemSpacing
      let size = (width - leftInset - rightInset - space * CGFloat(nphoto - 1)) / CGFloat(nphoto)
      return trunc(size)
     }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        // print ("LOADING FOLDER CELL WITH IP - \(indexPath)")
        // print ("VISIBLE CELLS: \(collectionView.visibleCells.count)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCollectionViewCell", for: indexPath) as! PhotoFolderCollectionViewCell
        let photoItem = photoItems[indexPath.row]
        cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
        
        cell.photoIconView.layer.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
        
        photoItem.getImage(requiredImageWidth:  imageSize)
        {(image) in
            cell.photoIconView.image = image
            cell.photoIconView.layer.contentsGravity = kCAGravityResizeAspect
            
            if let img = image
            {
               // print ("IMAGE LOADED FOR CELL WITH IP - \(indexPath)")
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
        
     if globalDragItems.contains(where:
      {item in
       if let dragPhotoItem = item as? PhotoItem, photoItem.id == dragPhotoItem.id {return true}
       return false
     })
     {
      PhotoSnippetViewController.startCellDragAnimation(cell: cell)
     }
        return cell
    }
 
 func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath?
 {
  guard let path = photoItems.enumerated().lazy.first(where: {$0.element.id == photoItem.id}) else {return nil}
  return IndexPath(row: path.offset, section: 0)
 }
    
}
