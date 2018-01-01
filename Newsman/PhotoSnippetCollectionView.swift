
import Foundation
import UIKit


protocol MenuItemProtocol
{
   var itemLayerName: String {get set}
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
    var itemLayerName: String
    var itemImage: UIImage?
}

struct CellMenuDrawItem: MenuItemDrawProtocol
{
    var itemLayerName: String
    var fillColor: UIColor
}

let mainMenuItems : [MenuItemProtocol] =
[
  CellMenuImageItem(itemLayerName: "flagSetLayer", itemImage: UIImage(named: "flag.menu.icon" )),
  CellMenuImageItem(itemLayerName: "trashLayer",   itemImage: UIImage(named: "trash.menu.icon")),
  CellMenuImageItem(itemLayerName: "cnxLayer",     itemImage: UIImage(named: "cnx.menu.icon"  ))
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

class PhotoSnippetCollectionView: UICollectionView
{
    var menuTapGR: UITapGestureRecognizer!
    var cellLongPressGR : UILongPressGestureRecognizer!
    
    let itemsInRow: Int = 3
    
    var menuArrowSize = CGSize(width: 20.0, height: 50.0)
    var menuItemSize =  CGSize(width: 50.0, height: 50.0)
    
    var isPhotoEditing = false
    
    var menuIndexPath: IndexPath? = nil
    var menuShift = CGPoint.zero
  
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        cellLongPressGR = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPress))
        cellLongPressGR.minimumPressDuration = 0.25
        addGestureRecognizer(cellLongPressGR)
        
        menuTapGR = UITapGestureRecognizer(target: self, action: #selector(tapCellMenuItem))
        addGestureRecognizer(menuTapGR)
    }
    
    @objc func cellLongPress(_ gr: UIGestureRecognizer)
    {
        if isPhotoEditing
        {
          return
        }
        
        let touchPoint = gr.location(in: self)
        
        if let _ = indexPathForItem(at: touchPoint)
        {
         if gr.state == .ended
         {
          drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: touchPoint, menuItems: mainMenuItems)
         }
        }
        else
        {
          dismissCellMenu()
        }
        
    }
    

    
    @objc func tapCellMenuItem (gr: UITapGestureRecognizer)
    {
        let touchPoint = gr.location(in: self)
        if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer,
           let buttonLayer = menuLayer.hitTest(touchPoint)
        {
           let ds = self.dataSource as! PhotoSnippetViewController
           switch (buttonLayer.name)
           {
            case "flagSetLayer"? :
             if let _ = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              menuLayer.removeFromSuperlayer()
              self.drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuLayer.menuTouchPoint, menuItems: flagMenuItems)
             }
                
            case "trashLayer"?   :
             if let indexPath = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              let deleted = ds.photoItems.remove(at: indexPath.row)
              deleted.deleteImage()
              self.deleteItems(at: [indexPath])
             }
            
            case "flagLayer"?:
             let flagColor = (buttonLayer as! FlagItemLayer).flagColor
             let flagStr = PhotoPriorityFlags.priorityColorMap.first(where: {$0.value == flagColor})?.key.rawValue
             if isPhotoEditing
             {
              ds.photoItems.enumerated().filter({$0.element.photo.isSelected}).forEach
              {
                $0.element.photo.priorityFlag = flagStr
                if let cell = cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
                {
                 cell.drawFlag(flagColor: flagColor!)
                }
              }
              ds.togglePhotoEditingMode()
             }
             else if let indexPath = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              ds.photoItems[indexPath.row].photo.priorityFlag = flagStr
              let cell = self.cellForItem(at: indexPath) as! PhotoSnippetCell
              cell.drawFlag(flagColor: flagColor!)
             }
            
            case "unflagLayer"?:
             if isPhotoEditing
             {
               ds.photoItems.enumerated().filter({$0.element.photo.isSelected}).forEach
               {
                $0.element.photo.priorityFlag = nil
                if let cell = cellForItem(at: IndexPath(row: $0.offset, section: 0)) as? PhotoSnippetCell
                {
                 cell.clearFlag()
                }
               }
                
               ds.togglePhotoEditingMode()
             }
             else if let indexPath = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              ds.photoItems[indexPath.row].photo.priorityFlag = nil
              let cell = self.cellForItem(at: indexPath) as! PhotoSnippetCell
              cell.clearFlag()
             }
            
            case "upLayer"?:
             if let _ = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
               menuLayer.removeFromSuperlayer()
               self.drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuLayer.menuTouchPoint, menuItems: mainMenuItems)
             }
            
            case "cnxLayer"? :
             if isPhotoEditing
             {
              menuTapGR.isEnabled = false
             }
            
            default: break
            
           }//switch
          
          self.menuIndexPath = nil
          self.menuShift = CGPoint.zero
          menuLayer.removeFromSuperlayer()
        
        }
    }
    
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
    
    func isCellMenuVisible()->Bool
    {
      return layer.sublayers?.first(where: {$0.name == "MenuLayer"}) != nil
    }
    
    func setItemsLayers(menuItems: [MenuItemProtocol])->[CALayer]
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
        layers.append(layer)
        
       default: break
      }
     }
     return layers
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
        
        let menuLayer = PhotoMenuLayer()
        let barLayer = CALayer()
        
        menuLayer.arrowSize = menuArrowSize
        menuLayer.fillColor = menuColor
        menuLayer.name = "MenuLayer"
        menuLayer.menuTouchPoint = touchPoint
    
        
        let barFrame =
            CGRect(x: 0, y: menuArrowSize.height,
                   width: menuItemSize.width * CGFloat(itemsInRow),
                   height: menuItemSize.height * CGFloat(menuItems.count/itemsInRow + (menuItems.count % itemsInRow == 0 ? 0 : 1)))
        
        let menuFrame =
            CGRect(x: touchPoint.x, y: touchPoint.y,
                   width: barFrame.width,
                   height: barFrame.height + menuArrowSize.height)
        
        
        barLayer.frame = barFrame
        barLayer.contentsScale = UIScreen.main.scale
        barLayer.zPosition = menuLayer.zPosition + 1
    
        
        if touchPoint.x + menuFrame.width  >= layer.bounds.width &&
           touchPoint.y + menuFrame.height <= layer.bounds.height
        {
            menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
            barLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
        }
        
        if touchPoint.y + menuFrame.height >= layer.bounds.height &&
           touchPoint.x + menuFrame.width  <= layer.bounds.width
        {
            menuLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
            barLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        }
        
        if touchPoint.y + menuFrame.height >= layer.bounds.height &&
           touchPoint.x + menuFrame.width  >= layer.bounds.width
        {
            menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, CGFloat.pi, 0, 1, 0)
            transform = CATransform3DRotate(transform, CGFloat.pi, 1, 0, 0)
            menuLayer.transform = transform
            barLayer.transform = transform
        }
        
        menuLayer.frame = menuFrame
        menuLayer.contentsScale = UIScreen.main.scale
        
        barLayer.sublayers = setItemsLayers(menuItems: menuItems)
    
        menuLayer.addSublayer(barLayer)
        
        menuLayer.shadowOpacity = 1.0
        menuLayer.shadowRadius = 10.0
        menuLayer.shadowOffset = CGSize(width: -5.0, height: -5.0)
        
        layer.addSublayer(menuLayer)
        
        menuLayer.display()
        
    }

}
