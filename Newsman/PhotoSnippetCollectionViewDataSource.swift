
import Foundation
import UIKit
import CoreData


class PhotoSectionHeader: UICollectionReusableView
{
    @IBOutlet weak var headerLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

class PhotoSectionFooter: UICollectionReusableView
{
    @IBOutlet weak var footerLabel: UILabel!
}

extension PhotoSnippetViewController: UICollectionViewDataSource
{
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    /*func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let movedItem = photoItems.remove(at: sourceIndexPath.row)
        photoItems.insert(movedItem, at: destinationIndexPath.row)
        
        for i in 0..<photoItems.count
        {
          photoItems[i].photo.position = Int16(i)
        }
        
        photoSnippet.grouping = GroupPhotos.manually.rawValue
    }*/
    
    func collectionView(_ collectionView: UICollectionView,
                          viewForSupplementaryElementOfKind kind: String,
                          at indexPath: IndexPath) -> UICollectionReusableView
    {
        
        switch (kind)
        {
         case UICollectionElementKindSectionHeader:
            
          let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "photoSectionHeader",
                                                                     for: indexPath) as! PhotoSectionHeader
          

          if photoCollectionView.photoGroupType == .makeGroups, let titles = sectionTitles
          {
           let title = (titles[indexPath.section].isEmpty) ? "Not Flagged Yet" : titles[indexPath.section]
           view.headerLabel.text = NSLocalizedString(title, comment: title)
           if let color = PhotoPriorityFlags(rawValue: titles[indexPath.section])?.color
           {
             view.backgroundColor = color
           }
           else
           {
            view.backgroundColor = UIColor.lightGray
           }
          }
          return view
          
            
         case UICollectionElementKindSectionFooter:
            
          let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "photoSectionFooter",
                                                                     for: indexPath) as! PhotoSectionFooter
          if photoCollectionView.photoGroupType == .makeGroups
          {
           view.backgroundColor = collectionView.backgroundColor
           let itemsCount = photoItems2D[indexPath.section].count
           view.footerLabel.text = NSLocalizedString("Total photos in group", comment: "Total photos in group") + ": \(itemsCount)"
          }
          return view
            
         default:  return UICollectionReusableView()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
       /* if (collectionView as! PhotoSnippetCollectionView).photoGroupType == .makeGroups
        {
          return sectionTitles.count
        }
        else
        {
          return 1
        }*/
 
        return photoItems2D.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      //return itemsForSections(section: section).count
        
        return photoItems2D[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
        
      let photoCV = collectionView as! PhotoSnippetCollectionView
        
      //let photoItem = itemsForSections(section: indexPath.section)[indexPath.row]
      let photoItem = photoItems2D[indexPath.section][indexPath.row]
        
      photoCV.layer.addSublayer(cell.layer)
        
      if let path = photoCV.menuIndexPath, path == indexPath
      {
       let cellPoint = CGPoint(x: round(cell.frame.width * photoCV.menuShift.x),
                               y: round(cell.frame.height * photoCV.menuShift.y))
    
       let menuPoint = cell.photoIconView.layer.convert(cellPoint, to: photoCV.layer)
        
        photoCV.drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuPoint, menuItems: mainMenuItems)
                            
      }
        
      cell.photoIconView.alpha = photoItem.photo.isSelected ? 0.5 : 1
       
      if let flag = photoItem.photo.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
      {
       cell.drawFlag(flagColor: color)
      }
      else
      {
       cell.clearFlag()
      }
        
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
