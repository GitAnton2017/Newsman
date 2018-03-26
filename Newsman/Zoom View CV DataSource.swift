
import Foundation
import UIKit

extension ZoomView:  UICollectionViewDataSource
{
    
    
    
    var imageSize: CGFloat
    {
        let w = self.bounds.width
        let cv = self.subviews.first as! UICollectionView
        let fl = cv.collectionViewLayout as! UICollectionViewFlowLayout
        let li = fl.sectionInset.left
        let ri = fl.sectionInset.right
        let s = fl.minimumInteritemSpacing
        
        let size = (w - li - ri - s * CGFloat(nphoto - 1)) / CGFloat(nphoto)
        
        return trunc(size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        // print ("LOADING FOLDER CELL WITH IP - \(indexPath)")
        // print ("VISIBLE CELLS: \(collectionView.visibleCells.count)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomCollectionViewCell", for: indexPath) as! ZoomViewCollectionViewCell
        
        let photoItem = photoItems[indexPath.row]
        
        //cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
        
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
        
        
        return cell
    }
    

    func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath
    {
        let path = photoItems.enumerated().lazy.first{$0.element.id == photoItem.id}
        return IndexPath(row: path!.offset, section: 0)
    }
    
}
