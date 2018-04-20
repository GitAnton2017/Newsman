
import Foundation
import UIKit

//MARK: -

//*************************************************************************************************************************
extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate
//*************************************************************************************************************************
{
 //***************************************************************************************************************
 var globalDragItems: [Any]
 {
  return (UIApplication.shared.delegate as! AppDelegate).globalDragItems
 }
 //***************************************************************************************************************
 var allPhotoItems: [PhotoItemProtocol]
 {
  return globalDragItems.filter {$0 is PhotoItemProtocol} as! [PhotoItemProtocol]
 }
 
 //***************************************************************************************************************
 var localPhotos: [PhotoItem]
 {
  let locals = globalDragItems.filter
  {
   if let photoItem = $0 as? PhotoItem, photoItem.photoSnippet === photoSnippetVC.photoSnippet, photoItem.photo.folder == nil
   {
    return true
   }
   return false
  }
  return locals as! [PhotoItem]
 }
 //***************************************************************************************************************
 var localFolders: [PhotoFolderItem]
 {
  let locals = globalDragItems.filter
  {
   if let photoFolder = $0 as? PhotoFolderItem, photoFolder.photoSnippet === photoSnippetVC.photoSnippet
   {
    return true
   }
   return false
  }
  return locals as! [PhotoFolderItem]
 }
 //***************************************************************************************************************
 var localItems: [PhotoItemProtocol]
 {
  return localPhotos as [PhotoItemProtocol] + localFolders as [PhotoItemProtocol]
 }
 //***************************************************************************************************************
 var localFoldered: [PhotoItem]
 {
  let locals = globalDragItems.filter
  {
   if let photoItem = $0 as? PhotoItem,
      photoItem.photoSnippet === photoSnippetVC.photoSnippet,
      photoItem.photo.folder != nil,
      !zoomedFolderPhotos.contains(where: {$0.id == photoItem.id})
    
   {
    return true
   }
   return false
  }
  return locals as! [PhotoItem]
 }
 //***************************************************************************************************************
 var outerSnippets: [PhotoSnippet]
 {
  let allPhotoItems = globalDragItems.filter
  {
   if let photoItem = $0 as? PhotoItemProtocol, photoItem.photoSnippet !== photoSnippetVC.photoSnippet
   {
    return true
   }
   return false
   } as! [PhotoItemProtocol]
  
  return allPhotoItems.map{$0.photoSnippet}
 }
 
//*************************************************************************************************************************
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
//*************************************************************************************************************************
 {
  print (#function)
  if photoSnippetVC != nil
  {
   photoSnippetVC.animateDragItemsEnd(photoSnippetVC.photoCollectionView)

   PhotoSnippetViewController.clearAllDraggedItems()
  }
  
 }//func dropInteraction(_ interaction: UIDropInteraction...
//*************************************************************************************************************************
 
//MARK: -

//*************************************************************************************************************************
 func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession)
//*************************************************************************************************************************
 {
  
  print (#function)
  photoSnippetVC.animateDragItemsBegin(photoSnippetVC.photoCollectionView, dragItems: session.items)
  
  //PhotoSnippetViewController.printAllDraggedItems()
  
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
    
    for item in globalDragItems
    {
     if let photoGlobalItem = item as? PhotoItemProtocol, photoGlobalItem.id == photoItem.id {return []}
    }
    
    (UIApplication.shared.delegate as! AppDelegate).globalDragItems.append(photoItem)
    
    photoItem.isSelected = true
    photoItem.dragSession = session
    dragItem.localObject = photoItem
    
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
   //PhotoSnippetViewController.printAllDraggedItems()
   return getDragItems(interaction, for: session)
 }
//*************************************************************************************************************************
 
//MARK: -
 
//*************************************************************************************************************************
 func dragInteraction(_ interaction: UIDragInteraction, itemsForAddingTo session: UIDragSession,
                        withTouchAt point: CGPoint) -> [UIDragItem]
//*************************************************************************************************************************
 {
  
  print (#function)
  let dragItems = getDragItems(interaction, for: session)
  photoSnippetVC.animateDragItemsBegin(photoSnippetVC.photoCollectionView, dragItems: dragItems)
  //PhotoSnippetViewController.printAllDraggedItems()
  return dragItems
  
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
 
//***************************************************************************************************************/
 func unfolderedLocalPhotoItems () -> [PhotoItemProtocol]
//***************************************************************************************************************/
 {
  let foldered = localFoldered
  
  if foldered.isEmpty {return []}
  
  let collectionView = photoSnippetVC.photoCollectionView!
  
  var nextItemFlag = false
  
  var photoItemsMap: [IndexPath : [PhotoItem]] = [:]
  
  for item in foldered
  {
   if nextItemFlag {nextItemFlag = false; continue}
   
   let folder = PhotoFolderItem(folder: item.photo.folder!)
   let sourceIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: folder)!
   
   if let cell = collectionView.cellForItem(at: sourceIndexPath) as? PhotoFolderCell
   {
    let ip = cell.photoItemIndexPath(photoItem: item)!
    cell.photoItems.remove(at: ip.row)
    cell.photoCollectionView.deleteItems(at: [ip])
    
    if (cell.photoItems.count == 1)
    {
     photoSnippetVC.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
     PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: folder)
     let singleItem = cell.photoItems.remove(at: 0)
     cell.photoCollectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
     collectionView.deleteItems(at: [sourceIndexPath])
     
     if (singleItem.isSelected) {nextItemFlag = true}
     else
     {
      photoSnippetVC.photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
      
      if (collectionView.photoGroupType == .makeGroups)
      {
       singleItem.priorityFlag = photoSnippetVC.sectionTitles?[sourceIndexPath.section]
      }
      collectionView.insertItems(at: [sourceIndexPath])
      collectionView.reloadSections([sourceIndexPath.section])
     }
    }
   }
   else 
   {
    var proxyPhotoItems: [PhotoItem] = []
    if let photoItems = photoItemsMap[sourceIndexPath]
    {
     proxyPhotoItems = photoItems
    }
    else if let photosInFolder = folder.folder.photos?.allObjects as? [Photo]
    {
     proxyPhotoItems = photosInFolder.map{PhotoItem(photo: $0)}
    }
    else
    {
     print ("Invalid Folder at Index Path \(sourceIndexPath)")
     continue
    }
    
    let itemIndex = proxyPhotoItems.index{$0.id == item.id}
    proxyPhotoItems.remove(at: itemIndex!)
    photoItemsMap[sourceIndexPath] = proxyPhotoItems
    
    if (proxyPhotoItems.count == 1)
    {
     photoSnippetVC.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
     PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: folder)
     let singleItem = proxyPhotoItems.remove(at: 0)
     photoItemsMap[sourceIndexPath] = nil
     collectionView.deleteItems(at: [sourceIndexPath])
     
     if (singleItem.isSelected) {nextItemFlag = true}
     else
     {
      photoSnippetVC.photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
      
      if (collectionView.photoGroupType == .makeGroups)
      {
       singleItem.priorityFlag = photoSnippetVC.sectionTitles?[sourceIndexPath.section]
      }
      collectionView.insertItems(at: [sourceIndexPath])
      collectionView.reloadSections([sourceIndexPath.section])
     } //if (singleItem.isSelected)...
    } //if (proxyPhotoItems.count == 1)...
   } //if let cell = collectionView.cellForItem... else...
  } //for item in...
  
  let unfoldered = PhotoItem.unfolderPhotos(from: photoSnippetVC.photoSnippet, to: photoSnippetVC.photoSnippet) ?? []
  
  unfoldered.forEach
  {movedItem in
   photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert(movedItem, at: zoomedCellIndexPath.row)
   photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
  }
  
  return unfoldered
 }
 //***************************************************************************************************************/
 
 //MARK: -
//*************************************************************************************************************************
 func movedOuterPhotoItems () -> [PhotoItemProtocol]
//*************************************************************************************************************************
 {
   var movedItems: [PhotoItemProtocol] = []
   let destin = photoSnippetVC.photoSnippet!
   outerSnippets.forEach
   {source in

     let folders:    [PhotoItemProtocol] = PhotoItem.moveFolders    (from: source, to: destin) ?? []
     let photos :    [PhotoItemProtocol] = PhotoItem.movePhotos     (from: source, to: destin) ?? []
     let unfoldered: [PhotoItemProtocol] = PhotoItem.unfolderPhotos (from: source, to: destin) ?? []
    
     let totalMoved = photos + folders + unfoldered
    
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
 func movePhotoItemsInsideApp ()
//*************************************************************************************************************************
 {
  let zoomedItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
  
  let local =  localItems
  let unfold = unfolderedLocalPhotoItems()
  let moved =  movedOuterPhotoItems ()
  
  let totalItems = local + unfold + moved + (local.contains{$0.id == zoomedItem.id} ? [] : [zoomedItem])
 
  guard totalItems.count > 1 else {return}
  
  totalItems.forEach{$0.isSelected = true}
 
  let photoCV = photoSnippetVC.photoCollectionView!
  
  if let newFolderItem = photoSnippetVC.performMergeIntoFolder(photoCV, from: totalItems, into: zoomedCellIndexPath)
  {
   zoomedPhotoItem = newFolderItem
   zoomedCellIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: newFolderItem)
   
   let cv = openWithCV(in: photoSnippetVC.view)
   if let newFolderCell = photoCV.cellForItem(at: zoomedCellIndexPath!) as? PhotoFolderCell
   {
    photoItems = newFolderCell.photoItems
   }
   else if let photosInFolder = newFolderItem.folder.photos?.allObjects as? [Photo]
   {
    photoItems = photosInFolder.map{PhotoItem(photo: $0)}
   }
   else
   {
    print ("Invalid new merged folder at index path \(zoomedCellIndexPath!)")
   }
   cv.reloadData()
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
  
   if (session.localDragSession != nil && allPhotoItems.count > 0)
   {
    movePhotoItemsInsideApp ()
   }
   else
   {
    copyImagesFromSideApp (interaction, with: session)
   }
 }//func dropInteraction...
//*************************************************************************************************************************
 
 
}//extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate...
//*************************************************************************************************************************
