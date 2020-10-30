//
//  Photo Item Pop-Up Menu.swift
//  Newsman
//
//  Created by Anton2016 on 14/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import UIKit

protocol MenuItemProtocol
{
 var itemLayerName: String { get set }
 var isEnabled: Bool       { get set }
}

protocol MenuItemImageProtocol: MenuItemProtocol
{
 var itemImage: UIImage? {get set}
}

protocol MenuItemDrawProtocol: MenuItemProtocol
{
 var fillColor: UIColor {get set}
}


struct CellMenuImageItem: MenuItemImageProtocol
{
 var isEnabled: Bool = true
 var itemLayerName: String
 var itemImage: UIImage?
 
 init (itemLayerName: String, itemImage: UIImage?)
 {
  self.itemLayerName = itemLayerName
  self.itemImage = itemImage
 }
}

struct CellMenuDrawItem: MenuItemDrawProtocol
{
 var isEnabled: Bool = true
 var itemLayerName: String
 var fillColor: UIColor
 
 init (itemLayerName: String, fillColor: UIColor)
 {
  self.itemLayerName = itemLayerName
  self.fillColor = fillColor
 }
 
}

var mainMenuItems : [MenuItemProtocol] =
[
  CellMenuImageItem(itemLayerName: "flagSetLayer", itemImage: UIImage(named: "flag.menu.icon" )),
  CellMenuImageItem(itemLayerName: "trashLayer",   itemImage: UIImage(named: "trash.menu.icon")),
  CellMenuImageItem(itemLayerName: "cnxLayer",     itemImage: UIImage(named: "cnx.menu.icon"  )),
  CellMenuImageItem(itemLayerName: "undoLayer",    itemImage: UIImage(named: "undo.menu.icon" )),
  CellMenuImageItem(itemLayerName: "redoLayer",    itemImage: UIImage(named: "redo.menu.icon" ))
]

let flagMenuItems : [MenuItemProtocol] =
 [
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.red),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.orange),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.yellow),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.brown),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.blue),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.green),
  CellMenuImageItem(itemLayerName: "upLayer", itemImage: UIImage(named: "up.menu.icon"      )),
  CellMenuImageItem(itemLayerName: "unflagLayer", itemImage: UIImage(named: "unflag.menu.icon"  )),
  CellMenuImageItem(itemLayerName: "cnxLayer", itemImage: UIImage(named: "cnx.menu.icon"     ))
]

let editMenuItems : [MenuItemProtocol] =
 [
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.red),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.orange),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.yellow),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.brown),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.blue),
  CellMenuDrawItem(itemLayerName: "flagLayer", fillColor: UIColor.green),
  CellMenuImageItem(itemLayerName: "unflagLayer", itemImage: UIImage(named: "unflag.menu.icon"  )),
  CellMenuImageItem(itemLayerName: "cnxLayer", itemImage: UIImage(named: "cnx.menu.icon"     ))
]

class PhotoMenuLayer: CALayer
{
 var fillColor: UIColor!
 var arrowSize: CGSize!
 var menuTouchPoint:  CGPoint!
 
 override func draw(in ctx: CGContext)
 {
  ctx.beginPath()
  let p1 = CGPoint(x: 0, y: 0)
  let p2 = CGPoint(x: 10, y: arrowSize.height)
  let p3 = CGPoint(x: arrowSize.width, y: arrowSize.height)
  
  ctx.addLines(between: [p1,p2,p3])
  ctx.closePath()
  ctx.setFillColor(fillColor.cgColor)
  ctx.fillPath()
  
  let rect = CGRect(x: 0, y: arrowSize.height, width: bounds.width, height: bounds.height - arrowSize.height)
  let roundRectPath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
  ctx.addPath(roundRectPath.cgPath)
  ctx.setFillColor(fillColor.cgColor)
  ctx.fillPath()
  
 }
}

class FlagItemLayer: CALayer
{
 var flagColor: UIColor!
 
 override init()
 {
  super.init()
 }
 
 override init(layer: Any)
 {
  super.init(layer: layer)
 }
 convenience init(flagColor: UIColor)
 {
  self.init()
  self.flagColor = flagColor
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 override func draw(in ctx: CGContext)
 {
  let p1 = CGPoint(x: 0, y: 0)
  let p2 = CGPoint(x: 0, y: bounds.height)
  let p3 = CGPoint(x: bounds.width/2, y: bounds.height * 0.6)
  let p4 = CGPoint(x: bounds.width, y: bounds.height)
  let p5 = CGPoint(x: bounds.width, y: 0)
  
  ctx.beginPath()
  ctx.addLines(between: [p1,p2,p3,p4,p5])
  ctx.closePath()
  ctx.setFillColor(flagColor.cgColor)
  ctx.drawPath(using: .fill)
 }
}
