
import Foundation
import UIKit

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
    
    let titles =
    [
        "PHOTO SNIPPETS" ,
        "TEXT SNIPPETS"  ,
        "AUDIO SNIPPETS" ,
        "VIDEO SNIPPETS" ,
        "SKETCH SNIPPETS",
        "REPORTS"
        
    ]
    
    let icons =
    [
        UIImage(named: "house"),
        UIImage(named: "house"),
        UIImage(named: "house"),
        UIImage(named: "house"),
        UIImage(named: "house"),
        UIImage(named: "house")
     
    ]

    

    
    
}
