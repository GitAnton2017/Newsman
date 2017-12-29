
import Foundation
import UIKit

struct CellMenuItem
{
  let itemLayerName: String
  let buttonImage: UIImage?
}

let mainMenuItems =
[
 CellMenuItem(itemLayerName: "flagSetLayer", buttonImage: UIImage(named: "flag.menu.icon" )),
 CellMenuItem(itemLayerName: "trashLayer",   buttonImage: UIImage(named: "trash.menu.icon")),
 CellMenuItem(itemLayerName: "cnxLayer",     buttonImage: UIImage(named: "cnx.menu.icon"  )),
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
        let p2 = CGPoint(x: 10, y: bounds.height)
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

class FlagPhotoLayer: CALayer
{
    override func draw(in ctx: CGContext)
    {
        
    }
}

class PhotoSnippetCollectionView: UICollectionView
{
    var menuTapGR: UITapGestureRecognizer!
    var cellLongPressGR : UILongPressGestureRecognizer!
    
    let menuArrowSize = CGSize(width: 20.0, height: 50.0)
    let menuBarSize =   CGSize(width: 150.0, height: 50.0)
    
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
        
        if (gr.state == .ended)
        {
         drawCellMenu(menuColor: UIColor.red, touchPoint: touchPoint)
        }
        
    }
    
    @objc func tapCellMenuItem (gr: UITapGestureRecognizer)
    {
        let touchPoint = gr.location(in: self)
        if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer
        {
          switch (menuLayer.hitTest(touchPoint)?.name)
          {
            case "flagSetLayer"? :
                if let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint)
                {
                    print (indexPath)
                }
                
            case "trashLayer"?   :
                if let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint)
                {
                 (dataSource as! PhotoSnippetViewController).photoItems.remove(at: indexPath.row)
                 deleteItems(at: [indexPath])
                }
                
            case "cnxLayer"? : break
            default: break
          }
          
          menuIndexPath = nil
          menuShift = CGPoint.zero
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
    
    func addMenuItems(menuItems: [CellMenuItem])
    {
        
    }
    
    func drawCellMenu (menuColor: UIColor, touchPoint: CGPoint)
    {
        if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"})
        {
            menuLayer.removeFromSuperlayer()
            menuIndexPath = nil
            menuShift = CGPoint.zero
            return
        }
        
        let menuLayer = PhotoMenuLayer()
        
        menuLayer.arrowSize = menuArrowSize
        menuLayer.fillColor = menuColor
        menuLayer.name = "MenuLayer"
        menuLayer.menuTouchPoint = touchPoint
        
        let menuFrame = CGRect(x: touchPoint.x, y: touchPoint.y, width: menuBarSize.width, height: menuBarSize.height + menuArrowSize.height)
        
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: 0, y: menuArrowSize.height, width: menuBarSize.width, height: menuBarSize.height)
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
        
        let flagSetLayer = CALayer()
        flagSetLayer.name = "flagSetLayer"
        flagSetLayer.frame = CGRect(x: 0, y: 0, width: menuBarSize.width/3.0, height: menuBarSize.height)
        flagSetLayer.contentsScale = UIScreen.main.scale
        flagSetLayer.contents = UIImage(named: "flag.menu.icon")?.cgImage
        flagSetLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        flagSetLayer.zPosition = barLayer.zPosition + 1
        barLayer.addSublayer(flagSetLayer)
        
        let trashLayer = CALayer()
        trashLayer.name = "trashLayer"
        trashLayer.frame = CGRect(x: menuBarSize.width/3.0, y: 0, width: menuBarSize.width/3.0, height: menuBarSize.height)
        trashLayer.contentsScale = UIScreen.main.scale
        trashLayer.contents = UIImage(named: "trash.menu.icon")?.cgImage
        trashLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        trashLayer.zPosition = barLayer.zPosition + 1
        barLayer.addSublayer(trashLayer)
        
        let cnxLayer = CALayer()
        cnxLayer.name = "cnxLayer"
        cnxLayer.frame = CGRect(x: menuBarSize.width/3.0 * 2.0, y: 0, width: menuBarSize.width/3.0, height: menuBarSize.height)
        cnxLayer.contentsScale = UIScreen.main.scale
        cnxLayer.contents = UIImage(named: "cnx.menu.icon")?.cgImage
        cnxLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        cnxLayer.zPosition = barLayer.zPosition + 1
        barLayer.addSublayer(cnxLayer)
        
        menuLayer.addSublayer(barLayer)
        
        layer.addSublayer(menuLayer)
        
        menuLayer.display()
        
    }

}
