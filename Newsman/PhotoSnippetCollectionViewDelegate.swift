
import Foundation
import UIKit

extension PhotoSnippetViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 1
    }
}
