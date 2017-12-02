
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
       view.headerText.text = NSLocalizedString("Welcome back to NewMan Pro!", comment: "Main menu welcome message header")
       return view
        
      case UICollectionElementKindSectionFooter:
       let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainViewFooter", for: indexPath) as! MainViewFooter
       view.footerText.text = NSLocalizedString("Copyright 2017 (c)", comment: "Main menu footer copyright message")
       return view
        
      default: return UICollectionReusableView()
     }
        
    }  
    
    let items =
    [
     MainMenuItems (title: NSLocalizedString("Photos", comment: "Main menu photos icon"),
                    mainIcon: UIImage(named: "photo.main")!,
                    tabIcon: UIImage(named: "photo.tab.icon")!,
                    tabTitle: "📷",
                    type: .photo),
     
     MainMenuItems (title: NSLocalizedString("Texts", comment: "Main menu texts icon"),
                    mainIcon: UIImage(named: "text.main")!,
                    tabIcon: UIImage(named: "text.tab.icon")!,
                    tabTitle: "📝",
                    type: .text),
     
     MainMenuItems (title: NSLocalizedString("Audios", comment: "Main menu audios icon"),
                    mainIcon: UIImage(named: "audio.main")!,
                    tabIcon: UIImage(named: "audio.tab.icon")!,
                    tabTitle: "🎙",
                    type: .audio),
     
     MainMenuItems (title: NSLocalizedString("Videos", comment: "Main menu videos icon"),
                    mainIcon: UIImage(named: "video.main")!,
                    tabIcon: UIImage(named: "video.tab.icon")!,
                    tabTitle: "🎥",
                    type: .video),
     
     MainMenuItems (title: NSLocalizedString("Sketches", comment: "Main menu sketches icon"),
                    mainIcon: UIImage(named: "sketch.main")!,
                    tabIcon: UIImage(named: "sketch.tab.icon")!,
                    tabTitle: "🖼",
                    type: .sketch),
     
     MainMenuItems (title: NSLocalizedString("Reports", comment: "Main menu reports icon"),
                    mainIcon: UIImage(named: "report.main")!,
                    tabIcon: UIImage(named: "report.tab.icon")!,
                    tabTitle: "📰",
                    type: .report)
    ]

    
}
