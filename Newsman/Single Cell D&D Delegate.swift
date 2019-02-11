//
//  Single Cell D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 14/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class SingleCellDropViewDelegate: NSObject,  UIDropInteractionDelegate
{
 final var photoSnippetVC: PhotoSnippetViewController?
 {
  return (self.owner as? PhotoItemsDraggable)?.photoSnippetVC
 }
 
 weak var owner: UICollectionViewCell?
 
 init( owner:  UICollectionViewCell )
 {
  self.owner = owner
  super.init()
 }
 
 func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool
 {
  return true
 }//func dropInteraction(_ interaction: ...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating)
 {
  animator.addAnimations
  {
   interaction.view?.superview?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
   self.owner?.contentView.backgroundColor = UIColor.red
  }
 }//func dropInteraction(_ interaction: ...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession)
 {
  UIView.animate(withDuration: 0.25, animations:
  {
   interaction.view?.superview?.transform = .identity
   self.owner?.contentView.backgroundColor = UIColor.gray
  })
  {_ in
   self.owner?.contentView.layer.borderWidth = 1.0
   self.owner?.contentView.alpha = 1.0
   self.updateMergedCell()
  }
  
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession)
 {
  //print (#function)
  owner?.contentView.layer.borderWidth = 3.0
  owner?.contentView.alpha = 0.5
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession)
 {
  //print (#function)
  owner?.contentView.layer.borderWidth = 1.0
  owner?.contentView.alpha = 1.0
 }//func dropInteraction(_ interaction:...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
 {
  print (#function)
  AppDelegate.clearAllDraggedItems()
  //clear Global Drags Array with delayed unselection and removing drag animation from all hosted cells in drag items
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
 {
  if session.localDragSession != nil
  {
   return UIDropProposal(operation: .move)
  }
  else
  {
   return UIDropProposal(operation: .copy)
  }
 }//func dropInteraction(_ interaction:...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
 {
  print (#function)
  
  if session.localDragSession != nil
  {
    mergeWithInAppItems(interaction, performDrop: session)
  }
  else
  {
  
  }
 }//func dropInteraction(_ interaction:...
 

 
 func mergeWithOtherFolderItem(item sourcePhotoItem: PhotoItem,          // Dragged PhotoItem with boxed Photo MO.
                               from sourcePhotoFolder: PhotoFolder)      // Source PhotoFolder MO
 // Merges dragged visible CV cell with single cell and moves underlying Photo MO
 // from visible folder of this PhotoSnippet VC or from outer PhotoSnippet
 {
  print (#function)
  
  guard let vc = photoSnippetVC else { return }
  guard let cv = vc.photoCollectionView else { return }
  
  let proxyFolderItem = PhotoFolderItem(folder: sourcePhotoFolder)
  //Create proxy folder to check if belongs to this snippet
  
  guard let folderIndexPath = vc.photoItemIndexPath(photoItem: proxyFolderItem) else { return }
   //Dragged PhotoItem wrapping Photo MO is owned by the PhotoSnippet of this PhotoSnippetVC PhotoItems2D
  
  switch sourcePhotoFolder.count
  {
   case 0...1: break //error folder with 0 or 1 element contained!
   case 2:
    
    let singlePhoto = sourcePhotoFolder.folderedPhotos.first{$0 !== sourcePhotoItem.photo}
    let singlePhotoItem = PhotoItem(photo: singlePhoto!)
    
    vc.photoItems2D[folderIndexPath.section][folderIndexPath.row] = singlePhotoItem
    cv.reloadItems(at: [folderIndexPath])
   
    //if zoomView is open during the drop showing zoomed-in source PhotoFolder we turn it into the single photo item IV.
    guard let zoomView = cv.zoomView else { break }
    guard zoomView.zoomedPhotoItem?.hostedManagedObject === sourcePhotoFolder else { break }
    zoomView.zoomedPhotoItem = singlePhotoItem
    
    let iv = zoomView.openWithIV(in: vc.view)
    singlePhotoItem.getImageOperation(requiredImageWidth: zoomView.zoomSize)
    {image in
     zoomView.stopSpinner()
     iv.image = image
    }
   
   default:
  
    if let folderCell = cv.cellForItem(at: folderIndexPath) as? PhotoFolderCell,
       let cellIndexPath = folderCell.photoItemIndexPath(photoItem: sourcePhotoItem)
     //Dragged PhotoItem Folder Cell is visible in the PhotoSnippet CV, upadate FolderCell CV
    {
     folderCell.photoItems.remove(at: cellIndexPath.row)
     folderCell.photoCollectionView.deleteItems(at: [cellIndexPath])
    }
   
    //if zoomView is open during the drop showing zoomed-in source PhotoFolder we remove dragged item from Zoom CV
    guard let zoomView = cv.zoomView else {break}
    guard zoomView.zoomedPhotoItem?.hostedManagedObject === sourcePhotoFolder else { break }
    guard let zoomCellIndexPath = zoomView.photoItemIndexPath(photoItem: sourcePhotoItem) else {break}
    
    zoomView.photoItems.remove(at: zoomCellIndexPath.row)
    (zoomView.presentSubview as? UICollectionView)?.deleteItems(at: [zoomCellIndexPath])
   
  }
  
 }//func mergeWithOtherFolderItem...
 
 

 
 func mergeWithUnfolderedItem(item sourcePhotoItem: PhotoItemProtocol)
 // Merges Dragged source PhotoItem with PhotoItem hosted by this CV cell and form new folder if needed.
 {
  print (#function)
  
  guard let vc = photoSnippetVC else { return }
  guard let cv = vc.photoCollectionView else { return }
  
  guard let sourceIndexPath = vc.photoItemIndexPath(photoItem: sourcePhotoItem) else { return }
  //if we drag inner item in this photo snippet, just remove it from CV when merging
  vc.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
  cv.deleteItems(at: [sourceIndexPath])
  
  //if zoomView is open during the drop showing zoomed-in single source PhotoItem we remove from screen
  guard let zoomView = cv.zoomView else { return }
  guard zoomView.zoomedPhotoItem?.hostedManagedObject === sourcePhotoItem.hostedManagedObject else { return }
  zoomView.removeZoomView()
 
  
 }//func mergeWithUnfolderedItem...
 
 
 
 func updateMergedCell()
 {
  guard let vc = photoSnippetVC else { return }
  guard let cv = vc.photoCollectionView else { return }
  
  guard let singleCell = self.owner as? PhotoSnippetCell else { return }
  guard let newMergedFolder = (singleCell.hostedItem as? PhotoItem)?.folder else { return }
  
  let newFolderItem = PhotoFolderItem(folder: newMergedFolder)
  
  guard let selfIndexPath = cv.indexPath(for: singleCell) else { return }
  let oldPhotoItem = vc.photoItems2D[selfIndexPath.section][selfIndexPath.row]
  vc.photoItems2D[selfIndexPath.section][selfIndexPath.row] = newFolderItem
  cv.reloadItems(at: [selfIndexPath])
  
 
  //if zoomView is open during the drop showing zoomed-in single destination PhotoItem we turn it into CV...
  guard let newFolderCell = cv.cellForItem(at: selfIndexPath) as? PhotoFolderCell else { return }
  guard let zoomView = cv.zoomView else { return }
  guard zoomView.zoomedPhotoItem?.hostedManagedObject === oldPhotoItem.hostedManagedObject else { return }
  zoomView.zoomedPhotoItem = newFolderItem
  
  let zoomCV = zoomView.openWithCV(in: vc.view)
  zoomView.photoItems = newFolderCell.photoItems
  zoomCV.reloadData()
  
 }
 
 
 func mergeWithInAppItems(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
 {
  print (#function)
  
  guard let photoSnippet = photoSnippetVC?.photoSnippet else { return }
  guard let hostedItem = (self.owner as? PhotoSnippetCellProtocol)?.hostedItem else { return }
  
  defer //finally update PhotoSnippet CV sections afted all merge operations ...
  {
   photoSnippetVC?.updateMovedItemsSections()
  }
  
  //iterate over all dragged items in Global Drags Array and make merges separately for each item...
  
  let draggedItems = AppDelegate.globalDragItems.filter{$0.dragSession != nil} //filter out not cancelled items!
  
  draggedItems.forEach
  {dragItem in
   defer { dragItem.move(to: photoSnippet, to: hostedItem) }  //just make merge in context
   switch dragItem
   {
    case let photoItem as PhotoItem:    // dragging PhotoItem to merge with single photo item ...
     photoItem.moveToDrops()
     
     switch photoItem.folder
     {
      case let folder?: mergeWithOtherFolderItem (item: photoItem, from: folder)
        // merging this cell hosted item with foldered photo item
      case nil:         mergeWithUnfolderedItem  (item: photoItem)
        // merging this cell hosted item with unfoldered photo item
     }
     
    case let folderItem as PhotoFolderItem://dragging FolderItem to merge with single photo item ...
     folderItem.moveToDrops(allNestedItems: true)
     mergeWithUnfolderedItem (item: folderItem)
    
    default: break
   }
  }
  
 } //func moveInAppItems....
 
 
}//extension PhotoSnippetCell: UIDragInteractionDelegate, UIDropInteractionDelegate....
