
import Foundation
import UIKit

//MARK: -

//*************************************************************************************************************************
extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate
//*************************************************************************************************************************
 
{
//*************************************************************************************************************************
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
//*************************************************************************************************************************
 {
  print (#function)
 
  PhotoSnippetViewController.clearAllDraggedItems()
  
 }//func dropInteraction(_ interaction: UIDropInteraction...
//*************************************************************************************************************************
 
//MARK: -

//*************************************************************************************************************************
 func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession)
//*************************************************************************************************************************
 {
  
  print (#function)
  
 }//dragInteraction(_ interaction: UIDragInteraction...
//*************************************************************************************************************************
 
//MARK: -
 
//*************************************************************************************************************************
 func getDragItems (_ interaction: UIDragInteraction, for session: UIDragSession) -> [UIDragItem]
//*************************************************************************************************************************
 {
  for subView in subviews
  {
   if let _ = subView as? UIImageView
   {
    PhotoSnippetViewController.clearCancelledDraggedItems()
    
    let photoItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
    let itemProvider = NSItemProvider(object: photoItem)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    
    for item in (UIApplication.shared.delegate as! AppDelegate).globalDragItems
    {
     if let photoGlobalItem = item as? PhotoItemProtocol, photoGlobalItem.id == photoItem.id {return []}
    }
    
    (UIApplication.shared.delegate as! AppDelegate).globalDragItems.append(photoItem)
    photoItem.isSelected = true
    photoItem.dragSession = session
    PhotoSnippetViewController.printAllDraggedItems()
    
    return [dragItem]
    
   }
  }
 
  return []
  
 }//func getDragItems (forCellAt indexPath: IndexPath)...
//*************************************************************************************************************************
 
 //MARK: -
 
//*************************************************************************************************************************
 func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem]
//*************************************************************************************************************************
 {
   print (#function)
   return getDragItems(interaction, for: session)
 }
//*************************************************************************************************************************
 
//MARK: -
 
//*************************************************************************************************************************
 func dragInteraction(_ interaction: UIDragInteraction,
                        itemsForAddingTo session: UIDragSession,
                        withTouchAt point: CGPoint) -> [UIDragItem]
//*************************************************************************************************************************
 {
  
  print (#function)
  return getDragItems(interaction, for: session)
  
 }//func dragInteraction(_ interaction: UIDragInteraction,itemsForAddingTo session....
//*************************************************************************************************************************
 
//MARK: -

//*************************************************************************************************************************
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
//*************************************************************************************************************************
 {
  if session.localDragSession == nil
  {
   return UIDropProposal(operation: .copy)
  }
  else
  {
   return UIDropProposal(operation: .move)
  }
 }//func dropInteraction(_ interaction: UIDropInteraction,...
//*************************************************************************************************************************
 
//MARK: -
 
//*************************************************************************************************************************
 func copyImagesFromSideApp (_ interaction: UIDropInteraction, with session: UIDropSession)
//*************************************************************************************************************************
 {
  session.loadObjects(ofClass: UIImage.self)
  {[weak self] items in
    if let images = items as? [UIImage], images.count > 0,
       let vc = self?.photoSnippetVC,
       let ip = self?.zoomedCellIndexPath,
       let cv = self?.openWithCV(in: vc.view),
       let imageSize = self?.imageSize
    {
      var mergedPhotoItems = [vc.photoItems2D[ip.section][ip.row] as! PhotoItem]
     
      images.forEach
      {image in
       let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth: imageSize)
       newPhotoItem.isSelected = true
       mergedPhotoItems.append(newPhotoItem)
       vc.photoItems2D[ip.section].insert(newPhotoItem, at: ip.row)
       vc.photoCollectionView.insertItems(at: [ip])
      }
     
      if let _ = vc.performMergeIntoFolder(vc.photoCollectionView, from: mergedPhotoItems, into: ip)
      {
       self?.photoItems = mergedPhotoItems
       cv.reloadData()
      }
      else
      {
       print ("\(#function): Unable to merge loaded items into Photo Folder at Index Path: \(ip)")
      }
     
    }
  }
 } //func copyImagesFromSideApp...
//*************************************************************************************************************************
 
//MARK: -
 
//*************************************************************************************************************************
 func movedOuterPhotoItems (_ globalPhotoItems: [PhotoItemProtocol]) -> [PhotoItemProtocol]
//*************************************************************************************************************************
 {
   var movedItems: [PhotoItemProtocol] = []
   let destin = photoSnippetVC.photoSnippet!
   globalPhotoItems.map{$0.photoSnippet}.filter{$0 !== destin}.forEach
   {source in

     let folders: [PhotoItemProtocol] = PhotoItem.moveFolders(from: source, to: destin) ?? []
     let photos : [PhotoItemProtocol] = PhotoItem.movePhotos (from: source, to: destin) ?? []
    
     let totalMoved = photos + folders
     totalMoved.forEach
     {movedItem in
       photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert(movedItem, at: zoomedCellIndexPath.row)
       photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
     }
    
     movedItems += totalMoved
    
   }
   return movedItems
 }//func movedOuterPhotoItems...
//*************************************************************************************************************************

 //MARK: -
 
//*************************************************************************************************************************
 func movePhotoItemsInsideApp (_ globalPhotoItems: [PhotoItemProtocol])
//*************************************************************************************************************************
 {
  
  let zoomedItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
  
  zoomedItem.isSelected = true
  
  let localItems = globalPhotoItems.filter{$0.photoSnippet === photoSnippetVC.photoSnippet}
  let outerItems = movedOuterPhotoItems(globalPhotoItems)
  let totalItems = localItems + outerItems + (localItems.contains{$0.id == zoomedItem.id} ? [] : [zoomedItem])
  
  guard totalItems.count > 1 else {return}
  
  outerItems.forEach{$0.isSelected = true}
 
  let photoCV = photoSnippetVC.photoCollectionView!
  
  if let newFolderItem = photoSnippetVC.performMergeIntoFolder(photoCV, from: totalItems, into: zoomedCellIndexPath)
  {
   let cv = openWithCV(in: photoSnippetVC.view)
   let ip = photoSnippetVC.photoItemIndexPath(photoItem: newFolderItem)
   if let newFolderCell = photoCV.cellForItem(at: ip) as? PhotoFolderCell
   {
    zoomedCellIndexPath = ip
    photoItems = newFolderCell.photoItems
    cv.reloadData()
   }
   else
   {
     print ("\(#function): Invalid Merged Folder Cell at Index Path: \(ip)")
   }
  }
  else
  {
   print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(zoomedCellIndexPath)")
  }

 }//func movePhotoItemsInsideApp ...
//*************************************************************************************************************************
 
//MARK: -

//*************************************************************************************************************************
 func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
//*************************************************************************************************************************
 {
   print (#function)
   if session.localDragSession != nil
   {
    var globalPhotoItems: [PhotoItemProtocol] = []
    
    for item in (UIApplication.shared.delegate as! AppDelegate).globalDragItems
    {
     if let photoItem = item as? PhotoItemProtocol
     {
      globalPhotoItems.append(photoItem)
     }
    }
    
    if globalPhotoItems.isEmpty {return}
    
    movePhotoItemsInsideApp (globalPhotoItems)

   }
   else
   {
    copyImagesFromSideApp (interaction, with: session)
   }
 }//func dropInteraction...
//*************************************************************************************************************************
 
 
}//extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate...
//*************************************************************************************************************************
