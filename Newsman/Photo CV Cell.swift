import UIKit
import Foundation
import AVKit

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
 
    func drawVideoDuration (textColor: UIColor, duration: CMTime)
    {
     let HH = Int(duration.seconds/3600)
     let MM = Int((duration.seconds - Double(HH) * 3600) / 60)
     let SS = Int(duration.seconds - Double(HH) * 3600 - Double(MM) * 60)
     
     let timeText = (HH > 0 ? "\(HH < 10 ? "0" : "")\(HH):" : "\u{20}\u{20}\u{20}") +
                    (HH > 0 || MM > 0 ? "\(MM < 10 ? "0" : "")\(MM):" : "\u{20}\u{20}:") +
                    "\(SS < 10 ? "0" : "")\(SS)"
     
     if let time = photoItemView.subviews.first(where: {$0.tag == 1}) as? UILabel
     {
      time.text = timeText
      return
     }
     
     let time = UILabel(frame: CGRect.zero)
     time.tag = 1
     time.font = UIFont.systemFont(ofSize: 25)
     time.minimumScaleFactor = 0.01
     time.numberOfLines = 1
     time.baselineAdjustment = .alignBaselines
     
     time.text = timeText
     
     time.backgroundColor = UIColor.clear
     time.textAlignment = .right
     time.adjustsFontSizeToFitWidth = true
     time.textColor = textColor
     
     photoItemView.addSubview(time)
     time.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate(
      [
       time.bottomAnchor.constraint  (equalTo:  photoItemView.bottomAnchor,  constant:  -5),
       time.trailingAnchor.constraint (equalTo:  photoItemView.trailingAnchor, constant: -5),
       time.widthAnchor.constraint(equalTo: photoItemView.widthAnchor, multiplier: 0.4),
       time.firstBaselineAnchor.constraint(equalTo: time.bottomAnchor, constant: 5)
 
      ]
     )
    }
 
    func showPlayIcon (iconColor: UIColor, r: CGFloat = 0.3, shift: CGFloat = 0.07, width: CGFloat = 0.03)
    {
     if photoItemView.subviews.contains(where: {$0.tag == 2 && $0 is PlayIconView}) {return}
     
     let playIcon = PlayIconView(iconColor: iconColor, r: r, shift: shift, width: width)
     playIcon.tag = 2
     playIcon.isUserInteractionEnabled = true
     photoItemView.addSubview(playIcon)
     playIcon.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate(
      [
       playIcon.bottomAnchor.constraint   (equalTo:  photoItemView.bottomAnchor  ),
       playIcon.trailingAnchor.constraint (equalTo:  photoItemView.trailingAnchor),
       playIcon.topAnchor.constraint      (equalTo:  photoItemView.topAnchor     ),
       playIcon.leadingAnchor.constraint  (equalTo:  photoItemView.leadingAnchor )
       
      ]
     )
     
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


