
import Foundation
import CoreData
import UIKit


extension ZoomView: UICollectionViewDragDelegate, UICollectionViewDropDelegate
{
 
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
 {
  print (#function, self.debugDescription, session.description, session.items.count)
  AppDelegate.clearAllDragAnimationCancelWorkItems()

 }

 func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
 {
  print (#function, self.debugDescription, session.description)
 }
 
 
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
 {
  print (#function, self.debugDescription, session.description)
  AppDelegate.clearAllDraggedItems()
  
 }

 
 func getDragItems (_ collectionView: UICollectionView,
                      for session: UIDragSession,
                      forCellAt indexPath: IndexPath) -> [UIDragItem]
  
 {
  
  let photoItem = photoItems[indexPath.row]
  
  guard collectionView.cellForItem(at: indexPath) != nil else {return []}
  
  let itemProvider = NSItemProvider(object: photoItem)
  let dragItem = UIDragItem(itemProvider: itemProvider)
  
  
  guard allPhotoItems.lazy.first(where: {$0 === photoItem || $0 === zoomedPhotoItem}) == nil else {return []}
  
  AppDelegate.globalDragItems.append(photoItem)
  
  photoItem.isSelected = true      //make selected in MOC
  photoItem.isDragAnimating = true //start drag animation of associated view
  photoItem.dragSession = session  
  dragItem.localObject = photoItem
  AppDelegate.printAllDraggedItems()
  
  return [dragItem]
  
 }
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                       itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem]

 {
  print (#function, self.debugDescription, session.description)

  let itemsForBeginning = getDragItems(collectionView, for: session, forCellAt: indexPath)
  
  //Auto cancel all dragged PhotoItems only!
  itemsForBeginning.compactMap{$0.localObject as? PhotoItem}.forEach
  {item in
   let autoCancelWorkItem = DispatchWorkItem
   {
    item.clear(with: (forDragAnimating: AppDelegate.dragAnimStopDelay,
                      forSelected:      AppDelegate.dragUnselectDelay))
   }
   
   item.dragAnimationCancelWorkItem = autoCancelWorkItem
   let delay: DispatchTime = .now() + .seconds(AppDelegate.dragAutoCnxxDelay)
   DispatchQueue.main.asyncAfter(deadline: delay, execute: autoCancelWorkItem)
    
  }
  
  return itemsForBeginning
  
 }

 
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                       itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]

 {
    print (#function, self.debugDescription, session.description)
    return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }

 
 
 func collectionView(_ collectionView: UICollectionView,
                       dropSessionDidUpdate session: UIDropSession,
                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
   //print(#function)
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
 
 
 
 
 //-------------------------------------------------------------------------------------------------
 
 func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                             performDropWith coordinator: UICollectionViewDropCoordinator,
                             at destinationIndexPath: IndexPath)

 {
  print(#function)
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                     reuseIdentifier: "ZoomCollectionViewCell")
   
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   {[weak self] item, error in
    OperationQueue.main.addOperation
    {
     guard let image = item as? UIImage,
           let ip = self?.zoomedCellIndexPath,
           let vc = self?.photoSnippetVC,
           let imageSize = self?.imageSize,
           let zoomedCell = vc.photoCollectionView.cellForItem(at: ip) as? PhotoFolderCell
      
     else
     {
       placeholderContext.deletePlaceholder()
       return
     }
     
     placeholderContext.commitInsertion
     {indexPath in
      let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth:imageSize)
      zoomedCell.photoItems.insert(newPhotoItem, at: indexPath.row)
      zoomedCell.photoCollectionView.insertItems(at: [indexPath])
      self?.photoItems.insert(newPhotoItem, at: indexPath.row)
     }
    }
   }
  }
  
 }
 
 
 //-------------------------------------------------------------------------------------------------
 
 func moveItemInside(_ collectionView: UICollectionView,
                     in zoomedFolder: PhotoFolderItem,
                     item photoItem: PhotoItem,
                     to destinationIndexPath: IndexPath)
  
 //-------------------------------------------------------------------------------------------------
 {
  print (#function)
  
  guard let indexPath = photoItemIndexPath(photoItem: photoItem) else {return}
 
  photoItems.remove(at: indexPath.row) // remove local PhotoItem!!!
  self.photoItems.insert(photoItem, at: destinationIndexPath.row) //but insert dragged one!!!
  collectionView.moveItem(at: indexPath, to: destinationIndexPath)
  collectionView.reloadItems(at: [destinationIndexPath])
  
  if let zoomedIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: zoomedFolder),
     let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedIndexPath) as? PhotoFolderCell,
     let indexPath = zoomedCell.photoItemIndexPath(photoItem: photoItem)
  {
  
   zoomedCell.photoItems.remove(at: indexPath.row) // remove local PhotoItem!!!
   zoomedCell.photoItems.insert(photoItem, at: destinationIndexPath.row) //but insert dragged one!!!
   zoomedCell.photoCollectionView.moveItem(at: indexPath, to: destinationIndexPath)
   zoomedCell.photoCollectionView.reloadItems(at: [destinationIndexPath])
   
  }
 }
 
 //-------------------------------------------------------------------------------------------------
 
 func moveFromOtherFolderItem(_ collectionView: UICollectionView,   // Zoom View CV
                                in zoomedFolder: PhotoFolderItem,   // Main PhotoSnippet CV zoomed folder
                                item photoItem: PhotoItem,          // Dragged PhotoItem with boxed Photo MO.
                                from photoFolder: PhotoFolder,      // Source PhotoFolder MO
                                to destinationIndexPath: IndexPath) // Destination IndexPath in Zoom View CV
 
 //-------------------------------------------------------------------------------------------------
 // Moves dragged visible CV cell to ZoomedView CV and underlying Photo MO from visible folder of this PhotoSnippet VC or
 // from outer PhotoSnippet
 //-------------------------------------------------------------------------------------------------
 {
  print (#function)
 
  defer //finally insert moved....
  {
   self.photoItems.insert(photoItem, at: destinationIndexPath.row)
   collectionView.insertItems(at: [destinationIndexPath])
   
   if let zoomedIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: zoomedFolder),
      let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedIndexPath) as? PhotoFolderCell
   {
    zoomedCell.photoItems.insert(photoItem, at: destinationIndexPath.row)
    zoomedCell.photoCollectionView.insertItems(at: [destinationIndexPath])
   }
   
  }
  
  let proxyFolderItem = PhotoFolderItem(folder: photoFolder) //Create proxy folder to check if belongs to this snippet
  
  guard let folderIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: proxyFolderItem) else { return }
  //Dragged PhotoItem wrapping Photo MO is owned by the PhotoSnippet of this PhotoSnippetVC PhotoItems2D
 
  switch photoFolder.count
  {
   case 0...1: break //error folder with 1 or 0 elements inside!
   case 2:
    
    let singlePhoto = photoFolder.folderedPhotos.first{$0 !== photoItem.photo}
    let singlePhotoItem = PhotoItem(photo: singlePhoto!)
    
    photoSnippetVC.photoItems2D[folderIndexPath.section][folderIndexPath.row] = singlePhotoItem
    photoSnippetVC.photoCollectionView.reloadItems(at: [folderIndexPath])

   default:
  
    if let folderCell = photoSnippetVC.photoCollectionView.cellForItem(at: folderIndexPath) as? PhotoFolderCell,
       let cellIndexPath = folderCell.photoItemIndexPath(photoItem: photoItem)
    //Dragged PhotoItem Folder Cell is visible in the PhotoSnippet CV, upadate FolderCell CV
    {
     folderCell.photoItems.remove(at: cellIndexPath.row)
     folderCell.photoCollectionView.deleteItems(at: [cellIndexPath])
    }
  }
 }//func moveFromOtherFolderItem...


 
 //-------------------------------------------------------------------------------------------------
 
 func moveEntireFolderItem(_ collectionView: UICollectionView,      // Zoom View CV
                             in zoomedFolder: PhotoFolderItem,      // Main PhotoSnippet CV zoomed folder
                             item photoFolderItem: PhotoFolderItem, // Dragged PhotoFolderItem
                             to destinationIndexPath: IndexPath)    // Destination IndexPath in Zoom View CV
  
 //-------------------------------------------------------------------------------------------------
 // Moves dragged visible CV Folder cell to ZoomedView CV and all its underlying Photo MOs from visible folder of this
 // PhotoSnippet VC or from outer PhotoSnippet. The emptified visible CV cell and undelying PhotoFolder MO is to deleted
 //-------------------------------------------------------------------------------------------------
 {
  print (#function)
  
  guard zoomedFolder !== photoFolderItem else {return}// Disallow dropping ZoomedFolder into self!!!
 
  let singlePhotoItems = photoFolderItem.singlePhotoItems
 
  if let folderIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: photoFolderItem)
  //Dragged PhotoFolderItem wrapping PhotoFolder MO is owned by the PhotoSnippet of this PhotoSnippetVC PhotoItems2D.
  {
   photoSnippetVC.photoItems2D[folderIndexPath.section].remove(at: folderIndexPath.row)
   photoSnippetVC.photoCollectionView.deleteItems(at: [folderIndexPath])
   photoSnippetVC.photoCollectionView.updateSection(sectionIndex: folderIndexPath.section)
  }
 
  self.photoItems.insert(contentsOf: singlePhotoItems, at: destinationIndexPath.row)
  let destIndexPaths = Array(repeating: destinationIndexPath, count: singlePhotoItems.count)
  collectionView.insertItems(at: destIndexPaths)
 
  if let zoomedIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: zoomedFolder),
     let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedIndexPath) as? PhotoFolderCell
  {
   zoomedCell.photoItems.insert(contentsOf: singlePhotoItems, at: destinationIndexPath.row)
   zoomedCell.photoCollectionView.insertItems(at: destIndexPaths)
  }
  
  
 }
 

 
 
 
 func moveUnfolderedItem(_ collectionView: UICollectionView,
                          in zoomedFolder: PhotoFolderItem,
                          item photoItem: PhotoItem,
                          to destinationIndexPath: IndexPath)
 
 {
  print (#function)
  
  if let photoIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: photoItem) //inner item in this photo snippet
  {
   photoSnippetVC.photoItems2D[photoIndexPath.section].remove(at: photoIndexPath.row)
   photoSnippetVC.photoCollectionView.deleteItems(at: [photoIndexPath])

  }
 
  self.photoItems.insert(photoItem, at: destinationIndexPath.row)
  collectionView.insertItems(at: [destinationIndexPath])
  
  if let zoomedIndexPath = photoSnippetVC.photoItemIndexPath(photoItem: zoomedFolder),
     let zoomedCell = photoSnippetVC.photoCollectionView.cellForItem(at: zoomedIndexPath) as? PhotoFolderCell
  {
   zoomedCell.photoItems.insert(photoItem, at: destinationIndexPath.row)
   zoomedCell.photoCollectionView.insertItems(at: [destinationIndexPath])
   zoomedCell.photoCollectionView.reloadItems(at: [destinationIndexPath])
  }
 }//func moveUnfolderedItem(_ collectionView: UICollectionView,...
 
 
 
 
 //Drags from outer snippets:
 // Task - 1 (+): Drag outer snippet 1 & > unfoldered photo and drop it into this snippet zoomed folder
 // Task - 2 (+): Drag outer snippet 1 foldered photo and drop it into this snippet zoomed folder
 // Task - 3 (+): Drag outer snippet 1 whole photo folder and drop it into this snippet zoomed folder
 // Task - 4 (+): Drag outer snippet 1 foldered photo from the same outer folder with only 2 items
 // Task - 5 (+): Drag outer snippet N foldered photo from the same outer folder with N + 1 items
 // Task - 6 (+): Drag outer snippet N foldered photo from the same outer folder with N  items
 
 // Task - 7 (+): Drag outer snippet 1 folder + 1 unfoldered + 1 foldered (from folder with 2 items) photo and drop it
 // Task - 8 (+): Drag outer snippet 1 folder + 1 unfoldered + 1 foldered (from folder with >2 items) photo and drop it
 // Task - 9 (+): Drag outer snippet 1 folder + 1 unfoldered + 2 foldered (from folder with 2 items) photo and drop it
 // Task - 10(+): Drag outer snippet N folders + M unfoldered + K foldered (from different folders) photos and drop it

 //Drag inside snippet:
 //Task - 1 (+): Drag N unfoldered into zoomed folder
 //Task - 2 (+): Drag N foldered into zoomed folder
 //Task - 3 (+): Drag N foldered & M unfoldered into zoomed folder
 //Task - 4 (+): Drag 1 folder into self zoomed folder!
 //Task - 5 (+): Drag N folders into zoomed folder
 //Task - 6 (+): Drag K folders + M unfoldered + N foldered (from the folder with N+1 items) into zoomed folder
 //Task - 7 (+): Drag 1 folder + N  foldered belonging to this folder into zoomed folder
 
 
 
 func moveInAppItems(_ collectionView: UICollectionView,
                       performDropWith coordinator: UICollectionViewDropCoordinator,
                       to destinationIndexPath: IndexPath)
 
 {
  print (#function)
  
  defer { photoSnippetVC.updateMovedItemsSections() }
 
  guard let zoomedFolder = zoomedPhotoItem as? PhotoFolderItem else { return }
  
  let draggedItems = AppDelegate.globalDragItems.filter{$0.dragSession != nil} //filter out not cancelled items!
  
  draggedItems.forEach
  {dragItem in
   defer { dragItem.move(to: photoSnippet, to: zoomedFolder) } //just make finally move in MOC...
   switch dragItem
   {
    case let photoItem as PhotoItem: //dragging PhotoItem...
     photoItem.moveToDrops()
     switch (photoItem.folder, photoItem.folder === zoomedFolder.folder)
     {
      case  ( _?, true) :
        moveItemInside(collectionView, in: zoomedFolder, item: photoItem, to: destinationIndexPath)
      case  let (photoFolder?, false):
       moveFromOtherFolderItem(collectionView, in: zoomedFolder, item: photoItem,
                               from: photoFolder, to: destinationIndexPath)
      case (nil, _):
       moveUnfolderedItem(collectionView, in: zoomedFolder, item: photoItem, to: destinationIndexPath)
   
     }
    
    case let folderItem as PhotoFolderItem: //dragging FolderItem...
     folderItem.moveToDrops(allNestedItems: true)
     moveEntireFolderItem(collectionView,in: zoomedFolder, item: folderItem, to: destinationIndexPath)
    
    default: break
   }
  }
 }//func moveInAppItems(_ collectionView: UICollectionView...
 
 

 func collectionView(_ collectionView: UICollectionView,
                       performDropWith coordinator: UICollectionViewDropCoordinator)

 {
  print (#function, self.debugDescription, coordinator.session)
  
  guard let destinationIndexPath = coordinator.destinationIndexPath else {return}
  
  switch (coordinator.proposal.operation)
  {
   case .move: moveInAppItems        (collectionView, performDropWith: coordinator, to: destinationIndexPath)
   case .copy: copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
   default: break
  }
  

 } //func collectionView(_ collectionView: UICollectionView, performDropWith...
 
 
 
}
