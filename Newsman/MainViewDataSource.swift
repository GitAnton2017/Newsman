
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
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewCell", for: indexPath) as! MainViewCell
        
        cell.cellLabel.text =  items[indexPath.row].title
        cell.cellImage.image = items[indexPath.row].mainIcon
        
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
    
    let items =
    [
     MainMenuItems(title: "Photos",   mainIcon: UIImage(named: "photo.main")!, tabIcon: UIImage(named: "photo.tab.icon")!, type: .photo),
     MainMenuItems(title: "Texts",    mainIcon: UIImage(named: "text.main")!,  tabIcon: UIImage(named: "text.tab.icon")!,  type: .text),
     MainMenuItems(title: "Audio",    mainIcon: UIImage(named: "audio.main")!, tabIcon: UIImage(named: "audio.tab.icon")!, type: .audio),
     MainMenuItems(title: "Video",    mainIcon: UIImage(named: "video.main")!, tabIcon: UIImage(named: "video.tab.icon")!, type: .video),
     MainMenuItems(title: "Sketches", mainIcon: UIImage(named: "sketch.main")!, tabIcon: UIImage(named: "sketch.tab.icon")!, type: .sketch),
     MainMenuItems(title: "Reports",  mainIcon: UIImage(named: "report.main")!, tabIcon: UIImage(named: "report.tab.icon")!, type: .report)
    ]

    
}
