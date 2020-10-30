//
//  Photo Snippet CV Pop-Up Menu.swift
//  Newsman
//
//  Created by Anton2016 on 16/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetCollectionView
{
 
 @objc func cellLongPress(_ gr: UILongPressGestureRecognizer)
 {
  guard !isPhotoEditing else {return}
  
  let touchPoint = gr.location(in: self)
  if let indexPath = indexPathForItem(at: touchPoint), gr.state == .ended
  {
   let ds = dataSource as! PhotoSnippetViewController
   let item = ds.photoItems2D[indexPath.section][indexPath.row]
   
   item.isDragAnimating = false
   item.isSelected = false
   
   let undoIndex = mainMenuItems.firstIndex{ $0.itemLayerName == "undoLayer" }
   mainMenuItems[undoIndex!].isEnabled = item.canUndo
   
   let redoIndex = mainMenuItems.firstIndex{ $0.itemLayerName == "redoLayer" }
   mainMenuItems[redoIndex!].isEnabled = item.canRedo
  
   let fillColor = #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1)
   drawCellMenu(menuColor: fillColor  , touchPoint: touchPoint, menuItems: mainMenuItems)
  }
  else
  {
   dismissCellMenu()
  }
  
 }//@objc func cellLongPress...
 
 
 @objc func tapCellMenuItem (gr: UITapGestureRecognizer)
 {
  let fillColor = #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1)
  let touchPoint = gr.location(in: self)
  guard let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer
   else { return }
  
  guard let buttonLayer = menuLayer.hitTest(touchPoint) else { return }
  
  let ds = dataSource as! PhotoSnippetViewController
  
  switch (buttonLayer.name)
  {
   case "flagSetLayer"?:
    menuLayer.removeFromSuperlayer()
    
    drawCellMenu(menuColor: fillColor, touchPoint: menuLayer.menuTouchPoint, menuItems: flagMenuItems)
   
   
   case "trashLayer"?:
    guard let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint) else { break }
    deletePhoto(at: indexPath)
    closeLayerAnimated(layer: menuLayer)
   
   case "flagLayer"?:
    guard let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint) else { break }
    let flagColor = (buttonLayer as! FlagItemLayer).flagColor
    ds.photoItems2D[indexPath.section][indexPath.row].priorityFlagColor = flagColor
    
    closeLayerAnimated(layer: menuLayer)
   
   case "unflagLayer"?:
    guard let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint) else { break }
    ds.photoItems2D[indexPath.section][indexPath.row].priorityFlagColor = nil
    closeLayerAnimated(layer: menuLayer)
   
   
   case "upLayer"?:
    menuLayer.removeFromSuperlayer()
    self.drawCellMenu(menuColor: fillColor, touchPoint: menuLayer.menuTouchPoint, menuItems: mainMenuItems)
   
   case "undoLayer"?:
    guard let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint) else { break }
    ds.photoItems2D[indexPath.section][indexPath.row].undo()
    closeLayerAnimated(layer: menuLayer)
   
   case "redoLayer"?:
    guard let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint) else { break }
    ds.photoItems2D[indexPath.section][indexPath.row].redo()
    closeLayerAnimated(layer: menuLayer)
   
   case "cnxLayer"?: closeLayerAnimated(layer: menuLayer)
   
   
   default: break
   
  }//switch
  
  self.menuIndexPath = nil
  self.menuShift = CGPoint.zero
  
  
  
 }//@objc func tapCellMenuItem..
 
 func locateCellMenu()
 {
  if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer
  {
   menuLayer.removeFromSuperlayer()
   
   if let path = indexPathForItem(at: menuLayer.menuTouchPoint), let cell = cellForItem(at: path)
   {
    let point = layer.convert(menuLayer.menuTouchPoint, to: cell.layer)
    if menuIndexPath == nil
    {
     menuIndexPath = path
     menuShift = CGPoint(x: point.x/cell.frame.width, y: point.y/cell.frame.height)
    }
   }
  }
 }
 
 func dismissCellMenu()
 {
  if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"})
  {
   menuLayer.removeFromSuperlayer()
  }
 }
 
 func closeLayerAnimated(layer: CALayer)
 {
  CATransaction.begin()
  CATransaction.setAnimationDuration(0.1)
  CATransaction.setCompletionBlock
   {
    CATransaction.setAnimationDuration(0.6)
    CATransaction.setCompletionBlock
    {
      layer.removeFromSuperlayer()
    }
    
    layer.position.y += self.frame.width
    layer.transform = CATransform3DMakeScale(0, 0, 1)
    layer.opacity = 0
    
  }
  
  var zeroLayer:(CALayer) -> Void  = {_ in}
  zeroLayer = {layer in
   layer.sublayers?.forEach
    {
     $0.transform = CATransform3DMakeScale(0, 0, 1)
     zeroLayer($0)
   }
  }
  
  if let subLayer = layer.sublayers?.first
  {
   zeroLayer(subLayer)
  }
  
  CATransaction.commit()
  
  
 }
 
 func isCellMenuVisible() -> Bool
 {
  return layer.sublayers?.first(where: {$0.name == "MenuLayer"}) != nil
 }//func isCellMenuVisible() -> Bool...
 
 func setItemsLayers(menuItems: [MenuItemProtocol]) -> [CALayer]
 {
  var layers: [CALayer] = []
  for i in 0..<menuItems.count
  {
   switch (menuItems[i])
   {
    case is CellMenuImageItem:
     let layer = CALayer()
     layer.contents = (menuItems[i] as! CellMenuImageItem).itemImage?.cgImage
     layer.name = menuItems[i].itemLayerName
     layer.frame = CGRect(x: menuItemSize.width * CGFloat(i % itemsInRow),
                          y: menuItemSize.height * CGFloat(i / itemsInRow),
                          width: menuItemSize.width,
                          height: menuItemSize.height)
     
     layer.contentsScale = UIScreen.main.scale
     layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
     layer.shadowOpacity = 0.5
     layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
     layer.opacity = menuItems[i].isEnabled ? 1.0 : 0.5
     layers.append(layer)
    
    case is CellMenuDrawItem:
     let layer = FlagItemLayer(flagColor: (menuItems[i] as! CellMenuDrawItem).fillColor)
     layer.setNeedsDisplay()
     layer.name = menuItems[i].itemLayerName
     layer.frame = CGRect(x: menuItemSize.width * CGFloat(i % itemsInRow),
                          y: menuItemSize.height * CGFloat(i / itemsInRow),
                          width: menuItemSize.width,
                          height: menuItemSize.height)
     
     layer.contentsScale = UIScreen.main.scale
     layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
     layer.shadowOpacity = 1.0
     layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
     layer.opacity = menuItems[i].isEnabled ? 1.0 : 0.5
     layers.append(layer)
    
    default: break
   }
  }
  
  return layers
 }//func setItemsLayers(menuItems: [MenuItemProtocol])...
 
 enum CellMenuType: Int
 {
  case normal = 0
  case right =  1
  case bottom = 2
  case corner = 3
 }
 

 func drawCellMenu (menuColor: UIColor, touchPoint: CGPoint, menuItems: [MenuItemProtocol])
 {
  if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"})
  {
   menuLayer.removeFromSuperlayer()
   menuIndexPath = nil
   menuShift = CGPoint.zero
   return
  }
  
  cellMenuType = .normal
  
  let menuLayer = PhotoMenuLayer()
  let barLayer = CALayer()
  
  menuLayer.arrowSize = menuArrowSize
  menuLayer.fillColor = menuColor
  menuLayer.name = "MenuLayer"
  menuLayer.menuTouchPoint = touchPoint
  
  
  let barFrame =
   CGRect(x: 0, y: menuArrowSize.height,
          width: menuItemSize.width * CGFloat(itemsInRow),
          height: menuItemSize.height * CGFloat(menuItems.count/itemsInRow +
                  (menuItems.count % itemsInRow == 0 ? 0 : 1)))
  
  let menuFrame =
   CGRect(x: touchPoint.x, y: touchPoint.y,
          width: barFrame.width,
          height: barFrame.height + menuArrowSize.height)
  
  
  barLayer.frame = barFrame
  barLayer.contentsScale = UIScreen.main.scale
  barLayer.zPosition = menuLayer.zPosition + 1
  
  if ( touchPoint.x + menuFrame.width  >= layer.bounds.width &&
       touchPoint.y + menuFrame.height <= layer.bounds.height )
  {
   menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
   menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
   barLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
   cellMenuType = .right
  }
  
  
  if ( touchPoint.y + menuFrame.height >= layer.bounds.height &&
       touchPoint.x + menuFrame.width  <= layer.bounds.width )
  {
   menuLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
   menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
   barLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
   cellMenuType = .bottom
  }
  
  if ( touchPoint.y + menuFrame.height >= layer.bounds.height &&
       touchPoint.x + menuFrame.width  >= layer.bounds.width )
  {
   menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
   var transform = CATransform3DIdentity
   transform = CATransform3DRotate(transform, CGFloat.pi, 0, 1, 0)
   transform = CATransform3DRotate(transform, CGFloat.pi, 1, 0, 0)
   menuLayer.transform = transform
   barLayer.transform = transform
   cellMenuType = .corner
  }
  
  menuLayer.frame = menuFrame
  menuLayer.contentsScale = UIScreen.main.scale
  
  barLayer.sublayers = setItemsLayers(menuItems: menuItems)
  
  menuLayer.addSublayer(barLayer)
  
  menuLayer.zPosition = layer.zPosition + 1
  menuLayer.shadowOpacity = 1.0
  menuLayer.shadowRadius = 10.0
  menuLayer.shadowOffset = CGSize(width: -5.0, height: -5.0)
  
  layer.addSublayer(menuLayer)
  
  menuLayer.setNeedsDisplay()
  
  
 }//func drawCellMenu (menuColor: UIColor, touchPoint:...
 
}//extension...
