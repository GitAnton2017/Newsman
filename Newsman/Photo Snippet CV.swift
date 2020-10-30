
import Foundation
import UIKit
import RxCocoa

class PhotoSnippetCollectionViewFlowLayout: UICollectionViewFlowLayout
{
 override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
  true
 }
}

class PhotoSnippetCollectionView: UICollectionView
{
 deinit { print ("******** DESTROYED <<<< Photo Snippet Collection View >>>> *******") }
 
 var photoSnippet: PhotoSnippet { (dataSource as! PhotoSnippetViewController).photoSnippet }

 var photoGroupType: GroupPhotos?
 {
  get { photoSnippet.photoGroupType }
  
  set
  {
   
   guard newValue != nil else { return }
   let ds = dataSource as! PhotoSnippetViewController
   
   ds.moc.perform
   {
    switch (newValue == self.photoGroupType, self.photoGroupType?.isSectioned)
    {
     case (true, true):  self.photoSnippet.ascending.toggle()
     case (true, false): self.photoSnippet.ascendingPlain.toggle()
     default: self.photoSnippet.photoGroupType = newValue
    }
    
   }
   
  }
 }
 
 var menuTapGR: UITapGestureRecognizer!
 var cellLongPressGR : UILongPressGestureRecognizer!
 var cellPanGR: UIPanGestureRecognizer!
 var cellDoubleTapGR: UITapGestureRecognizer!
 
 let itemsInRow: Int = 3
 
 var menuArrowSize = CGSize(width: 20.0, height: 50.0)
 var menuItemSize =  CGSize(width: 50.0, height: 50.0)
 
 var isPhotoEditing = false
 
 var menuIndexPath: IndexPath? = nil
 var menuShift = CGPoint.zero

 var cellMenuType: CellMenuType!

 weak var zoomView: ZoomView?

 override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
 {
  super.init(frame: frame, collectionViewLayout: layout)
 }

 

 
 required init?(coder aDecoder: NSCoder)
 {
     super.init(coder: aDecoder)
     
     cellDoubleTapGR = UITapGestureRecognizer(target: self, action: #selector(cellDoubleTap))
     cellDoubleTapGR.numberOfTapsRequired = 2
     addGestureRecognizer(cellDoubleTapGR)
     
     menuTapGR = UITapGestureRecognizer(target: self, action: #selector(tapCellMenuItem))
     menuTapGR.require(toFail: cellDoubleTapGR)
     addGestureRecognizer(menuTapGR)
  

     
     
 }
 
 var photoItems2D: [[PhotoItemProtocol]]
 {
  (dataSource as! PhotoSnippetViewController).photoItems2D
 }
 
 var mainView: UIView { (dataSource as! PhotoSnippetViewController).view }
 
 var mainViewCenter: CGPoint
 {
   return CGPoint(x: mainView.center.x, y: mainView.center.y - mainView.frame.origin.y)
 }
 
 var zoomSize: CGFloat { 0.9 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) }
 
 var zoomFrame: CGRect
 {
   return CGRect(origin: CGPoint.zero, size: CGSize(width: zoomSize, height: zoomSize))
 }
 
 func snippetCellZoom(at touchPoint: CGPoint, with centerAt: CGPoint) -> ZoomView?
 {
  for view in mainView.subviews
  {
   if let zoomView = view as? ZoomView {return zoomView}
  }
  
  if let indexPath = indexPathForItem(at: touchPoint)
  {
    let zoomView = ZoomView()
    zoomView.center = centerAt
    zoomView.zoomedCellIndexPath = indexPath
    zoomView.photoSnippetVC = dataSource as? PhotoSnippetViewController
   
    let tappedItem = photoItems2D[indexPath.section][indexPath.row]
    zoomView.zoomedPhotoItem = tappedItem
 
    switch cellForItem(at: indexPath)
    {
     case is PhotoSnippetCell:
      
      let photoItem = tappedItem as! PhotoItem
        switch (photoItem.type)
        {
         case .photo:
          let imageView = zoomView.openWithIV(in: mainView)
          photoItem.getImage(requiredImageWidth: zoomSize)
          {image in
           zoomView.stopSpinner()
           imageView.image = image
           image?.setSquared(in: imageView)
          }
         
         case .video:
          guard let videoURL = photoItem.url else { break }
          zoomView.openWithVideoPlayer(in: mainView, for:  videoURL)
         
         default: break
        }
     
     
     case let cell as PhotoFolderCell:
       let cv  = zoomView.openWithCV(in: mainView)
       zoomView.photoItems = cell.photoItems
       cv.reloadData()
     
     default: break
     
    }
   
    return zoomView
     
  }
     
  return nil
 }

 func cellSpringInt (_ springContext: UISpringLoadedInteractionContext) -> ZoomView?
 {
  let tpMV = springContext.location(in: mainView)
  return snippetCellZoom(at: springContext.location(in: self),
                         with: CGPoint (x: tpMV.x, y: tpMV.y + mainView.frame.origin.y))
 }
 
 
 @objc func cellDoubleTap(_ gr: UITapGestureRecognizer)
 {
  let tpMV = gr.location(in: mainView)
  zoomView = snippetCellZoom(at: gr.location(in: self),
                             with: CGPoint (x: tpMV.x, y: tpMV.y + mainView.frame.origin.y))
 }
 
 var hasUnfinishedMove = false
 //var unfinishedMoveCell: PhotoSnippetCell? = nil

 //var movedCell: UICollectionViewCell? = nil
 var correctionY: CGFloat? = nil
 var movedCellBeginPosition = CGPoint.zero
 

 func moveSelectedPhotos (to destinationIndexPath: IndexPath)
 {
     
 }
 
//    func cancellUnfinishedMove()
//    {
//        if hasUnfinishedMove
//        {
//            cancelInteractiveMovement()
//            unfinishedMoveCell?.photoIconView.alpha = 1
//            unfinishedMoveCell?.photoIconView.layer.borderWidth = 1
//            unfinishedMoveCell = nil
//            hasUnfinishedMove = false
//        }
//    }

//    func reorderPhoto (tappedCell cell: PhotoSnippetCell, tappedIndexPath indexPath: IndexPath, with gr: UILongPressGestureRecognizer)
//    {
//        let tp = gr.location(in: self)
//        switch (gr.state)
//        {
//         case .began:
//          cancellUnfinishedMove()
//          beginInteractiveMovementForItem(at: indexPath)
//          hasUnfinishedMove = true
//          unfinishedMoveCell = cell
//          cell.photoIconView.alpha = 0.75
//          cell.photoIconView.layer.borderWidth = 5.0
//          UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut,.`repeat`,.autoreverse],
//                         animations: {cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)},
//                         completion: nil)
//
//
//         case .changed: updateInteractiveMovementTargetPosition(tp)
//         case .ended:
//
//          endInteractiveMovement()
//          hasUnfinishedMove = false
//          unfinishedMoveCell = nil
//          cell.photoIconView.layer.borderWidth = 1.0
//          cell.photoIconView.alpha = 1
//
//         default: cancellUnfinishedMove()
//        }
//
//    }

 
 
 func movePhoto (at indexPath: IndexPath, with flagStr: String?)
 {
  let ds = dataSource as! PhotoSnippetViewController
  if let section = ds.photoItems2D.enumerated().first(where: {$0.element.first?.priorityFlag == flagStr})
  {
   moveBetweenExistingSections(at: indexPath, to: section, with: flagStr)
  }
  else
  {
   let pred = {(item: (offset : Int, element: [PhotoItemProtocol])) -> Bool in
    let firstItem = item.element.first?.priorityFlag ?? ""
    let currRate = (firstItem.isEmpty ? -1 : PhotoPriorityFlags(rawValue: firstItem)!.rateIndex)
    let rate =     (flagStr ==  nil ? -1 : PhotoPriorityFlags(rawValue:    flagStr!)!.rateIndex)
    return  rate < currRate
   }
             
   if let next = ds.photoItems2D.enumerated().first(where: pred)
   {
     moveToNewInsertedSection(at: indexPath, to: next, with: flagStr)
   }
   else
   {
     moveToNewAppendedSection(at: indexPath, with: flagStr)
   }
  }
 }




 func updateSection (sectionIndex: Int)   //update section without reloading all the section's CV cells
 {
  guard let ds = dataSource as? PhotoSnippetViewController else {return}
  guard sectionIndex < photoItems2D.count else {return}
  
  let itemsCount = ds.photoItems2D[sectionIndex].count
  
  if itemsCount == 0
  {
   ds.photoItems2D.remove(at: sectionIndex)
   ds.photoCollectionView.deleteSections([sectionIndex])
   ds.sectionTitles?.remove(at: sectionIndex)
   return
  }
  
  let kind = UICollectionView.elementKindSectionFooter
  let indexPath = IndexPath(row: 0, section: sectionIndex)
  //CV supplementary view IndexPath is IndexPath with row = 0, section = section index!
  
  if let footer = supplementaryView(forElementKind: kind, at: indexPath) as? PhotoSectionFooter
  {
   footer.footerLabel.text = NSLocalizedString("Total photos in group", comment: "Total photos in group") + ": \(itemsCount)"
  }
  
 }




 func refreshSections (sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
 {
  let ds = dataSource as! PhotoSnippetViewController
     
  reloadSections([destinationIndexPath.section])
  if ds.photoItems2D[sourceIndexPath.section].count != 0
  {
     reloadSections([sourceIndexPath.section])
  }
  else
  {
     ds.photoItems2D.remove(at: sourceIndexPath.section)
     ds.sectionTitles?.remove(at: sourceIndexPath.section)
     deleteSections([sourceIndexPath.section])
  }
 }
 
 func moveToNewAppendedSection(at indexPath: IndexPath, with flagStr: String?)
 {
  let ds = dataSource as! PhotoSnippetViewController
  ds.photoItems2D.append([])
  ds.sectionTitles?.append(flagStr ?? "")
  insertSections([ds.photoItems2D.count - 1])
  let moved = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
  moved.priorityFlag = flagStr
  ds.photoItems2D[ds.photoItems2D.count - 1].append(moved)
  let destIndexPath = IndexPath(row: 0, section: ds.photoItems2D.count - 1)
  moveItem(at: indexPath, to: destIndexPath)
  refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
 }
 
 func moveToNewInsertedSection(at indexPath: IndexPath, to section: (offset : Int, element: [PhotoItemProtocol]), with flagStr: String?)
 {
  let ds = dataSource as! PhotoSnippetViewController
  ds.photoItems2D.insert([], at: section.offset)
  ds.sectionTitles?.insert(flagStr ?? "", at: section.offset)
  insertSections([section.offset])
  if section.offset > indexPath.section
  {
  let moved = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
   moved.priorityFlag = flagStr
   ds.photoItems2D[section.offset].append(moved)
   let destIndexPath = IndexPath(row: 0, section: section.offset)
   moveItem(at: indexPath, to: destIndexPath)
   refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
  }
  else
  {
  let moved = ds.photoItems2D[indexPath.section + 1].remove(at: indexPath.row)
   moved.priorityFlag = flagStr
   ds.photoItems2D[section.offset].append(moved)
   let destIndexPath = IndexPath(row: 0, section: section.offset)
   let sourIndexPath = IndexPath(row: indexPath.row, section: indexPath.section + 1)
   moveItem(at: sourIndexPath, to: destIndexPath)
   refreshSections(sourceIndexPath: sourIndexPath, destinationIndexPath: destIndexPath)
  }
 }
 
 func moveBetweenExistingSections(at indexPath: IndexPath, to section: (offset : Int, element: [PhotoItemProtocol]), with flagStr: String?)
 {
   guard (section.offset != indexPath.section) else
   {
    return
   }
 
   let ds = dataSource as! PhotoSnippetViewController
   let moved = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
   moved.priorityFlag = flagStr
   ds.photoItems2D[section.offset].append(moved)
   let destIndexPath = IndexPath(row: section.element.count, section: section.offset)
   moveItem(at: indexPath, to: destIndexPath)
   refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
 }
 
}//class PhotoSnippetCollectionView: UICollectionView...
