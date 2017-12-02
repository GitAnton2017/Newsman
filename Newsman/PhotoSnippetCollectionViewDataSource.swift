
import Foundation
import UIKit
import CoreData

extension PhotoSnippetViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      return photos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
        
      cell.photoIconView.alpha = cell.isSelected ? 0.5 : 1
      cell.photoIconView.image = photos[indexPath.row].image
        
      return cell
    }
    
    
}
