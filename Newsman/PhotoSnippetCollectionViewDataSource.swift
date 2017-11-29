
import Foundation
import UIKit
import CoreData

extension PhotoSnippetViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      let photos = cache.getPhotos(photoSnippet: photoSnippet)
      return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
        
      let photos = cache.getPhotos(photoSnippet: photoSnippet)
      cell.photoIconView.image = photos[indexPath.row]
        
      return cell
    }
    
    
}
