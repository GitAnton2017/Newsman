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

class PhotoSnippetCell: UICollectionViewCell
{
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        spinner.startAnimating()
        super.awakeFromNib()
        imageRoundClip()
    }
    
    override func prepareForReuse()
    {
        spinner.startAnimating()
        super.prepareForReuse()
        imageRoundClip()
    }
    
    func clearFlag ()
    {
        if let prevFlagLayer = photoIconView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
          prevFlagLayer.removeFromSuperlayer()
        }
    }
    
    func imageRoundClip()
    {
       photoIconView.layer.cornerRadius = 10.0
       photoIconView.layer.borderWidth = 1.0
       photoIconView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
       photoIconView.layer.masksToBounds = true
    }
    
    func drawFlag (flagColor: UIColor)
    {
        let flagLayer = FlagLayer()
        flagLayer.fillColor = flagColor
        flagLayer.name = "FlagLayer"
        
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
