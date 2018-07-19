
import Foundation
import UIKit

//MARK:================================== PHOTO SNIPPET CV DELEGATE ===========================================
extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
//=============================================================================================================
{
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
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
//-------------------------------------------------------------------------------------------------------------
 {
    
  return CGSize(width: imageSize, height: imageSize)

 }//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    

//MARK:--------------------------- SETTING UP CV CELLS SELECTION ANIMATION ------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func cellTouchAnimation(view: UIView)
//-------------------------------------------------------------------------------------------------------------
 {
  let downAni = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn)
  {
   view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
  }
    
  let upAni = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut)
  {
    view.transform = CGAffineTransform.identity
  }
  
  downAni.addCompletion{_ in upAni.startAnimation()}
 
  downAni.startAnimation()

 } //func cellTouchAnimation(view: UIView)...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK:------------------------------- PROCESSING CV CELLS SELECTION  -----------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//-------------------------------------------------------------------------------------------------------------
 {
  /*guard isEditingPhotos else {return}
    
  photoItems2D[indexPath.section][indexPath.row].isSelected = true
  allPhotosSelected = true
  selectBarButton.title = "☆☆☆"

  switch (collectionView.cellForItem(at: indexPath))
  {
   case let cell as PhotoFolderCell:
      cell.isPhotoItemSelected = true
      cell.photoCollectionView.visibleCells.forEach{cellTouchAnimation(view: $0)}
      cellTouchAnimation(view: cell)
   case let cell as PhotoSnippetCell:
      cell.isPhotoItemSelected = true
      cellTouchAnimation(view: cell)
   default: return
  }*/
    
  toggleCellSelection(collectionView, at: indexPath)
    
 }//func collectionView(_ collectionView: UICollectionView, didSelectItem...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    

 func toggleCellSelection(_ collectionView: UICollectionView, at indexPath: IndexPath)
 {
    guard isEditingPhotos else {return}
    
    let state = photoItems2D[indexPath.section][indexPath.row].isSelected
    photoItems2D[indexPath.section][indexPath.row].isSelected = !state
    
    allPhotosSelected = !state
    
    if (photoItems2D.filter{$0.lazy.first{$0.isSelected} != nil}.count == 0)
    {
        selectBarButton.title = "★★★"
    }
    else
    {
        selectBarButton.title = "☆☆☆"
    }
    
    switch (collectionView.cellForItem(at: indexPath))
    {
    case let cell as PhotoFolderCell:
        cell.isPhotoItemSelected = !state
        cell.photoCollectionView.visibleCells.forEach{cellTouchAnimation(view: $0)}
        cellTouchAnimation(view: cell)
    case let cell as PhotoSnippetCell:
        cell.isPhotoItemSelected = !state
        cellTouchAnimation(view: cell)
    default: return
    }
    
 }
    
//MARK:------------------------------- PROCESSING CV CELLS DESELECTION  ---------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//-------------------------------------------------------------------------------------------------------------
 {
  /*guard isEditingPhotos else {return}
  
  photoItems2D[indexPath.section][indexPath.row].isSelected = false
  allPhotosSelected = false

  if (photoItems2D.filter{$0.lazy.first{$0.isSelected} != nil}.count == 0)
  {
     selectBarButton.title = "★★★"
  }
    
  switch (collectionView.cellForItem(at: indexPath))
  {
   case let cell as PhotoFolderCell:
    cell.isPhotoItemSelected = false
    cell.photoCollectionView.visibleCells.forEach{cellTouchAnimation(view: $0)}
    cellTouchAnimation(view: cell)
   case let cell as PhotoSnippetCell:
    cell.isPhotoItemSelected = false
    cellTouchAnimation(view: cell)
   default: return
  }*/
    
  toggleCellSelection(collectionView, at: indexPath)
    
 }//func collectionView(_ collectionView: UICollectionView, didDeselectItemAt...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
}//extension PhotoSnippetViewController...
//================================================================================================
