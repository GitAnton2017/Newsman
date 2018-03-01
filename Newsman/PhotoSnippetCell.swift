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

protocol PhotoSnippetCellProtocol
{
    var photoItemView: UIView {get}
    var cellFrame: CGRect     {get}
    func deselect ()
    func select ()
    
    
}

extension PhotoSnippetCellProtocol
{
    func clearFlag ()
    {
        if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
        {
            prevFlagLayer.removeFromSuperlayer()
        }
        deselect()
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
        deselect()
        
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
        
        flagLayer.display()
    }
}


class PhotoSnippetCell: UICollectionViewCell, PhotoSnippetCellProtocol
{
    func deselect() {photoIconView.alpha = 1}
    func select()   {photoIconView.alpha = 0.5}

    var photoItemView: UIView {return photoIconView}
    var cellFrame: CGRect     {return frame}
    
    @IBOutlet weak var photoIconView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        spinner.startAnimating()
        super.awakeFromNib()
        photoIconView.image = nil
        clearFlag()
        imageRoundClip()
    }
    
    override func prepareForReuse()
    {
        spinner.startAnimating()
        super.prepareForReuse()
        photoIconView.image = nil
        clearFlag()
        imageRoundClip()
    }
    
    
}


