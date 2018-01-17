
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

class PhotoSnippetCollectionView: UICollectionView
{
    var ascendingSort: Bool
    {
      get
      {
        return (dataSource as! PhotoSnippetViewController).photoSnippet.ascending
      }
        
      set
      {
       (dataSource as! PhotoSnippetViewController).photoSnippet.ascending = newValue
        GroupPhotos.ascending = newValue
      }
    }
    var photoGroupType: GroupPhotos
    {
      get
      {
        let grouping = (dataSource as! PhotoSnippetViewController).photoSnippet.grouping
        return GroupPhotos(rawValue: grouping!)!
      }
        
      set
      {
       
       let ds = dataSource as! PhotoSnippetViewController
       if (newValue == .makeGroups && photoGroupType != .makeGroups)
       {
         ds.photoItems2D = ds.sectionedPhotoItems()
       }
       else if (newValue != .makeGroups && photoGroupType == .makeGroups)
       {
         ds.photoItems2D = ds.desectionedPhotoItems()
         ds.photoItems2D[0].sort(by: newValue.sortPredicate!)
       }
       else if (newValue != .makeGroups && photoGroupType != .makeGroups)
       {
         ds.photoItems2D[0].sort(by: newValue.sortPredicate!)
         ascendingSort = !ascendingSort
       }
       else
       {
        ascendingSort = !ascendingSort
        ds.photoItems2D = ds.sectionedPhotoItems()
       }
    
       ds.photoSnippet.grouping = newValue.rawValue
       reloadData()
      }
    }
    
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
    
    var hasUnfinishedMove = false
    var unfinishedMoveCell: PhotoSnippetCell? = nil

    
    func cancellUnfinishedMove()
    {
        if hasUnfinishedMove
        {
            cancelInteractiveMovement()
            unfinishedMoveCell?.photoIconView.alpha = 1
            unfinishedMoveCell?.photoIconView.layer.borderWidth = 1
            unfinishedMoveCell = nil
            hasUnfinishedMove = false
        }
    }
    func reorderPhoto (tappedCell cell: PhotoSnippetCell, tappedIndexPath indexPath: IndexPath, with gr: UILongPressGestureRecognizer)
    {
        let tp = gr.location(in: self)
        switch (gr.state)
        {
         case .began:
          cancellUnfinishedMove()
          beginInteractiveMovementForItem(at: indexPath)
          hasUnfinishedMove = true
          unfinishedMoveCell = cell
          cell.photoIconView.alpha = 0.75
          cell.photoIconView.layer.borderWidth = 5.0
          UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut,.`repeat`,.autoreverse],
                         animations: {cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)},
                         completion: nil)
          

         case .changed: updateInteractiveMovementTargetPosition(tp)
         case .ended:
    
          endInteractiveMovement()
          hasUnfinishedMove = false
          unfinishedMoveCell = nil
          cell.photoIconView.layer.borderWidth = 1.0
          cell.photoIconView.alpha = 1
       
         default: cancellUnfinishedMove()
        }
    
    }
    
    @objc func cellLongPress(_ gr: UILongPressGestureRecognizer)
    {
        let touchPoint = gr.location(in: self)
        
        if isPhotoEditing,
            let ip = indexPathForItem(at: touchPoint),
            let cell = cellForItem(at: ip) as? PhotoSnippetCell
        {
          reorderPhoto(tappedCell: cell, tappedIndexPath: ip, with: gr)
        }
        else if let _ = indexPathForItem(at: touchPoint)
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
    
    func movePhoto (at indexPath: IndexPath, with flagStr: String?)
    {
     let ds = dataSource as! PhotoSnippetViewController
     if let section = ds.photoItems2D.enumerated().first(where: {$0.element.first?.photo.priorityFlag == flagStr})
     {
      moveBetweenExistingSections(at: indexPath, to: section, with: flagStr)
     }
     else
     {
      let pred =
      {(item: (offset : Int, element: [PhotoItem])) -> Bool in
       let firstItem = item.element.first?.photo.priorityFlag
       let currRate = (firstItem == nil ? -1 : PhotoPriorityFlags(rawValue: (firstItem)!)!.rateIndex)
       let rate =     (flagStr ==   nil ? -1 : PhotoPriorityFlags(rawValue:     flagStr!)!.rateIndex)
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
     moved.photo.priorityFlag = flagStr
     ds.photoItems2D[ds.photoItems2D.count - 1].append(moved)
     let destIndexPath = IndexPath(row: 0, section: ds.photoItems2D.count - 1)
     moveItem(at: indexPath, to: destIndexPath)
     refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
    }
    
    func moveToNewInsertedSection(at indexPath: IndexPath, to section: (offset : Int, element: [PhotoItem]), with flagStr: String?)
    {
     let ds = dataSource as! PhotoSnippetViewController
     ds.photoItems2D.insert([], at: section.offset)
     ds.sectionTitles?.insert(flagStr ?? "", at: section.offset)
     insertSections([section.offset])
     if section.offset > indexPath.section
     {
      let moved = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
      moved.photo.priorityFlag = flagStr
      ds.photoItems2D[section.offset].append(moved)
      let destIndexPath = IndexPath(row: 0, section: section.offset)
      moveItem(at: indexPath, to: destIndexPath)
      refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
     }
     else
     {
      let moved = ds.photoItems2D[indexPath.section + 1].remove(at: indexPath.row)
      moved.photo.priorityFlag = flagStr
      ds.photoItems2D[section.offset].append(moved)
      let destIndexPath = IndexPath(row: 0, section: section.offset)
      let sourIndexPath = IndexPath(row: indexPath.row, section: indexPath.section + 1)
      moveItem(at: sourIndexPath, to: destIndexPath)
      refreshSections(sourceIndexPath: sourIndexPath, destinationIndexPath: destIndexPath)
     }
    }
    
    func moveBetweenExistingSections(at indexPath: IndexPath, to section: (offset : Int, element: [PhotoItem]), with flagStr: String?)
    {
      guard section.offset != indexPath.section else
      {
       (cellForItem(at: indexPath) as! PhotoSnippetCell).photoIconView.alpha = 1.0
       return
      }
    
      let ds = dataSource as! PhotoSnippetViewController
      let moved = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
      moved.photo.priorityFlag = flagStr
      ds.photoItems2D[section.offset].append(moved)
      let destIndexPath = IndexPath(row: section.element.count, section: section.offset)
      moveItem(at: indexPath, to: destIndexPath)
      refreshSections(sourceIndexPath: indexPath, destinationIndexPath: destIndexPath)
    }
    
    func deletePhoto (at indexPath: IndexPath)
    {
     let ds = dataSource as! PhotoSnippetViewController
     let deleted = ds.photoItems2D[indexPath.section].remove(at: indexPath.row)
     deleted.deleteImage()
     deleteItems(at: [indexPath])
     if ds.photoItems2D[indexPath.section].count == 0
     {
      ds.photoItems2D.remove(at: indexPath.section)
      ds.sectionTitles?.remove(at: indexPath.section)
      deleteSections([indexPath.section])
     }
     else if photoGroupType == .makeGroups
     {
      reloadSections([indexPath.section])
     }
    }
    
    @objc func tapCellMenuItem (gr: UITapGestureRecognizer)
    {
        cancellUnfinishedMove()
        let touchPoint = gr.location(in: self)
        if let menuLayer = layer.sublayers?.first(where: {$0.name == "MenuLayer"}) as? PhotoMenuLayer,
           let buttonLayer = menuLayer.hitTest(touchPoint)
        {
           let ds = dataSource as! PhotoSnippetViewController
           switch (buttonLayer.name)
           {
            case "flagSetLayer"? :
             if let _ = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              menuLayer.removeFromSuperlayer()
              drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuLayer.menuTouchPoint, menuItems: flagMenuItems)
             }
                
            case "trashLayer"? :
             if let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              deletePhoto(at: indexPath)
             }
             closeLayerAnimated(layer: menuLayer)
        
            case "flagLayer"?:
             let flagColor = (buttonLayer as! FlagItemLayer).flagColor
             let flagStr = PhotoPriorityFlags.priorityColorMap.first(where: {$0.value == flagColor})?.key.rawValue
             if let indexPath = indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              let cell = cellForItem(at: indexPath) as! PhotoSnippetCell
              cell.drawFlag(flagColor: flagColor!)
              
              if photoGroupType != .makeGroups
              {
               ds.photoItems2D[indexPath.section][indexPath.row].photo.priorityFlag = flagStr
              }
              else
              {
                movePhoto(at: indexPath, with: flagStr)
              }
              
             }
             closeLayerAnimated(layer: menuLayer)
            
            case "unflagLayer"?:
             if let indexPath = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
              let cell = cellForItem(at: indexPath) as! PhotoSnippetCell
              cell.clearFlag()
              if photoGroupType != .makeGroups
              {
                ds.photoItems2D[indexPath.section][indexPath.row].photo.priorityFlag = nil
              }
              else
              {
               movePhoto(at: indexPath, with: nil)
              }
             }
             closeLayerAnimated(layer: menuLayer)
           
            
            case "upLayer"?:
             if let _ = self.indexPathForItem(at: menuLayer.menuTouchPoint)
             {
               menuLayer.removeFromSuperlayer()
               self.drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuLayer.menuTouchPoint, menuItems: mainMenuItems)
             }
           case "cnxLayer"?:
             closeLayerAnimated(layer: menuLayer)
        
            
           default: break
            
          }//switch
          
          self.menuIndexPath = nil
          self.menuShift = CGPoint.zero
          
        
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
    
    enum CellMenuType: Int
    {
        case normal = 0
        case right =  1
        case bottom = 2
        case corner = 3
    }
    
    var cellMenuType: CellMenuType!
    
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
            cellMenuType = .right
        }
        
        if touchPoint.y + menuFrame.height >= layer.bounds.height &&
           touchPoint.x + menuFrame.width  <= layer.bounds.width
        {
            menuLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
            barLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
            cellMenuType = .bottom
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
        
        menuLayer.display()
        
    }

}
