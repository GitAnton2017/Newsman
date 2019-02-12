import Foundation
import UIKit
import CoreData

protocol Draggable: class
{
 var dragSession: UIDragSession?    { get set }
 var id: UUID                       { get     }
 
 var hostedManagedObject: NSManagedObject  { get } //ref to the MO wrapped in conformer
 
 var isSelected: Bool               { get set } //managed state by MO wrapped in conformer...
 var isDragAnimating: Bool          { get set } //not managed...
 var isSetForClear: Bool            { get set } //not managed...
 //this state is traced to avoid multiple clearance animations to be fired for cell when drop session ends...
 
 var isFolderDragged: Bool          { get }
 var isZoomed: Bool                 { get set }

 var dragAnimationCancelWorkItem: DispatchWorkItem? {get set}
 
 func move(to snippet: PhotoSnippet, to photoItem: PhotoItemProtocol?)
}



func == (lhs: Draggable?, rhs: Draggable?) -> Bool
{
 return lhs?.hostedManagedObject === rhs?.hostedManagedObject
}



extension Draggable
{
 var isDraggable: Bool
 {
  return !(isDragAnimating || isSetForClear || isFolderDragged)
 }
 
 func clear (with delays: (forDragAnimating: Int, forSelected: Int), completion: (()->())? = nil)
 {
 
  if isSetForClear {return}
  
  print (#function, self, self.dragSession ?? "No session")
  
  dragAnimationCancelWorkItem = nil
  
  isSetForClear = true //this flag is set when clear block is about to fire to avoid multiple calls of clear()
  
  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delays.forDragAnimating))
  {
   self.isDragAnimating = false
   DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delays.forSelected))
   {
    self.isSelected = false
    self.isSetForClear = false  //unset flag after full completion
    self.remove()
    completion?()               //fire completion handler for additional post animation actions if any needed
   }
  }
 }
 
 func moveToDrops(allNestedItems flag: Bool = false)
 {
  AppDelegate.globalDragItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
  switch (self, flag)
  {
   case     (_ , false):
    AppDelegate.globalDropItems.append(self)
   case let (folderItem as PhotoFolderItem, true):
    folderItem.isSelected = false
    folderItem.isDragAnimating = false
    AppDelegate.globalDropItems.append(contentsOf: folderItem.singlePhotoItems)
   default: break
  }
 }
 
 func remove()
 {
  print (#function, self, self.dragSession ?? "No session")
  
  //remove drag item from drags personally if found...
  AppDelegate.globalDragItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
 
  //remove drag item from drops personally if found...
  AppDelegate.globalDropItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
 }
 
}

protocol PhotoItemsDraggable: class
{
 var photoSnippet: PhotoSnippet!    { get  set }
 var photoSnippetVC: PhotoSnippetViewController! { get set }
}

extension PhotoItemsDraggable
{
 
 var allPhotoItems: [PhotoItemProtocol]
 {
  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoItemProtocol}
 }
 
 var allPhotos: [PhotoItem]
 {
  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoItem}
 }
 
 var allFolders: [PhotoFolderItem]
 {
  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoFolderItem}
 }
 
 var localPhotos: [PhotoItem]
 {
  return allPhotos.filter{$0.photoSnippet === photoSnippet && $0.photo.folder == nil}
 }
 
 var localFolders: [PhotoFolderItem]
 {
  return allFolders.filter{$0.photoSnippet === photoSnippet}
 }
 
 var localItems: [PhotoItemProtocol]
 {
  return localPhotos as [PhotoItemProtocol] + localFolders as [PhotoItemProtocol]
 }
 
 var localFoldered: [PhotoItem]
 {
  return allPhotos.filter{$0.photoSnippet === photoSnippet && $0.photo.folder != nil}
 }
 
 var outerFoldered: [PhotoItem]
 {
  return allPhotos.filter{$0.photoSnippet !== photoSnippet && $0.photo.folder != nil}
 }
 
 var outerSnippets: [PhotoSnippet]
 {
  return allPhotoItems.filter{$0.photoSnippet !== photoSnippet}.map{$0.photoSnippet}
 }
 
 var localFolderedFolders: [PhotoFolderItem]
 {
  return Set(localFoldered.compactMap{$0.photo.folder}).compactMap{PhotoFolderItem(folder: $0)}
 }
 
 
 var outerFolderedFolders: [PhotoFolderItem]
 {
  return Set(outerFoldered.compactMap{$0.photo.folder}).compactMap{PhotoFolderItem(folder: $0)}
 }
 
 var removedLocalFolders: [PhotoFolderItem]
 {
  return localFolderedFolders.lazy.filter
  {folder in
   let items = folder.singlePhotoItems
   let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
   return items.count - drags == 0
   
  }
 }
 
 var singleLocalFolders: [PhotoFolderItem]
 {
  return localFolderedFolders.lazy.filter
   {folder in
    let items = folder.singlePhotoItems
    let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
    return items.count - drags == 1
    
  }
 }
 
 var updatedLocalFolders: [PhotoFolderItem]
 {
  return localFolderedFolders.lazy.filter
  {folder in
   let items = folder.singlePhotoItems
   let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
   return items.count - drags > 1
    
  }
 }

}


extension AppDelegate
{
 static let dragAnimStopDelay: Int = 2 // in seconds of DispatchTimeInterval underlying associted value
 static let dragUnselectDelay: Int = 5 // in seconds of DispatchTimeInterval underlying associted value
 static let dragAutoCnxxDelay: Int = 1 // in seconds of DispatchTimeInterval underlying associted value
 
 static var globalDragItems = [Draggable]()
 static var globalDropItems = [Draggable]()
 
 static var globalDragDropItems: [Draggable]
 {
  return globalDragItems + globalDropItems
 }
 
 static func clearAllDraggedItems()
 {
 
  print(#function)
 
  globalDragDropItems.forEach
  {dropped in
   dropped.clear(with: (forDragAnimating: dragAnimStopDelay,
                        forSelected:      dragUnselectDelay))
  }
 }
 
 static func printAllDraggedItems()
 {
  globalDragItems.forEach
  {
   print("DRAG ITEM ID: \($0.id) DRAG SESSION: \(String(describing: $0.dragSession)) SELECTED:\($0.isSelected) ")
  }
 }
 
 

 static func clearCancelledDraggedItems()
 {
  print (#function)
  globalDragItems.removeAll{$0.dragSession == nil}
 }
 
 
 static func clearAllDragAnimationCancelWorkItems ()
 {
  print (#function)
  AppDelegate.globalDragItems.forEach
  {
   $0.dragAnimationCancelWorkItem?.cancel()
   $0.dragAnimationCancelWorkItem = nil
  }
 }
 
 
 
 
 static func startCellDragAnimation (cell: UICollectionViewCell)
 {
  var slt = CATransform3DIdentity
  slt.m34 = -1.0/600
  cell.contentView.layer.superlayer!.sublayerTransform = slt
  
  let ag = CAAnimationGroup()
  
  let bc = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
  bc.fromValue = UIColor.brown.cgColor
  bc.toValue = UIColor.red.cgColor
  
  let bw = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
  bw.fromValue = 0.5
  bw.toValue = 1.25
  
  let kft = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
  kft.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
  kft.values =
   [
    CATransform3DMakeScale(0.98, 0.98, 1),
    CATransform3DMakeRotation( .pi/15, 1, 1, 0),  CATransform3DMakeRotation(-.pi/15, 1, 1, 0),
    CATransform3DMakeRotation( .pi/15, -1, 1, 0), CATransform3DMakeRotation(-.pi/15, -1, 1, 0),
    CATransform3DMakeRotation( .pi/90, 0, 0, 1),  CATransform3DMakeRotation(-.pi/90, 0, 0, 1),
    CATransform3DMakeScale(1.02, 1.02, 1)
  ]
  
  kft.calculationMode = kCAAnimationCubic
  kft.rotationMode = kCAAnimationRotateAuto
  
  ag.duration = 0.35
  ag.autoreverses = true
  ag.repeatCount = .infinity
  
  ag.animations = [bc, bw, kft]
  
  cell.contentView.layer.add(ag, forKey: "waggle")
  
 }
 
 
 static func stopCellDragAnimation (cell: UICollectionViewCell)
 {
  cell.contentView.layer.removeAnimation(forKey: "waggle")
 }
 
}
