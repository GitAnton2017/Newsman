
import Foundation
import UIKit

extension PhotoSnippetViewController
{
 var menuViewOrigin: CGPoint
 {
  let x = (menuFrameSize.width - CGFloat(photoCollectionView.itemsInRow) * photoCollectionView.menuItemSize.width)/2
  let y = (menuFrameSize.height - ceil(CGFloat(editMenuItems.count) / CGFloat(photoCollectionView.itemsInRow)) * photoCollectionView.menuItemSize.height) / 2
  return CGPoint(x: x, y: y)
 }
 
 func showFlagPhotoMenu()
 {
   if menuView != nil
   {
     closeMenuAni()
     return
   }
  
   photoCollectionView.dismissCellMenu()
   photoCollectionView.drawCellMenu(menuColor: #colorLiteral(red: 0.8855290292, green: 0.8220692608, blue: 0.755911735, alpha: 1), touchPoint: CGPoint.zero, menuItems: editMenuItems)
  
   if let menuLayer = photoCollectionView.layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer
   {
       let menuFrame = CGRect(origin: menuViewOrigin, size: menuLayer.frame.size)
       menuView = UIView(frame: menuFrame)
       let flagMenuGR = UITapGestureRecognizer(target: self, action: #selector(tapPhotoEditMenu))
       let panMenuGR =  UIPanGestureRecognizer(target: self, action: #selector(panPhotoEditMenu))
       menuView!.addGestureRecognizer(flagMenuGR)
       menuView!.addGestureRecognizer(panMenuGR)
       view.addSubview(menuView!)
       menuView!.layer.addSublayer(menuLayer)
       openMenuAni()
   }
 }
 
 
 @objc func panPhotoEditMenu (gr: UIPanGestureRecognizer)
 {
     guard let menu = menuView else {return}
    
     switch (gr.state)
     {
     case .began: menuTouchPoint = gr.location(in: menu)
     
     UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {menu.alpha = 0.85}, completion: nil)
     UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn, .`repeat`, .autoreverse],
                    animations:
         {
             menu.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
     },
                    completion: nil)
     case .changed:
         let touchPoint = gr.location(in: menu)
         let translation = gr.translation(in: menu)
         if (touchPoint.x > menuTouchPoint.x - 30  && touchPoint.y > menuTouchPoint.y - 30  &&
             touchPoint.x < menuTouchPoint.x + 30  && touchPoint.y < menuTouchPoint.y + 30)
         {
             menu.center.x += translation.x
             menu.center.y += translation.y
         }
         
         gr.setTranslation(CGPoint.zero, in: menu)
        
     default:
         UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut],
                        animations:
             {
                 menu.transform = CGAffineTransform.identity
                 menu.alpha = 1.0
         },
                        completion: nil)
     }
    
 }
 
 func openMenuAni()
 {
     menuView!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
     menuView!.alpha = 0
     UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                    animations:
         {
             self.menuView!.transform = CGAffineTransform.identity
             self.menuView!.alpha = 1
     },
                    completion: nil)
    
 }
 
 func closeMenuAni()
 {
     UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                    animations:
         {
             self.menuView!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
             self.menuView!.alpha = 0
     },
                    completion:
         {_ in
             self.menuView!.removeFromSuperview()
             self.menuView = nil
     })
    
 }
 
 
 @objc func tapPhotoEditMenu (gr: UITapGestureRecognizer)
 {
     let touchPoint = gr.location(in: menuView)
     if let menuLayer = menuView!.layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer,
         let buttonLayer = menuLayer.hitTest(touchPoint)
     {
         switch (buttonLayer.name)
         {
         case "flagLayer"?:
             let flagColor = (buttonLayer as! FlagItemLayer).flagColor
             let flagStr = PhotoPriorityFlags.priorityColorMap.first(where: {$0.value == flagColor})?.key.rawValue
             if photoCollectionView.photoGroupType != .makeGroups
             {
                 photoItems2D[0].enumerated().filter({$0.element.isSelected}).forEach
                     {
                         var item = $0.element
                         item.priorityFlag = flagStr
                         if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
                         {
                             cell.drawFlag(flagColor: flagColor!)
                         }
                 }
             }
             else
             {
                 flagGroupedSelectedPhotos(with: flagStr)
             }
             
             togglePhotoEditingMode()
             closeMenuAni()
            
            
         case "unflagLayer"?:
             if photoCollectionView.photoGroupType != .makeGroups
             {
                 photoItems2D[0].enumerated().filter({$0.element.isSelected}).forEach
                     {
                         var item = $0.element
                         item.priorityFlag = nil
                         if let cell = photoCollectionView.cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
                         {
                             cell.clearFlag()
                         }
                 }
             }
             else
             {
                 flagGroupedSelectedPhotos(with: nil)
             }
             
             togglePhotoEditingMode()
             closeMenuAni()
            
            
         case "cnxLayer"?: closeMenuAni()
            
         default: break
            
         }
     }
 }
}



