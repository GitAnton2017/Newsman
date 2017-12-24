
import Foundation
import UIKit
import CoreData

extension PhotoSnippetViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      return photoItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
      
    
      cell.photoIconView.alpha = photoItems[indexPath.row].photo.isSelected ? 0.5 : 1
    
      cell.photoIconView.layer.cornerRadius = 10.0
      cell.photoIconView.layer.borderWidth = 1
      cell.photoIconView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
      cell.photoIconView.layer.masksToBounds = true
      
       
      if let flag = photoItems[indexPath.row].photo.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
      {
       cell.drawFlag(flagColor: color)
      }
      else
      {
       cell.clearFlag()
      }
        
      photoItems[indexPath.row].getImage(requiredImageWidth:  imageSize)
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
