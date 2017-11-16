
import Foundation
import UIKit

class MainViewHeader : UICollectionReusableView
{
    @IBOutlet var headerText: UILabel!
}

class MainViewFooter: UICollectionReusableView
{
    @IBOutlet var footerText: UILabel!
}

class MainViewDataSource: NSObject, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewCell", for: indexPath) as! MainViewCell
        cell.cellLabel.text =  titles[indexPath.row]
        cell.cellImage.image = icons[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
    
     switch (kind)
     {
      case UICollectionElementKindSectionHeader:
       let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainViewHeader", for: indexPath) as! MainViewHeader
       view.headerText.text = "Welcome back to NewMan Pro!"
       return view
        
      case UICollectionElementKindSectionFooter:
       let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainViewFooter", for: indexPath) as! MainViewFooter
       view.footerText.text = "Copyright 2017 (c)"
       return view
        
      default: return UICollectionReusableView()
     }
        
    }
    
    let titles =
    [
        "Photos" ,
        "Texts"  ,
        "Audio" ,
        "Video" ,
        "Sketches",
        "Reports"
        
    ]
    
    let icons =
    [
        UIImage(named: "photos"),
        UIImage(named: "texts"),
        UIImage(named: "audios"),
        UIImage(named: "videos"),
        UIImage(named: "sketches"),
        UIImage(named: "reports")
     
    ]

    

    
    
}
