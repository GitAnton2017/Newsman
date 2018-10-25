
import Foundation
import UIKit

protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
// var photoItems: [PhotoItem] {get set}
}



@IBDesignable class BorderedImageView: UIImageView
{
 @IBInspectable var cornerRadius: CGFloat
 {
  set {layer.cornerRadius = newValue}
  get {return layer.cornerRadius}
 }
 
 @IBInspectable var borderWidth: CGFloat
  {
  set {layer.borderWidth = newValue}
  get {return layer.borderWidth}
 }
 
 @IBInspectable var borderColor: UIColor
 {
  set {layer.borderColor = newValue.cgColor}
  get {return UIColor(cgColor: layer.borderColor!)}
 }
 
 
 
}

@IBDesignable class SnippetsViewCell: UITableViewCell, CAAnimationDelegate, ImageContextLoadProtocol
{
 
//    var photoItems: [PhotoItem] = []
 
    private var _stop_flag = false
 
    var snippetID: String
    {
     return (hostedSnippet as? BaseSnippet)?.id?.uuidString ?? ""
    }
 
    weak var hostedSnippet: SnippetImagesPreviewProvidable?
 
    var isLoadTaskCancelled: Bool
    {
     get
     {
      guard Thread.current != Thread.main else {return _stop_flag}
      return DispatchQueue.main.sync {return _stop_flag}
     }
     set
     {
      DispatchQueue.main.async {[weak self] in self?._stop_flag = newValue}
      //if newValue {photoItems.forEach{$0.cancelImageOperation()}
       //photoItems = []
      //}
     }
    }

 
    @IBOutlet var snippetTextTag: UILabel!
    @IBOutlet var snippetDateTag: UILabel!
    @IBOutlet var snippetImage: UIImageView!
    @IBOutlet var imageSpinner: UIActivityIndicatorView!
 
    var animate: ((TimeInterval) -> Void)?
    var transDuration = 0.0
    var animating: [String : Bool] = [:]
 
    @IBInspectable var cornerRadius: CGFloat
    {
     set {layer.cornerRadius = newValue}
     get {return layer.cornerRadius}
    }
 
    @IBInspectable var borderWidth: CGFloat
    {
     set {layer.borderWidth = newValue}
     get {return layer.borderWidth}
    }
 
    @IBInspectable var borderColor: UIColor
    {
     set {layer.borderColor = newValue.cgColor}
     get {return UIColor(cgColor: layer.borderColor!)}
    }
 
    @IBInspectable var selectionColor: UIColor?
    {
     set
     {
      let v = UIView()
      v.backgroundColor = newValue
      selectedBackgroundView = v
     }
     get
     {
      return selectedBackgroundView?.backgroundColor
     }
    }
 
 
    override func awakeFromNib()
    {
     super.awakeFromNib()
     
     //snippetImage.layer.cornerRadius = 3.5
     //snippetImage.layer.borderWidth = 1.25
     //snippetImage.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
     snippetImage.layer.masksToBounds = true
     
    }
 
    func stopImageProvider()
    {
      hostedSnippet?.imageProvider.cancel()
    }
 
    func clear()
    {
     isLoadTaskCancelled = false
     hostedSnippet = nil
     snippetImage.layer.removeAllAnimations()
     animate = nil
     animating = [:]
     transDuration = 0.0
     imageSpinner.startAnimating()
     snippetImage.image = nil

    }
 
    override func prepareForReuse()
    {
     super.prepareForReuse()
     clear()
   
    }
 
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
     guard let status = animating["trans2" + snippetID], status else {return}
     let id = self.snippetID
     if (flag)
     {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + transDuration * 0.75)
      {[weak self] in
       guard let cell = self, cell.snippetID == id else {return}
       guard let status = cell.animating["trans2" + cell.snippetID], status else {return}
       cell.animate?(0.25 * cell.transDuration)
     
      }
     }
    }
 
    deinit
    {
     print ("Snippet cell with ID\(snippetID) DESTROYED!")
    }
}
