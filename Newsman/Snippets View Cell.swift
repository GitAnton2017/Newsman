
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
 
    private func getDisclosureImage(of color: UIColor) -> UIImage
    {
     let format = UIGraphicsImageRendererFormat.preferred()
     let rect = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
     let render = UIGraphicsImageRenderer(bounds: rect, format: format)
     let image = render.image
     {_ in
      
      let p1 = CGPoint.zero
      let p2 = CGPoint(x: rect.width , y: rect.height / 2)
      let p3 = CGPoint(x: 0,  y: rect.height)
      let p4 = CGPoint(x: rect.width / 3, y: rect.height / 2)
      
      let path = UIBezierPath(points: [p1, p2, p3, p4])
      
      color.setFill()
      path.fill()
      
     }
     
     return image
    }
 
    @objc func disclosurePressed(_ sender: UIButton)
    {
    }
 
    private func configueDisclosure()
    {
     let b = UIButton(type: .custom)
  
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 1, green: 0.08644389563, blue: 0.04444610194, alpha: 1)), for: .normal)
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)), for: .highlighted)
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), for: .focused)
     b.addTarget(self, action: #selector(disclosurePressed), for: .touchDown)
     
     b.sizeToFit()
     accessoryView = b
     
    }
 
    override func awakeFromNib()
    {
     super.awakeFromNib()
     
     //snippetImage.layer.cornerRadius = 3.5
     //snippetImage.layer.borderWidth = 1.25
     //snippetImage.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
     snippetImage.layer.masksToBounds = true
     configueDisclosure()
     
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

