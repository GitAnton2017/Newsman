
import Foundation
import UIKit

//MARK:================================== PHOTO SNIPPET CV DELEGATE ===========================================
extension PhotoSnippetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
//=============================================================================================================
{
    
    
//MARK:------------------------------ SETTING SECTION HEADERS SIZES -------------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
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
  guard isEditingPhotos else {return}
    
  var photoItem = photoItems2D[indexPath.section][indexPath.row]
  var selection: UIView;
    
  switch (photoItem)
  {
   case is PhotoFolderItem:
    selection = (collectionView.cellForItem(at: indexPath) as! PhotoFolderCell).photoCollectionView
    (selection as! UICollectionView).visibleCells.forEach{cellTouchAnimation(view: $0)}
   case is PhotoItem:
    selection = (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView
   default: return
  }

  cellTouchAnimation(view: selection)

  if (!photoItem.isSelected)
  {
    print ("SELECT NOT SELECTED")
    selection.alpha = 0.5
    photoItem.isSelected = true
    allPhotosSelected = true
    selectBarButton.title = "☆☆☆"
  }
  else
  {
    print ("SELECT SELECTED")
    selection.alpha = 1
    photoItem.isSelected = false
    
    if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
    {
       selectBarButton.title = "★★★"
    }
  }
 }//func collectionView(_ collectionView: UICollectionView, didSelectItem...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
    
//MARK:------------------------------- PROCESSING CV CELLS DESELECTION  ---------------------------------------
//-------------------------------------------------------------------------------------------------------------
 func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//-------------------------------------------------------------------------------------------------------------
 {
  guard isEditingPhotos else {return}
  
  var photoItem = photoItems2D[indexPath.section][indexPath.row]
  var selection: UIView;
  switch (photoItem)
  {
   case is PhotoFolderItem:
    selection = (collectionView.cellForItem(at: indexPath) as! PhotoFolderCell).photoCollectionView
    (selection as! UICollectionView).visibleCells.forEach{cellTouchAnimation(view: $0)}
   case is PhotoItem:
    selection = (collectionView.cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView
    default: return
  }
    
  cellTouchAnimation(view: selection)
    
  if (photoItem.isSelected)
  {
    print ("DESELECT SELECTED")
    selection.alpha = 1
    photoItem.isSelected = false
    if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0
    {
      selectBarButton.title = "★★★"
    }
  }
  else
  {
    print ("DESELECT DESELECTED")
    selection.alpha = 0.5
    photoItem.isSelected = true
    allPhotosSelected = true
    selectBarButton.title = "☆☆☆"
  }
 }//func collectionView(_ collectionView: UICollectionView, didDeselectItemAt...
//-------------------------------------------------------------------------------------------------------------
//MARK: -
    
}//extension PhotoSnippetViewController...
//================================================================================================
