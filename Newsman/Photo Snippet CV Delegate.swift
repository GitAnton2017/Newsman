
import Foundation
import UIKit
import AVKit



//MARK:================================== PHOTO SNIPPET CV DELEGATE ===========================================
extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

 
//=============================================================================================================
{
 
 func collectionView(_ collectionView: UICollectionView,
                       willDisplay cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  //updateCell(collectionView, willDisplay: cell, forItemAt: indexPath)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  guard let photoCell = cell as? PhotoSnippetCellProtocol else { return }
  photoCell.cancelImageOperations()
  //photoCell.hostedItem?.hostingCollectionViewCell = nil
 }
 
 
 
//MARK:------------------------------ SETTING SECTION HEADERS SIZES -------------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       referenceSizeForHeaderInSection section: Int) -> CGSize
//-------------------------------------------------------------------------------------------------------------
 {
   if photoCollectionView.photoGroupType == .makeGroups
   {
     return CGSize(width: 0, height: 50)
   }
   else
   {
     return CGSize.zero
   }
 }//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:------------------------------ SETTING SECTION FOOTERS SIZES -------------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                    referenceSizeForFooterInSection section: Int) -> CGSize
//-------------------------------------------------------------------------------------------------------------
 {
  if photoCollectionView.photoGroupType == .makeGroups
  {
    return CGSize(width: 0, height: 50)
  }
  else
  {
    return CGSize.zero
  }
 }//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
 
    
    
    
//MARK:------------------------------------- SETTING CV CELLS SIZES -------------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
//-------------------------------------------------------------------------------------------------------------
 {
    
  return CGSize(width: imageSize, height: imageSize)

 }//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
 
    
//MARK:------------------------------- PROCESSING CV CELLS SELECTION  -----------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//-------------------------------------------------------------------------------------------------------------
 {
    
  toggleCellSelection(collectionView, at: indexPath)
    
 }//func collectionView(_ collectionView: UICollectionView, didSelectItem...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    

 func toggleCellSelection(_ collectionView: UICollectionView, at indexPath: IndexPath)
 {
    guard isEditingPhotos else {return}
  
    photoItems2D[indexPath.section][indexPath.row].toggleSelection()
    allPhotosSelected = photoItems2D.flatMap{$0}.allSatisfy{$0.isSelected}
    selectBarButton.title = allPhotosSelected ? "☆☆☆" : "★★★"
  
 }
    
//MARK:------------------------------- PROCESSING CV CELLS DESELECTION  ---------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//-------------------------------------------------------------------------------------------------------------
 {
    
  toggleCellSelection(collectionView, at: indexPath)
    
 }//func collectionView(_ collectionView: UICollectionView, didDeselectItemAt...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
}//extension PhotoSnippetViewController...
//================================================================================================
