
import Foundation
import UIKit
import AVKit



//MARK:================================== PHOTO SNIPPET CV DELEGATE =========================================

extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 
 func bringArrowMenuToFront()
 {
  guard let menuCell = (photoCollectionView?.visibleCells.compactMap{ $0 as? PhotoSnippetCellProtocol }
                                            .first{ $0.arrowMenuView != nil }) else { return }
  
   photoCollectionView?.bringSubviewToFront(menuCell)
  
 }
 
 func bringOverlayFolderCellsToFront(_ collectionView: UICollectionView,
                                     cell: PhotoSnippetCellProtocol,
                                     forItemAt indexPath: IndexPath)
 {
  guard let folderCell = cell as? PhotoFolderCell else
  {
   if cell.hostedItem?.isArrowMenuShowing ?? false { return }
   collectionView.sendSubviewToBack(cell)
   return
  }
  
  collectionView.bringSubviewToFront(folderCell)
  
  let belowIndexPath = IndexPath(row: indexPath.row + photosInRow, section: indexPath.section)
  if let belowCell = collectionView.cellForItem(at: belowIndexPath) as? PhotoFolderCell
  {
   bringOverlayFolderCellsToFront(collectionView, cell: belowCell, forItemAt: belowIndexPath)
  }
  else
  {
   bringArrowMenuToFront()
  }
  
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       willDisplay cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  //print (#function, indexPath)
  guard let photoCell = cell as? PhotoSnippetCellProtocol else { return }
  
  photoCell.refreshCellView()
 
  bringOverlayFolderCellsToFront(collectionView, cell: photoCell, forItemAt: indexPath)
 
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  //print (#function, indexPath)
  guard let photoCell = cell as? PhotoSnippetCellProtocol else { return }
  photoCell.clearMainView()
  //photoCell.cancelImageOperations()
  photoCell.hostedItem?.isArrowMenuShowing = false
 }
 
 
 

 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       referenceSizeForHeaderInSection section: Int) -> CGSize
 {
  if (photoCollectionView.photoGroupType?.isSectioned ?? false) && !photoItems2D[section].isEmpty
  {
   return CGSize(width: 0, height: 50)
  }
  else
  {
   return CGSize.zero
  }
 }
    
    
    

 func collectionView(_ collectionView: UICollectionView,
                     layout collectionViewLayout: UICollectionViewLayout,
                     referenceSizeForFooterInSection section: Int) -> CGSize
 {
  
  
  if (photoCollectionView.photoGroupType?.isSectioned ?? false) && !photoItems2D[section].isEmpty
  {
    return CGSize(width: 0, height: 35)
  }
  else
  {
    return CGSize.zero
  }
 }
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
 {
  CGSize(width: imageSize, height: imageSize)
 }
 
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
 {
  toggleCellSelection(collectionView, at: indexPath)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                     shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
 {
  isEditingPhotos
 }
    
 func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView)
 {
  collectionView.allowsMultipleSelection = false
 }
 
 func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
 {
  (collectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol)?.setHighlighted(true)
 }

 func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
 {
  (collectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol)?.setHighlighted(false)
 }

 func toggleCellSelection(_ collectionView: UICollectionView, at indexPath: IndexPath)
 {
  guard isEditingPhotos else { return }
  photoItems2D[indexPath.section][indexPath.row].toggleSelection()
 }
 
// When allowMultipleSelection is set to YES (by default) this method is not needed.
// func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
// {
//  toggleCellSelection(collectionView, at: indexPath)
// }
 
}


