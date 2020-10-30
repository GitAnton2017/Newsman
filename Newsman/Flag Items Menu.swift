
import Foundation
import UIKit

extension PhotoSnippetViewController
{
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
       menuView = UIView(frame: menuLayer.frame)
       menuView!.center = self.view.center
       //menuView!.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
       let flagMenuGR = UITapGestureRecognizer(target: self, action: #selector(tapPhotoEditMenu))
       let panMenuGR =  UIPanGestureRecognizer(target: self, action: #selector(panPhotoEditMenu))
       menuView!.addGestureRecognizer(flagMenuGR)
       menuView!.addGestureRecognizer(panMenuGR)
       view.addSubview(menuView!)
       menuView!.translatesAutoresizingMaskIntoConstraints = false
    
       NSLayoutConstraint.activate(
        [
         menuView!.widthAnchor.constraint   (equalToConstant: menuLayer.frame.width),
         menuView!.centerXAnchor.constraint (equalTo: self.view.centerXAnchor),
         menuView!.centerYAnchor.constraint (equalTo: self.view.centerYAnchor),
         menuView!.widthAnchor.constraint   (equalTo: menuView!.heightAnchor)
        ]
       )
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
  menuView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
  menuView?.alpha = 0
  UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                 animations:
                 {[weak self] in
                  self?.menuView?.transform = CGAffineTransform.identity
                  self?.menuView?.alpha = 1
                 },completion: nil)
    
 }
 
 func closeMenuAni()
 {
  UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                 animations:
                 {[weak self] in
                  self?.menuView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                  self?.menuView?.alpha = 0
                 }, completion:
                 {[weak self] _ in
                  self?.menuView?.removeFromSuperview()
                  self?.menuView = nil
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
     photoSnippet.flagSelectedObjects(with: flagColor)
//     let flagStr = PhotoPriorityFlags.priorityColorMap.first(where: {$0.value == flagColor})?.key.rawValue
//     if (photoCollectionView.photoGroupType != .makeGroups)
//     {
//      PhotoItem.MOC.persistAndWait
//      {
//       self.photoItems2D[0].enumerated().filter({$0.element.isSelected}).forEach
//       {item in
//        item.element.priorityFlag = flagStr //Photo MO change operation to be persisted here!!
//        let indexPath = IndexPath(row: item.offset, section: 0)
//        if let cell = self.photoCollectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol
//        {
//         cell.drawFlagMarker(flagColor: flagColor!)
//        }
//       }
//      }
//     }
//     else
//     {
//       flagGroupedSelectedPhotos(with: flagStr)
//     }
//
     togglePhotoEditingMode()
     closeMenuAni()
    
    
    case "unflagLayer"?:
     photoSnippet.flagSelectedObjects(with: nil)
     
//     if (photoCollectionView.photoGroupType != .makeGroups)
//     {
//      PhotoItem.MOC.persistAndWait
//      {
//       self.photoItems2D[0].enumerated().filter({$0.element.isSelected}).forEach
//       {item in
//        item.element.priorityFlag = nil //Photo MO change operation to be persisted here!!
//        let indexPath = IndexPath(row: item.offset, section: 0)
//        if let cell = self.photoCollectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol
//        {
//          cell.unsetFlagMarker()
//        }
//       }
//      }
//     }
//     else
//     {
//       flagGroupedSelectedPhotos(with: nil)
//     }
     
     togglePhotoEditingMode()
     closeMenuAni()
    
    
    case "cnxLayer"?: closeMenuAni()
    
    default: break
    
   }
  }
 }
}



