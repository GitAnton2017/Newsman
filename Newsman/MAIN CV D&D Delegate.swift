
import Foundation
import CoreData
import UIKit

//MARK: -

//***************************************************************************************************************
extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate
//***************************************************************************************************************/
{
 
//MARK: -
 
class func printAllDraggedItems()
{
 (UIApplication.shared.delegate as! AppDelegate).globalDragItems.forEach
 {
  print("DRAG ITEM ID: \(($0 as! PhotoItemProtocol).id) DRAG SESSION: \(String(describing: ($0 as! PhotoItemProtocol).dragSession))")
 }
}
 
class func removeDraggedItem(PhotoItemToRemove: PhotoItemProtocol)
{
 if let index = (UIApplication.shared.delegate as! AppDelegate).globalDragItems.index(where:
 {
  if let photoItem = $0 as? PhotoItemProtocol, photoItem.id == PhotoItemToRemove.id {return true}
  return false
 })
 {
  (UIApplication.shared.delegate as! AppDelegate).globalDragItems.remove(at: index)
 }
}
 
class func clearAllDraggedItems()
{
 let globalDragItems = (UIApplication.shared.delegate as! AppDelegate).globalDragItems
 
 (UIApplication.shared.delegate as! AppDelegate).globalDragItems.removeAll()
 
 globalDragItems.forEach
 {item in
   if let photoItem = item as? PhotoItemProtocol {photoItem.isSelected = false}
 }
}
 
//***************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
//***************************************************************************************************************
 {
  print (#function)
  
  PhotoSnippetViewController.clearAllDraggedItems()
  
 }
//***************************************************************************************************************
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
//***************************************************************************************************************
 {
  
  print (#function, session.items.count)
 
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
  {anyItem in
   if let photoItem = anyItem as? PhotoItemProtocol, photoItem.dragSession == nil {return true}
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
 func getDragItems (_ collectionView: UICollectionView,
                      for session: UIDragSession,
                      forCellAt indexPath: IndexPath) -> [UIDragItem]
//***************************************************************************************************************
 {
  
  PhotoSnippetViewController.clearCancelledDraggedItems()
  
  let photoItem = photoItems2D[indexPath.section][indexPath.row]
  
  if collectionView.cellForItem(at: indexPath) != nil
  {
   let itemProvider = NSItemProvider(object: photoItem)
   let dragItem = UIDragItem(itemProvider: itemProvider)
 
   for item in (UIApplication.shared.delegate as! AppDelegate).globalDragItems
   {
    if let photoGlobalItem = item as? PhotoItemProtocol, photoGlobalItem.id == photoItem.id
    {
     return []
    }
   }
   
   (UIApplication.shared.delegate as! AppDelegate).globalDragItems.append(photoItem)
   photoItem.isSelected = true
   photoItem.dragSession = session
   dragItem.localObject = photoItem
   
   PhotoSnippetViewController.printAllDraggedItems()
   
   return [dragItem]
   
  }
  else
  {
    return []
  }

 }
/***************************************************************************************************************/
    
//MARK: -
    
/***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem]
/***************************************************************************************************************/
 {
  print (#function)
  return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }
/***************************************************************************************************************/
 
 //MARK: -
    
/***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
/***************************************************************************************************************/
 {
  print (#function)
  return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }
/***************************************************************************************************************/
    
 //MARK: -

/***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       dropSessionDidUpdate session: UIDropSession,
                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
/***************************************************************************************************************/
    
 {
  
  if session.localDragSession != nil
  {
    
    if session.items.count == 1
    {
      return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
  }
  else
  {
   return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
  }
 }
/***************************************************************************************************************/
    
//MARK: -
    
/***************************************************************************************************************/
 func performMergeIntoFolder (_ collectionView: PhotoSnippetCollectionView,
                                from photoItems: [PhotoItemProtocol],
                                into destinationIndexPath: IndexPath) -> PhotoFolderItem?
/***************************************************************************************************************/
 {
     if let newFolder = PhotoFolderItem(photoSnippet: photoSnippet)
     {
         newFolder.priorityFlag = sectionTitles?[destinationIndexPath.section]
         photoItems.forEach
         {photoItem in
            let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
            photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
            PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: photoItem)
            collectionView.deleteItems(at: [sourceIndexPath])
            
            if (collectionView.photoGroupType == .makeGroups && sourceIndexPath.section != destinationIndexPath.section)
            {
             collectionView.reloadSections([sourceIndexPath.section])
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
/***************************************************************************************************************/
    
//MARK: -
    
/***************************************************************************************************************/
 func movedOuterPhotoItems (_ globalPhotoItems: [PhotoItemProtocol],
                              in collectionView: PhotoSnippetCollectionView,
                              at destinationIndexPath: IndexPath) -> [PhotoItemProtocol]
/***************************************************************************************************************/
 {
 
  var movedItems: [PhotoItemProtocol] = []

  globalPhotoItems.map{$0.photoSnippet}.filter{$0 !== photoSnippet}.forEach
  {source in
   let folders: [PhotoItemProtocol] = PhotoItem.moveFolders(from: source, to: photoSnippet) ?? []
   let photos : [PhotoItemProtocol] = PhotoItem.movePhotos (from: source, to: photoSnippet) ?? []
    
   let totalMoved = photos + folders
    
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
/***************************************************************************************************************/
    
//MARK: -
    
/***************************************************************************************************************/
 func performMergeIntoFolder (_ globalPhotoItems: [PhotoItemProtocol],
                                in collectionView: PhotoSnippetCollectionView,
                                performDropWith coordinator: UICollectionViewDropCoordinator,
                                at destinationIndexPath: IndexPath)
/***************************************************************************************************************/
 {
    
  let localItems = globalPhotoItems.filter{$0.photoSnippet === photoSnippet}
  let outerItems = movedOuterPhotoItems(globalPhotoItems, in: collectionView,  at: destinationIndexPath)
  let totalItems = localItems + outerItems
  
  guard totalItems.count > 1 else {return}
  
  outerItems.forEach{$0.isSelected = true}

  if let newFolderItem = performMergeIntoFolder(collectionView, from: totalItems, into: destinationIndexPath)
  {
    let ip = photoItemIndexPath(photoItem: newFolderItem)
    if let cell = collectionView.cellForItem(at: ip) as? PhotoFolderCell
    {
     coordinator.session.items.forEach{coordinator.drop($0, intoItemAt: destinationIndexPath, rect: cell.bounds)}
    }
    else
    {
      print ("\(#function): Invalid Merged Folder Cell at Index Path: \(ip)")
    }
  }
  else
  {
    print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(destinationIndexPath)")
  }
    
 }
/***************************************************************************************************************/
    
 //MARK: -
    
/***************************************************************************************************************/
 func performItemsMove (_ globalPhotoItems: [PhotoItemProtocol],
                          in collectionView: PhotoSnippetCollectionView,
                          performDropWith coordinator: UICollectionViewDropCoordinator,
                          at destinationIndexPath: IndexPath)
/***************************************************************************************************************/
 {
    
   let localItems = globalPhotoItems.filter{$0.photoSnippet === photoSnippet}
    
   localItems.forEach
   {photoItem in
      let sourceIndexPath = photoItemIndexPath(photoItem: photoItem)
      collectionView.movePhoto(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    
   }
    
   let outerItems = movedOuterPhotoItems(globalPhotoItems, in: collectionView,  at: destinationIndexPath)
    
   coordinator.session.items.forEach{coordinator.drop($0, toItemAt: destinationIndexPath)}
    
   let totalItems = localItems + outerItems
    
   print ("TOTAL ITEMS MOVED SUCCESSFULLY TO \(destinationIndexPath) - \(totalItems.count)")
   
 }//func performItemsMove (_ collectionView: UICollectionView...
/***************************************************************************************************************/
    
//MARK: -
  
/***************************************************************************************************************/
 func movePhotosInsideApp (_ globalPhotoItems: [PhotoItemProtocol],
                             in collectionView: PhotoSnippetCollectionView,
                             performDropWith coordinator: UICollectionViewDropCoordinator,
                             at destinationIndexPath: IndexPath)
/***************************************************************************************************************/
 {
    
   let dropItems = coordinator.items.filter{$0.sourceIndexPath != nil}

   if (dropItems.first{$0.sourceIndexPath == destinationIndexPath} != nil)
   {
    performMergeIntoFolder(globalPhotoItems, in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
   }
   else
   {
    performItemsMove(globalPhotoItems, in: collectionView, performDropWith: coordinator, at: destinationIndexPath)
   }
    
 }//func movePhotosInsideCollectionView (_ collectionView: UICollectionView...
/***************************************************************************************************************/
    
//MARK: -
    
/***************************************************************************************************************/
 func copyPhotosFromSideApp (_ collectionView: PhotoSnippetCollectionView,
                              performDropWith coordinator: UICollectionViewDropCoordinator,
                              at destinationIndexPath: IndexPath)
/***************************************************************************************************************/
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
/***************************************************************************************************************/
    
//MARK: -

    
/***************************************************************************************************************/
 func collectionView(_ collectionView: UICollectionView,
                       performDropWith coordinator: UICollectionViewDropCoordinator)
/***************************************************************************************************************/
 {
   print (#function)
   let photoCV = collectionView as! PhotoSnippetCollectionView
    
   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
    
   switch (coordinator.proposal.operation)
   {
    case .move:
     var globalPhotoItems: [PhotoItemProtocol] = []
     
     for item in (UIApplication.shared.delegate as! AppDelegate).globalDragItems
     {
      if let photoItem = item as? PhotoItemProtocol
      {
       globalPhotoItems.append(photoItem)
      }
     }
     
     if globalPhotoItems.isEmpty {return}
     
     movePhotosInsideApp (globalPhotoItems, in: photoCV, performDropWith: coordinator, at: destinationIndexPath)
  
    
    case .copy:
     copyPhotosFromSideApp (photoCV, performDropWith: coordinator, at: destinationIndexPath)
    default: return
   }
  
  
  
 } //func collectionView(_ collectionView: UICollectionView, performDropWith...
/***************************************************************************************************************/
    
//MARK: -



}//extension PhotoSnippetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate...


