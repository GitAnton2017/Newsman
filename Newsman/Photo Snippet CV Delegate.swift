
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
  
  guard let photoItem = photoItems2D[indexPath.section][indexPath.row] as? PhotoItem else {return}
  
  photoItem.getImageOperation(requiredImageWidth:  imageSize)
  {[weak self] (image) in
   
   guard let dataSource = self,
         let ip = dataSource.photoItemIndexPath(photoItem: photoItem),
         let cell = collectionView.cellForItem(at: ip) as? PhotoSnippetCell else {return}
   
   cell.spinner.stopAnimating()
   
   UIView.transition(with: cell.photoIconView, duration: 0.5,  options: .transitionCrossDissolve,
                     animations: {cell.photoIconView.image = image},
                     completion:
                     {_ in
                      
                      if let flag = photoItem.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
                      {
                       cell.drawFlagMarker(flagColor: color)
                      }
                      else
                      {
                       cell.clearFlagMarker()
                      }
                      
                      if (photoItem.type == .video)
                      {
                       cell.showPlayIcon(iconColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.65))
                       cell.showVideoDuration(textColor: UIColor.red,
                                              duration: AVURLAsset(url: photoItem.url).duration)
                      }
                      
                      cell.photoItemView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                      
                      UIView.animate(withDuration: 0.15, delay: 0,
                                     usingSpringWithDamping: 2500,
                                     initialSpringVelocity: 0,
                                     options: .curveEaseInOut,
                                     animations: {cell.photoItemView.transform = .identity},
                                     completion: nil)
                      
                    })
   
  }
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       didEndDisplaying cell: UICollectionViewCell,
                       forItemAt indexPath: IndexPath)
 {
  
  let photoItem = photoItems2D[indexPath.section][indexPath.row]
  
  switch (photoItem)
  {
   case let item as PhotoItem: item.cancelImageOperation()
   case _ as PhotoFolderItem: (cell as! PhotoFolderCell).photoItems.forEach{$0.cancelImageOperation()}
   default: break
  }
  
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
