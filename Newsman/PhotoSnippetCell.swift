import UIKit
import Foundation
import CoreData


class LayerDelegate: NSObject, CALayerDelegate
{
    
    var fillColor: UIColor!
    
    func draw(_ layer: CALayer, in ctx: CGContext)
    {
        ctx.beginPath()
        
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 0, y: layer.bounds.height)
        let p3 = CGPoint(x: layer.bounds.width/2, y: layer.bounds.height * 0.75)
        let p4 = CGPoint(x: layer.bounds.width, y: layer.bounds.height)
        let p5 = CGPoint(x: layer.bounds.width, y: 0)
        
        ctx.addLines(between: [p1,p2,p3,p4,p5])
        ctx.setFillColor(fillColor.cgColor)
        ctx.closePath()
        
        ctx.fillPath()
        
        
    
    }
}

class MenuLayer: CALayer
{
    var fillColor: UIColor!
    var arrowHeight: CGFloat!
    var arrowWidth: CGFloat!
    
    override func draw(in ctx: CGContext)
    {
      ctx.beginPath()
      let p1 = CGPoint(x: 0, y: 0)
      let p2 = CGPoint(x: 0, y: bounds.height)
      let p3 = CGPoint(x: bounds.width, y: bounds.height)
      let p4 = CGPoint(x: bounds.width, y: arrowHeight)
      let p5 = CGPoint(x: arrowWidth, y: arrowHeight)
    
      ctx.addLines(between: [p1,p2,p3,p4,p5])
      ctx.setFillColor(fillColor.cgColor)
      ctx.closePath()
        
      ctx.fillPath()
    }
}

class FlagLayer: CALayer
{
    var fillColor: UIColor!

    override func draw(in ctx: CGContext)
    {
        ctx.beginPath()
        
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 0, y: bounds.height)
        let p3 = CGPoint(x: bounds.width/2, y: bounds.height * 0.75)
        let p4 = CGPoint(x: bounds.width, y: bounds.height)
        let p5 = CGPoint(x: bounds.width, y: 0)
        
        ctx.addLines(between: [p1,p2,p3,p4,p5])
        ctx.setFillColor(fillColor.cgColor)
        ctx.closePath()
        
        ctx.fillPath()
    }
}

class PhotoSnippetCell: UICollectionViewCell
{
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        let menuPress = UITapGestureRecognizer(target: self, action: #selector(cellLongPress))
        addGestureRecognizer(menuPress)
    
    }
    
    @objc func cellLongPress(_ gr: UIGestureRecognizer)
    {
      let location = gr.location(in: self)
      print ("LONG PRESSED AT \(location)")
      drawMenu(menuColor: UIColor.red, touchPoint: location)

    }
    
    @objc func deleteCell(_ sender: UIMenuController)
    {
     print ("delete")
        
    }
    
    override var canBecomeFirstResponder: Bool {return true}
    
    override func awakeFromNib()
    {
        spinner.startAnimating()
        super.awakeFromNib()
        if let menuLayer = layer.superlayer?.sublayers?.first(where: {$0.name == "MenuLayer"})
        {
            menuLayer.removeFromSuperlayer()
        }
    }
    
    override func prepareForReuse()
    {
        spinner.startAnimating()
        super.prepareForReuse()
        if let menuLayer = layer.superlayer?.sublayers?.first(where: {$0.name == "MenuLayer"})
        {
            menuLayer.removeFromSuperlayer()
        }
    }
    
    func clearFlag ()
    {
        if let prevFlagLayer = photoIconView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
          prevFlagLayer.removeFromSuperlayer()
        }
    }
    
    func drawMenu (menuColor: UIColor, touchPoint: CGPoint)
    {
     if let menuLayer = layer.superlayer?.sublayers?.first(where: {$0.name == "MenuLayer"})
     {
      menuLayer.removeFromSuperlayer()
      return
     }
     
     let menuLayer = MenuLayer()
     menuLayer.arrowHeight = 50.0
     menuLayer.arrowWidth = 10.0
     menuLayer.fillColor = menuColor
     menuLayer.name = "MenuLayer"
     let point = photoIconView.layer.convert(touchPoint, to: layer.superlayer)
     let menuFrame = CGRect(x: point.x, y: point.y, width: 100.0, height: 100.0)
     
     if point.x + 100.0 >= layer.superlayer!.bounds.width &&
        point.y + 100.0 <= layer.superlayer!.bounds.height
     {
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
     }
        
     if point.y + 100.0 >= layer.superlayer!.bounds.height &&
        point.x + 100.0 <= layer.superlayer!.bounds.width
     {
        menuLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        menuLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
     }
        
     if point.y + 100.0 >= layer.superlayer!.bounds.height &&
        point.x + 100.0 >= layer.superlayer!.bounds.width
     {
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat.pi, 0, 1, 0)
        transform = CATransform3DRotate(transform, CGFloat.pi, 1, 0, 0)
        menuLayer.transform = transform
     }
     menuLayer.frame = menuFrame
     menuLayer.contentsScale = UIScreen.main.scale
     layer.superlayer?.addSublayer(menuLayer)
     
     menuLayer.display()
        
    }
    
    func drawFlag (flagColor: UIColor)
    {
        //let flagLayer = CALayer()
        let flagLayer = FlagLayer()
        flagLayer.fillColor = flagColor
        flagLayer.name = "FlagLayer"
        
        //flagLayer.delegate = (UIApplication.shared.delegate as! AppDelegate).layerDelegate
        //(UIApplication.shared.delegate as! AppDelegate).layerDelegate.fillColor = flagColor
        
        let imageSize = frame.width
        flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
        flagLayer.contentsScale = UIScreen.main.scale
        
        if let prevFlagLayer = photoIconView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
          photoIconView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
        }
        else
        {
          photoIconView.layer.addSublayer(flagLayer)
        }
        
        flagLayer.display()
    }
    

}
