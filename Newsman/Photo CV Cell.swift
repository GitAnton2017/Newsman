import UIKit
import Foundation

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

@objc protocol PhotoSnippetCellProtocol: AnyObject
{
    var photoItemView: UIView     {get    }
    var cellFrame: CGRect         {get    }
    var isPhotoItemSelected: Bool {get set}
}

extension PhotoSnippetCellProtocol
{
    
    var cornerRadius: CGFloat
    {
     get {return photoItemView.layer.cornerRadius}
     set
     {
      photoItemView.layer.cornerRadius = newValue
     }
    }

    
    
    func clearFlag ()
    {
        if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
            prevFlagLayer.removeFromSuperlayer()
        }

    }
    
    func imageRoundClip()
    {
        photoItemView.clearsContextBeforeDrawing = true
        photoItemView.layer.cornerRadius = 10.0
        photoItemView.layer.borderWidth = 1.0
        photoItemView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
        photoItemView.layer.masksToBounds = true
        
    }
    
    func drawFlag (flagColor: UIColor)
    {
        let flagLayer = FlagLayer()
        flagLayer.fillColor = flagColor
        flagLayer.name = "FlagLayer"
    
        let imageSize = cellFrame.width
        flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
        flagLayer.contentsScale = UIScreen.main.scale
        
        if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
            photoItemView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
        }
        else
        {
            photoItemView.layer.addSublayer(flagLayer)
        }
        
        flagLayer.setNeedsDisplay()
    }
 
    func drawPlayIcon (iconColor: UIColor, r: CGFloat = 0.3, shift: CGFloat = 0.07, width: CGFloat = 0.03)
    {
     let D = cellFrame.width // cell contentView diametr...
     let rect = CGRect(origin: .zero, size: CGSize(width: D, height: D))
     let player = CAShapeLayer()
     player.contentsScale = UIScreen.main.scale
     player.frame = rect
     player.name = "player"
     let path = CGMutablePath()
     let rs = r + shift
     let r1 = r + width // 0.03 define the width of outer ring...
     
     path.addEllipse(in: rect.insetBy(dx: r * D, dy: r * D))    //outer circle
     path.addEllipse(in: rect.insetBy(dx: r1 * D, dy: r1 * D))  //inner circle
  
     let p13x = D * (1/2 + (rs - 1/2) * cos(.pi/3))
     let q = (rs - 1/2) * sin(.pi/3)
     let p1 = CGPoint(x: p13x, y:  D * (1/2 + q))
     let p2 = CGPoint(x:  D * (1 - rs), y:  D / 2)
     let p3 = CGPoint(x:  p13x, y:  D * (1/2 - q))
  
     path.addLines(between: [p1, p2, p3]) // play icon internal triangle points...
     player.path = path
     player.strokeColor = iconColor.cgColor
     player.fillColor = iconColor.cgColor
     player.fillRule = kCAFillRuleEvenOdd
     player.opacity = 0.5
     
     if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "player"})
     {
      photoItemView.layer.replaceSublayer(prevFlagLayer, with: player)
     }
     else
     {
      photoItemView.layer.addSublayer(player)
     }
     
   }
}


class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    var isPhotoItemSelected: Bool
    {
      set {photoIconView.alpha = newValue ? 0.5 : 1}
      get {return photoIconView.alpha == 0.5       }
    }
 
    var photoItemView: UIView {return self.contentView}
    var cellFrame: CGRect     {return self.frame}
    
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        spinner.startAnimating()
        photoIconView.image = nil
        clearFlag()
        imageRoundClip()
        
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        spinner.startAnimating()
        photoIconView.image = nil
        clearFlag()
        imageRoundClip()
    }
    
    
}


