//
//  MAIN CV D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 30/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate, PhotoItemsDraggable
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
  
  print (#function, self.debugDescription, session.description)
  
  guard collectionView.cellForItem(at: indexPath) != nil else { return [] }
  
  let dragged = photoItems2D[indexPath.section][indexPath.row]
  
  guard dragged.isDraggable else { return [] } //check up if it is really eligible for drags...
  
  let itemProvider = NSItemProvider(object: dragged)
  let dragItem = UIDragItem(itemProvider: itemProvider)
  
  AppDelegate.globalDragItems.append(dragged) //if all OK put it in drags first...
  dragged.isSelected = true                   //make selected in MOC
  dragged.isDragAnimating = true              //start drag animation of associated view
  dragged.dragSession = session
  dragItem.localObject = dragged
  
  AppDelegate.printAllDraggedItems()
 
  return [dragItem]
  
 }
 
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                     itemsForBeginning session: UIDragSession,
                     at indexPath: IndexPath) -> [UIDragItem]
  
 {
  print (#function, self.debugDescription, session.description)
  
  let itemsForBeginning = getDragItems(collectionView, for: session, forCellAt: indexPath)
  
  //Auto cancel all dragged PhotoFolderItems and PhotoItems as PhotoItemProtocol!
  itemsForBeginning.compactMap{$0.localObject as? PhotoItemProtocol}.forEach
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
 
 
 func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                             performDropWith coordinator: UICollectionViewDropCoordinator,
                             at destinationIndexPath: IndexPath)
 
 {
  PhotoItem.MOC.persistAndWait
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
         placeholderContext.deletePlaceholder()
         return
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
  }
 }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
 
 
 
 
 func insertSingleFolderItem(item singlePhotoItem: PhotoItem)
 {
  var singleItemSection: Int?
  
  defer //finally insert single item of deleted folder into proper CV section...
  {
   let rowCount = self.photoItems2D[singleItemSection!].count
   let singleItemIndexPath = IndexPath(row: rowCount, section: singleItemSection!)
   self.photoItems2D[singleItemSection!].insert(singlePhotoItem, at: rowCount)
   self.photoCollectionView.insertItems(at: [singleItemIndexPath])
  }
  
  switch (photoCollectionView.photoGroupType, sectionTitles)
  {
   case (.makeGroups, let titles?):
    singleItemSection = titles.index{$0 == singlePhotoItem.priorityFlag ?? ""}
    
    if singleItemSection == nil
    {
     singleItemSection = self.photoItems2D.filter
     {section in
      self.photoSnippet.ascending ? (section.first?.priority ?? -1) < singlePhotoItem.priority:
                                    (section.first?.priority ?? -1) > singlePhotoItem.priority
     }.count
     
     self.photoItems2D.insert([], at: singleItemSection!)
     self.sectionTitles?.insert(singlePhotoItem.priorityFlag ?? "", at: singleItemSection!)
     self.insertedSections.insert(singleItemSection!)
     self.photoCollectionView.insertSections([singleItemSection!])
   }
   
   default: singleItemSection = 0 //if no grouping by sections we insert finally into 0 section!
  }
  
 } //func insertSingleFolderItem...
 
 
 
 
 func updateFolderSingleItems()
 {
  switch (photoCollectionView.photoGroupType, sectionTitles)
  {
   case ( .makeGroups,  let titles? ):
    self.photoItems2D.enumerated().map
    {s in s.1.compactMap{$0 as? PhotoItem}.filter{$0.priorityFlag ?? "" != titles[s.0]}}.flatMap{$0}.forEach
    {singleItem in
     guard let indexPath = self.photoItemIndexPath(photoItem: singleItem) else {return}
     self.photoItems2D[indexPath.section].remove(at: indexPath.row)
     self.photoCollectionView.deleteItems(at: [indexPath])
     self.insertSingleFolderItem(item: singleItem)
    }
   
   default: break
  }
  
 }//func updateFolderSingleItems...
 
 func updateEmptySectionsAndFooters()
 {
  photoItems2D.enumerated().map{$0.offset}.sorted(by: >).forEach
  {sectionIndex in
   let itemsCount = photoItems2D[sectionIndex].count
   if itemsCount == 0
   {
    photoItems2D.remove(at: sectionIndex)
    sectionTitles?.remove(at: sectionIndex)
    photoCollectionView.deleteSections([sectionIndex])
   }
   else
   {
    let kind = UICollectionElementKindSectionFooter
    let indexPath = IndexPath(row: 0, section: sectionIndex)
    
    if let footer = photoCollectionView.supplementaryView(forElementKind: kind, at: indexPath) as? PhotoSectionFooter
    {
     footer.footerLabel.text = NSLocalizedString("Total photos in group", comment: "Total photos in group") + ": \(itemsCount)"
    }
   }
  }
 } //func updateFolderSingleItems...
 
 
 
 
 func updateMovedItemsSections()
 {
   print (#function)
  
   updateFolderSingleItems()
   updateEmptySectionsAndFooters()
 } //func updateMovedItemsSections...
 
 
 
 func insertMovedItem (item photoItem: PhotoItemProtocol,
                       to destinationIndexPath: IndexPath,
                       completion: (()->())? = nil)
 {

  print (#function)
  
  self.currentFRC?.deactivateDelegate()
  photoSnippet.managedObjectContext?.persist(block:
  {
   switch (self.photoCollectionView.photoGroupType, self.sectionTitles)
   {
    case (.makeGroups, let titles?): photoItem.priorityFlag = titles[destinationIndexPath.section]
    default: break
   }
   
  })
  {flag in
   guard flag else {return}
   let sectionCount = self.photoItems2D[destinationIndexPath.section].count
   let maxSectionIndexPath = IndexPath(row: sectionCount, section: destinationIndexPath.section)
   let indexPath = min(destinationIndexPath, maxSectionIndexPath)
   self.photoItems2D[destinationIndexPath.section].insert(photoItem, at: indexPath.row)
   self.photoCollectionView.insertItems(at: [indexPath])
   self.currentFRC?.activateDelegate()
   completion?()
  }
  
 }//func insertMovedItem (item photoItem: PhotoItemProtocol...
 
 
 
 func moveUnfolderedItem( item photoItem: PhotoItemProtocol,
                          to destinationIndexPath: IndexPath,  completion: (()->())? = nil )
 
  
 {
  print (#function)
  
  defer //finally insert dragged item into the main CV async with completion...
  {
   insertMovedItem(item: photoItem, to: destinationIndexPath){ completion?() }
  }
  
  guard let sourceIndexPath = self.photoItemIndexPath(photoItem: photoItem) else {return}
  //inner item in this photo snippet

  self.photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
  self.photoCollectionView.deleteItems(at: [sourceIndexPath])

  //if zoomView is open during the drop showing zoomed-in single source PhotoItem we remove it from screen
  guard let zoomView = photoCollectionView.zoomView else { return }
  guard zoomView.zoomedPhotoItem?.hostedManagedObject === photoItem.hostedManagedObject else { return }
  zoomView.removeZoomView()
 

 }//func moveUnfolderedItem(_ collectionView: UICollectionView,...
 

 
 
 func moveFolderedItem(  item photoItem: PhotoItem,
                         from photoFolder: PhotoFolder,
                         to destinationIndexPath: IndexPath, completion: (()->())? = nil )
 {
  print (#function)
  
  var singleSection: Int?
  
  defer //finally insert dragged async with completion...
  {
   insertMovedItem(item: photoItem, to: destinationIndexPath){ completion?() }
  }
 
  let proxyFolderItem = PhotoFolderItem(folder: photoFolder) //Create proxy folder to check if belongs to this snippet
  
  //Dragged PhotoItem wrapping Photo MO is owned by the PhotoSnippet of this PhotoItems2D...
  guard let folderIndexPath = self.photoItemIndexPath(photoItem: proxyFolderItem) else {return}
  
  switch photoFolder.count
  {
   case 0...1: break //error folder with 1 or 0 elements inside!
   case 2:
    
    let singlePhoto = photoFolder.folderedPhotos.first{$0 !== photoItem.photo}
    let singlePhotoItem = PhotoItem(photo: singlePhoto!)
    
    defer
    {
     self.photoItems2D[folderIndexPath.section][folderIndexPath.row] = singlePhotoItem
     self.photoCollectionView.reloadItems(at: [folderIndexPath])
    }
    
    //if zoomView is open during the drop showing zoomed-in source PhotoFolder we turn it into the single photo item IV.
    guard let zoomView = photoCollectionView.zoomView else                   { break }
    guard zoomView.zoomedPhotoItem?.hostedManagedObject === photoFolder else { break }
    zoomView.zoomedPhotoItem = singlePhotoItem
    
    let iv = zoomView.openWithIV(in: self.view)
    singlePhotoItem.getImageOperation(requiredImageWidth: zoomView.zoomSize)
    {image in
     zoomView.stopSpinner()
     iv.image = image
    }
   
   default:
    
    if let folderCell = self.photoCollectionView.cellForItem(at: folderIndexPath) as? PhotoFolderCell,
       let cellIndexPath = folderCell.photoItemIndexPath(photoItem: photoItem)
       //Dragged PhotoItem Folder Cell is visible in the PhotoSnippet CV, upadate FolderCell CV
    {
     folderCell.photoItems.remove(at: cellIndexPath.row)
     folderCell.photoCollectionView.deleteItems(at: [cellIndexPath])
    }
    
    //if zoomView is open during the drop showing zoomed in source PhotoFolder we remove dragged item from Zoom CV
    guard let zoomView = self.photoCollectionView.zoomView else                          { break }
    guard zoomView.zoomedPhotoItem?.hostedManagedObject === photoFolder else             { break }
    guard let zoomCellIndexPath = zoomView.photoItemIndexPath(photoItem: photoItem) else { break }
    
    zoomView.photoItems.remove(at: zoomCellIndexPath.row)
    (zoomView.presentSubview as? UICollectionView)?.deleteItems(at: [zoomCellIndexPath])
   
  }
  
 }//func moveUnfolderedItem(_ collectionView: UICollectionView,...
 
 
 
 func moveInAppItems(_ collectionView: UICollectionView,
                     performDropWith coordinator: UICollectionViewDropCoordinator,
                     to destinationIndexPath: IndexPath)
  
 {
  print (#function)
  
  let group = DispatchGroup()
  
  defer //finally update sections after all commited drops in case of sectioned items...
  {
   group.notify(queue: DispatchQueue.main) { self.updateMovedItemsSections() }
  }
  
  let draggedItems = AppDelegate.globalDragItems.filter{$0.dragSession != nil} //filter out not cancelled items!
  
  draggedItems.forEach
  {dragItem in
   defer { dragItem.move(to: photoSnippet, to: nil) } //finally commit underlying MO move changes in MOC.
   dragItem.moveToDrops()
   group.enter()
   switch dragItem
   {
    case let photoItem as PhotoItem: //dragging PhotoItem...
     switch photoItem.folder
     {
      case let photoFolder?: //if item nested in folder...
       moveFolderedItem(item: photoItem, from: photoFolder, to: destinationIndexPath) { group.leave() }
      
      case nil: //if not nested...
       moveUnfolderedItem(item: photoItem, to: destinationIndexPath) { group.leave() }
     }
    
    case let folderItem as PhotoFolderItem: //dragging FolderItem...
     moveUnfolderedItem(item: folderItem, to: destinationIndexPath) { group.leave() }
 
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
   case .move:  moveInAppItems        (collectionView, performDropWith: coordinator, to: destinationIndexPath)
   case .copy:  copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
   default: break
  }
  
  
 }//func collectionView(_ collectionView: UICollectionView, performDropWith...
 
 
}
