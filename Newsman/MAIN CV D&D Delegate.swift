
import Foundation
import CoreData
import UIKit

//MARK: -

//***************************************************************************************************************
extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
//***************************************************************************************************************
{
 
class func startCellDragAnimation (cell: UICollectionViewCell)
 {
 
  cell.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/100)
  UIView.animate(withDuration: 0.1,
                 delay: 0,
                 options: [.curveEaseInOut, .`repeat`, .autoreverse],
                 animations: {cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi/100).scaledBy(x: 0.95, y: 0.95)},
                 completion: nil
  )
 }
 
 class func stopCellDragAnimation (cell: UICollectionViewCell)
 {
  UIView.animate(withDuration: 0.1,
                 delay: 0,
                 options: [.curveEaseInOut],
                 animations: {cell.transform = CGAffineTransform.identity},
                 completion: nil)
 }
 
 func animateDragItemsBegin (_ collectionView: UICollectionView, dragItems: [UIDragItem])
 {
  dragItems.forEach
  {item in
   if let photoItem = item.localObject as? PhotoItemProtocol,
      let itemIndexPath = photoItemIndexPath(photoItem: photoItem),
      let cell = collectionView.cellForItem(at: itemIndexPath)
   {
    PhotoSnippetViewController.startCellDragAnimation(cell: cell)
   }
  }
 }
 
 func animateDragItemsEnd (_ collectionView: UICollectionView)
 {
   globalDragItems.forEach
   {item in
    if let photoItem = item as? PhotoItemProtocol,
       let itemIndexPath = photoItemIndexPath(photoItem: photoItem),
       let cell = collectionView.cellForItem(at: itemIndexPath)
    {
      PhotoSnippetViewController.stopCellDragAnimation(cell: cell)
    }
    else
    if let photoItem = item as? PhotoItem,
       let zv = (collectionView as! PhotoSnippetCollectionView).zoomView,
       let itemIndexPath = zv.photoItemIndexPath(photoItem: photoItem),
       let cv = zv.presentSubview as? UICollectionView,
       let cell = cv.cellForItem(at: itemIndexPath)
    {
     PhotoSnippetViewController.stopCellDragAnimation(cell: cell)
    }
    else
    if let photoItem = item as? PhotoItem,
       let folder = photoItem.photo.folder,
       let folderCellIndexPath = photoItemIndexPath(photoItem: PhotoFolderItem(folder: folder)),
       let folderCell = collectionView.cellForItem(at: folderCellIndexPath) as? PhotoFolderCell,
       let cellInFolderIndexPath = folderCell.photoItemIndexPath(photoItem: photoItem),
       let cellInFolder = folderCell.photoCollectionView.cellForItem(at: cellInFolderIndexPath)
    {
     PhotoSnippetViewController.stopCellDragAnimation(cell: cellInFolder)
    }
    
  }
 }

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
   if let photoItem = $0 as? PhotoItem, photoItem.photoSnippet === photoSnippet, photoItem.photo.folder == nil
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
   if let photoFolder = $0 as? PhotoFolderItem, photoFolder.photoSnippet === photoSnippet
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
   if let photoItem = $0 as? PhotoItem, photoItem.photoSnippet === photoSnippet, photoItem.photo.folder != nil
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
   if let photoItem = $0 as? PhotoItemProtocol, photoItem.photoSnippet !== photoSnippet
   {
    return true
   }
   return false
  } as! [PhotoItemProtocol]
  
  return allPhotoItems.map{$0.photoSnippet}
 }
//***************************************************************************************************************
 
//MARK: -

//***************************************************************************************************************
 class func printAllDraggedItems()
//***************************************************************************************************************
 {
  (UIApplication.shared.delegate as! AppDelegate).globalDragItems.forEach
  {
   print("DRAG ITEM ID: \(($0 as! PhotoItemProtocol).id) DRAG SESSION: \(String(describing: ($0 as! PhotoItemProtocol).dragSession)) SELECTED:\(($0 as! PhotoItemProtocol).isSelected) ")
  }
 }
//***************************************************************************************************************
 
//MARK: -
 
//***************************************************************************************************************
 class func removeDraggedItem(PhotoItemToRemove: PhotoItemProtocol)
//***************************************************************************************************************
 {
   if let index = (UIApplication.shared.delegate as! AppDelegate).globalDragItems.index(where:{
    if let photoItem = $0 as? PhotoItemProtocol, photoItem.id == PhotoItemToRemove.id {return true}
    return false})
   {
    (UIApplication.shared.delegate as! AppDelegate).globalDragItems.remove(at: index)
   }
 }
//***************************************************************************************************************

//MARK: -

//***************************************************************************************************************
 class func clearAllDraggedItems()
//***************************************************************************************************************
 {
  let globalDragItems = (UIApplication.shared.delegate as! AppDelegate).globalDragItems
 
  (UIApplication.shared.delegate as! AppDelegate).globalDragItems.removeAll()
 
  globalDragItems.forEach
  {
   if let photoItem = $0 as? PhotoItemProtocol {photoItem.isSelected = false}
  }
 }
//***************************************************************************************************************
 
 //MARK: -
 
//***************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
//***************************************************************************************************************
 {
  print (#function)
  animateDragItemsEnd(collectionView)
  PhotoSnippetViewController.clearAllDraggedItems()
  
 }
 
//***************************************************************************************************************
 
 //MARK: -
 
//***************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
//***************************************************************************************************************
 {
  print (#function, session.items.count)
  print ("CV HAS ACTIVE DRAG: \(collectionView.hasActiveDrag)")
  animateDragItemsBegin(collectionView, dragItems: session.items)
 }
//***************************************************************************************************************
 
//MARK: -
 
//***************************************************************************************************************
  func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
//***************************************************************************************************************
 {
  print (#function)
 }
//***************************************************************************************************************
 
 //MARK: -
 
//***************************************************************************************************************
 class func getCancelledDraggedItems() -> [PhotoItemProtocol]
//***************************************************************************************************************
 {
  let cnxxDragItems = (UIApplication.shared.delegate as! AppDelegate).globalDragItems.filter
  {
   if let photoItem = $0 as? PhotoItemProtocol, photoItem.dragSession == nil {return true}
   return false
  }
  
  return cnxxDragItems as! [PhotoItemProtocol]
  
 }
 //***************************************************************************************************************
 
 //MARK: -
 
//***************************************************************************************************************
 class func clearCancelledDraggedItems()
//***************************************************************************************************************
 {
  getCancelledDraggedItems().forEach {removeDraggedItem(PhotoItemToRemove: $0)}
 }
//***************************************************************************************************************
 
 //MARK: -
 
//***************************************************************************************************************
 func getDragItems (_ collectionView: UICollectionView, for session: UIDragSession,
                      forCellAt indexPath: IndexPath) -> [UIDragItem]
//***************************************************************************************************************
 {
  
  PhotoSnippetViewController.clearCancelledDraggedItems()
  
  let photoItem = photoItems2D[indexPath.section][indexPath.row]
  
  if collectionView.cellForItem(at: indexPath) != nil
  {
   let itemProvider = NSItemProvider(object: photoItem)
   let dragItem = UIDragItem(itemProvider: itemProvider)
 
   for item in globalDragItems
   {
    if let photoGlobalItem = item as? PhotoItemProtocol, photoGlobalItem.id == photoItem.id
    {
     return []
    }
    else
    if let photoGlobalItem = item as? PhotoItem, let dragged = photoItem as? PhotoFolderItem,
       photoGlobalItem.photo.folder?.id == dragged.id
    {
     return []
    }
    
    
   }
   
   (UIApplication.shared.delegate as! AppDelegate).globalDragItems.append(photoItem)
   
   photoItem.isSelected = true
   photoItem.dragSession = session
   dragItem.localObject = photoItem
   PhotoSnippetViewController.printAllDraggedItems()
   print ("CV HAS ACTIVE DRAG: \(collectionView.hasActiveDrag)")
   
   return [dragItem]
   
  }
  else
  {
    return []
  }

 }
//***************************************************************************************************************/
    
//MARK: -
    
//***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem]
//***************************************************************************************************************/
 {
  print (#function, session.items.count)
  let dragItems = getDragItems(collectionView, for: session, forCellAt: indexPath)
  return dragItems
 }
//***************************************************************************************************************/
 
 //MARK: -
    
//***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//***************************************************************************************************************/
 {
  print (#function)
  let dragItems = getDragItems(collectionView, for: session, forCellAt: indexPath)
  animateDragItemsBegin(collectionView, dragItems: dragItems)
  return dragItems
 }
//***************************************************************************************************************/
    
 //MARK: -

//***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       dropSessionDidUpdate session: UIDropSession,
                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
//***************************************************************************************************************/
    
 {
  if session.localDragSession != nil
  {

    if session.items.count == 1
    {
      return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
    }
    
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
  }
  else
  {
   return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
  }
 }
//***************************************************************************************************************/
    
//MARK: -
    
//***************************************************************************************************************/
 func performMergeIntoFolder (_ collectionView: PhotoSnippetCollectionView,
                                from photoItems: [PhotoItemProtocol],
                                into destinationIndexPath: IndexPath) -> PhotoFolderItem?
//***************************************************************************************************************/
 {
     if let newFolder = PhotoFolderItem(photoSnippet: photoSnippet)
     {
         newFolder.priorityFlag = sectionTitles?[destinationIndexPath.section]
         photoItems.forEach
         {photoItem in
            let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
            photoItems2D[sourceIndexPath!.section].remove(at: sourceIndexPath!.row)
            PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: photoItem)
            collectionView.deleteItems(at: [sourceIndexPath!])
          
            if (collectionView.photoGroupType == .makeGroups && sourceIndexPath!.section != destinationIndexPath.section)
            {
             collectionView.reloadSections([sourceIndexPath!.section])
            }
            
         }//photoItems.forEach...
        
         let sectionCnt = photoItems2D[destinationIndexPath.section].count
         if  (destinationIndexPath.row < sectionCnt)
         {
             photoItems2D[destinationIndexPath.section].insert(newFolder, at: destinationIndexPath.row)
             collectionView.insertItems(at: [destinationIndexPath])
         }
         else
         {
             photoItems2D[destinationIndexPath.section].append(newFolder)
             let indexPath = IndexPath(row: sectionCnt, section: destinationIndexPath.section)
             collectionView.insertItems(at: [indexPath])
         }
        
         if (collectionView.photoGroupType == .makeGroups)
         {
             collectionView.reloadSections([destinationIndexPath.section])
         }
        
         deleteEmptySections()
        
         PhotoFolderItem.removeEmptyFolders(from: photoSnippet)
        
         return newFolder
     }
    
     return nil
 }
//***************************************************************************************************************/
    
//MARK: -

//***************************************************************************************************************/
 func unfolderedLocalPhotoItems (in collectionView: PhotoSnippetCollectionView,
                                 at destinationIndexPath: IndexPath) -> [PhotoItemProtocol]
//***************************************************************************************************************/
 {
  let foldered = localFoldered
  if foldered.isEmpty {return []}
  var nextItemFlag = false
  var photoItemsMap: [IndexPath : [PhotoItem]] = [:]

  for item in foldered
  {
     if (nextItemFlag) {nextItemFlag = false; continue}
     let folder = PhotoFolderItem(folder: item.photo.folder!)
     let sourceIndexPath = photoItemIndexPath(photoItem: folder)!
   
     if let cell = collectionView.cellForItem(at: sourceIndexPath) as? PhotoFolderCell
     {
      let ip = cell.photoItemIndexPath(photoItem: item)!
      cell.photoItems.remove(at: ip.row)
      cell.photoCollectionView.deleteItems(at: [ip])
      
      if (cell.photoItems.count == 1)
      {
       photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
       PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: folder)
       let singleItem = cell.photoItems.remove(at: 0)
       cell.photoCollectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
       collectionView.deleteItems(at: [sourceIndexPath])
       
       if (singleItem.isSelected) {nextItemFlag = true}
       else
       {
        photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
        
        if (collectionView.photoGroupType == .makeGroups)
        {
         singleItem.priorityFlag = sectionTitles?[sourceIndexPath.section]
        }
        collectionView.insertItems(at: [sourceIndexPath])
        collectionView.reloadSections([sourceIndexPath.section])
       }//if (singleItem.isSelected)....
       if let zv = collectionView.zoomView {zv.removeZoomView()}
      }//if (cell.photoItems.count == 1)...
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
      
      let itemIndex = proxyPhotoItems.index{$0.id == item.id}
      proxyPhotoItems.remove(at: itemIndex!)
      photoItemsMap[sourceIndexPath] = proxyPhotoItems
     
      if (proxyPhotoItems.count == 1)
      {
       photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
       PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: folder)
       let singleItem = proxyPhotoItems.remove(at: 0)
       photoItemsMap[sourceIndexPath] = nil
       collectionView.deleteItems(at: [sourceIndexPath])
       
       if (singleItem.isSelected) {nextItemFlag = true}
       else
       {
        photoItems2D[sourceIndexPath.section].insert(singleItem, at: sourceIndexPath.row)
        
        if (collectionView.photoGroupType == .makeGroups)
        {
         singleItem.priorityFlag = sectionTitles?[sourceIndexPath.section]
        }
        collectionView.insertItems(at: [sourceIndexPath])
        collectionView.reloadSections([sourceIndexPath.section])
       } // if (singleItem.isSelected)...
       
       if let zv = collectionView.zoomView {zv.removeZoomView()}
      } //if (proxyPhotoItems.count == 1)...
     } //if let cell = collectionView.cellForItem...
   
     if let zv = collectionView.zoomView,
        let cv = zv.presentSubview as? UICollectionView,
        let ip = zv.photoItemIndexPath(photoItem: item)
     {
        zv.photoItems.remove(at: ip.row)
        cv.deleteItems(at: [ip])
     }//if let zv = collectionView.zoomView...
  } //for item in...
  
  let unfoldered = PhotoItem.unfolderPhotos(from: photoSnippet, to: photoSnippet) ?? []
  
  unfoldered.forEach
  {movedItem in
   
   photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
  
   if (collectionView.photoGroupType == .makeGroups)
   {
    movedItem.priorityFlag = sectionTitles?[destinationIndexPath.section]
   }
   
   collectionView.insertItems(at: [destinationIndexPath])
   collectionView.reloadSections([destinationIndexPath.section])
   
  }
 
  return unfoldered
 }
 //***************************************************************************************************************/
 
 //MARK: -

//***************************************************************************************************************/
 func movedOuterPhotoItems (in collectionView: PhotoSnippetCollectionView,
                            at destinationIndexPath: IndexPath) -> [PhotoItemProtocol]
//***************************************************************************************************************/
 {
 
  var movedItems: [PhotoItemProtocol] = []

  outerSnippets.forEach
  {source in
   
   let unfoldered: [PhotoItemProtocol] = PhotoItem.unfolderPhotos (from: source, to: photoSnippet) ?? []
   
   let folders:    [PhotoItemProtocol] = PhotoItem.moveFolders    (from: source, to: photoSnippet) ?? []
   let photos :    [PhotoItemProtocol] = PhotoItem.movePhotos     (from: source, to: photoSnippet) ?? []
   
    
   let totalMoved = photos + folders + unfoldered
    
   totalMoved.forEach
   {movedItem in
     photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
     if collectionView.photoGroupType == .makeGroups
     {
      movedItem.priorityFlag = sectionTitles?[destinationIndexPath.section]
     }
     collectionView.insertItems(at: [destinationIndexPath])

   }
    
   movedItems += totalMoved
            
  }
  
  if (collectionView.photoGroupType == .makeGroups && movedItems.count > 0)
  {
    collectionView.reloadSections([destinationIndexPath.section])
  }
  
  return movedItems
 }
//***************************************************************************************************************/

 //MARK: -
 
//***************************************************************************************************************/
 func performMergeIntoFolder ( in collectionView: PhotoSnippetCollectionView,
                                performDropWith coordinator: UICollectionViewDropCoordinator,
                                at destinationIndexPath: IndexPath)
//***************************************************************************************************************/
 {
  
  
  let local = localItems
  let unfold = unfolderedLocalPhotoItems (in: collectionView, at: destinationIndexPath)
  let moved = movedOuterPhotoItems (in: collectionView, at: destinationIndexPath)
  
  let totalItems = local + moved + unfold
  
  guard totalItems.count > 1 else {return}
  
  totalItems.forEach{$0.isSelected = true}

  if let newFolderItem = performMergeIntoFolder(collectionView, from: totalItems, into: destinationIndexPath)
  {
    let ip = photoItemIndexPath(photoItem: newFolderItem)
    if let cell = collectionView.cellForItem(at: ip!) as? PhotoFolderCell
    {
     coordinator.session.items.forEach{coordinator.drop($0, intoItemAt: destinationIndexPath, rect: cell.bounds)}
    }
    else
    {
      print ("\(#function): Invalid Merged Folder Cell at Index Path: \(ip!)")
    }
   
    if let zv = collectionView.zoomView
    {
     if let zoomedItem = zv.zoomedPhotoItem,
        let zoomedIndexPath = photoItemIndexPath(photoItem: zoomedItem)
     {
      zv.zoomedCellIndexPath = zoomedIndexPath
     }
     else if zv.zoomedCellIndexPath == destinationIndexPath,
             let newFolderCell = collectionView.cellForItem(at: destinationIndexPath) as? PhotoFolderCell
     {
      zv.zoomedPhotoItem = newFolderItem
      if zv.presentSubview is UIImageView
      {
       let cv = zv.openWithCV(in: view)
       zv.photoItems = newFolderCell.photoItems
       cv.reloadData()
      }
      else
      {
       let cv = zv.presentSubview as! UICollectionView
       let deleted = zv.photoItems
       deleted?.forEach
       {photo in
         let ip = zv.photoItemIndexPath(photoItem: photo)
         zv.photoItems.remove(at: ip!.row)
         cv.deleteItems(at: [ip!])
        
       }
       
       newFolderCell.photoItems.forEach
       {photo in
         zv.photoItems.insert(photo, at: 0)
         cv.insertItems(at: [IndexPath(row: 0, section: 0)])
       }
       
      }
     }
     else
     {
      zv.removeZoomView()
     }
    }
   
  }
  else
  {
    print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(destinationIndexPath)")
  }
    
 }
//***************************************************************************************************************/
    
 //MARK: -
    
//***************************************************************************************************************/
 func performItemsMove (  in collectionView: PhotoSnippetCollectionView,
                          performDropWith coordinator: UICollectionViewDropCoordinator,
                          at destinationIndexPath: IndexPath)
//***************************************************************************************************************/
 {
  
   localItems.forEach
   {photoItem in
      let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
      collectionView.movePhoto(sourceIndexPath: sourceIndexPath!, destinationIndexPath: destinationIndexPath)
      photoItem.isSelected = false
   }
    
   let outerItems = movedOuterPhotoItems      (in: collectionView,  at: destinationIndexPath)
   let unfoldered = unfolderedLocalPhotoItems (in: collectionView,  at: destinationIndexPath)
    
   //coordinator.session.items.forEach{coordinator.drop($0, toItemAt: destinationIndexPath)}
    
   let totalItems = localItems + outerItems + unfoldered
  
   if let zv = collectionView.zoomView, let zoomedItem = zv.zoomedPhotoItem
   {
    zv.zoomedCellIndexPath = photoItemIndexPath(photoItem: zoomedItem)
   }
    
   print ("TOTAL ITEMS MOVED SUCCESSFULLY TO \(destinationIndexPath) - \(totalItems.count)")
   
 }//func performItemsMove (_ collectionView: UICollectionView...
//***************************************************************************************************************/
    
//MARK: -
  
//***************************************************************************************************************/
 func movePhotosInsideApp (  in collectionView: PhotoSnippetCollectionView,
                             performDropWith coordinator: UICollectionViewDropCoordinator,
                             at destinationIndexPath: IndexPath)
//***************************************************************************************************************/
 {
    
   let dropItems = coordinator.items.filter{$0.sourceIndexPath != nil}

   if (dropItems.first{$0.sourceIndexPath == destinationIndexPath} != nil)
   {
    performMergeIntoFolder(in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
   }
   else
   {
    performItemsMove(in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
   }
  
  
    
 }//func movePhotosInsideCollectionView (_ collectionView: UICollectionView...
//***************************************************************************************************************/
    
//MARK: -
    
//***************************************************************************************************************/
 func copyPhotosFromSideApp (_ collectionView: PhotoSnippetCollectionView,
                              performDropWith coordinator: UICollectionViewDropCoordinator,
                              at destinationIndexPath: IndexPath)
//***************************************************************************************************************/
 {
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "PhotoSnippetCell")
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   {[weak self] item, error in
     OperationQueue.main.addOperation
     {
      guard let image = item as? UIImage else
      {
       placeholderContext.deletePlaceholder(); return
      }
      placeholderContext.commitInsertion
      {indexPath in
       let newPhotoItem = PhotoItem(photoSnippet: (self?.photoSnippet)!, image: image, cachedImageWidth:(self?.imageSize)!)
       if let flagStrs = self?.sectionTitles
       {
        newPhotoItem.photo.priorityFlag = flagStrs[indexPath.section]
       }
       self?.photoItems2D[indexPath.section].insert(newPhotoItem, at: indexPath.row)
      }
     }
    }
   }
 }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
//***************************************************************************************************************/
    
//MARK: -

//***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       performDropWith coordinator: UICollectionViewDropCoordinator)
//***************************************************************************************************************/
 {
   print (#function)
   PhotoSnippetViewController.printAllDraggedItems()
  
   let photoCV = collectionView as! PhotoSnippetCollectionView
    
   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
   switch (coordinator.proposal.operation)
   {
    case .move:
      if allPhotoItems.isEmpty {return}
      movePhotosInsideApp (in: photoCV, performDropWith: coordinator, at: destinationIndexPath)
    
    case .copy: copyPhotosFromSideApp (photoCV, performDropWith: coordinator, at: destinationIndexPath)
    default:
     print("OPERATION: \(coordinator.proposal.operation)")
    return
   }
  
  
  
 } //func collectionView(_ collectionView: UICollectionView, performDropWith...
//***************************************************************************************************************/
    
//MARK: -



}//extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate...


