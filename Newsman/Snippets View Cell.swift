
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
    {
     didSet
     {
      guard let snippet = snippet else {return}
      discloseView?.transform = snippet.disclosedCell ? CGAffineTransform(rotationAngle: .pi / 2): .identity
      
      let dy = -contentView.bounds.height / 4
      contentView.constraints.first{$0.identifier == "imageCenterY"}?.constant = snippet.disclosedCell ? dy : 0
      
      locationLabel.isHidden = !snippet.disclosedCell
      locationLabel.text = snippet.snippetLocation
     }
    }
 
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
 
    private func getDisclosureImage(of color: UIColor, and size: CGSize) -> UIImage
    {
     let format = UIGraphicsImageRendererFormat.preferred()
     let rect = CGRect(origin: .zero, size: size)
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
 
    private lazy var locationLabel: UILabel =
    {
      let title = UILabel(frame: CGRect.zero)
      title.lineBreakMode = .byTruncatingMiddle
      title.backgroundColor = UIColor.clear
      title.textAlignment = .left
      title.textColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
      title.font = UIFont.systemFont(ofSize: 13)
      contentView.addSubview(title)
      
      title.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate(
       [
        title.topAnchor.constraint       (equalTo: snippetImage.bottomAnchor, constant: 10),
        title.leadingAnchor.constraint   (equalTo: snippetImage.leadingAnchor, constant: 0),
        title.trailingAnchor.constraint  (equalTo: contentView.trailingAnchor, constant: -10)
       ]
      )
      
      return title
    }()
 
    private var tableView: UITableView?
    {
     return self.superview as? UITableView
    }
    private var currentFRC: SnippetsFetchController?
    {
     return (tableView?.dataSource as? SnippetsViewDataSource)?.currentFRC
    }
    private var snippet: BaseSnippet?
    {
     return hostedSnippet as? BaseSnippet
    }
    private var discloseView: UIImageView?
    {
     return (accessoryView as? UIButton)?.imageView
    }
 
    private func refresh()
    {
     guard let snippet = snippet else {return}
     currentFRC?.deactivateDelegate()
     snippet.managedObjectContext?.persistAndWait{snippet.disclosedCell = !snippet.disclosedCell}
     currentFRC?.activateDelegate()
     
     
     if snippet.disclosedCell
     {
      tableView?.performBatchUpdates(nil)
      {[weak self] _ in
       guard let cell = self else {return}
       let dy = -cell.contentView.bounds.height / 4
       cell.contentView.constraints.first{$0.identifier == "imageCenterY"}?.constant = dy
       
       let locationLabelAnim: (Bool) -> Void  =
       {[weak self] _ in
        self?.locationLabel.transform = CGAffineTransform(translationX: 0, y: -dy * 2)
        self?.locationLabel.isHidden = false
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1.5,
                       initialSpringVelocity: 10, options: [.curveEaseIn],
                       animations:
                       {[weak self] in self?.locationLabel.transform = .identity},
                       completion: nil)
        
       }
       
       UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.35,
                      initialSpringVelocity: 10, options: [.curveEaseIn],
                      animations:
                      {[weak self] in self?.contentView.layoutIfNeeded()},
                      completion: locationLabelAnim)
      }
     }
     else
     {
      contentView.constraints.first{$0.identifier == "imageCenterY"}?.constant = 0
      UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.35,
                     initialSpringVelocity: 10, options: [.curveEaseOut],
                     animations:
                     {[weak self] in self?.contentView.layoutIfNeeded()
                      self?.locationLabel.isHidden = true
                     },
                     completion:
                     {[weak self] _ in
                      
                      self?.tableView?.performBatchUpdates(nil)
                     })
     }
     
     
    }
 
    @objc private func disclosurePressed(_ sender: UIButton)
    {
     
     guard let snippet = snippet else {return}
     let rt = CGAffineTransform(rotationAngle: .pi / 2)
     discloseView?.transform = snippet.disclosedCell ? rt: .identity
     
     UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 10, options: [.curveEaseOut],
                    animations: {[weak self] in self?.discloseView?.transform = snippet.disclosedCell ? .identity : rt},
                    completion: nil)
     
     refresh()
    }
 
 
 
    private func configueDisclosure()
    {
     
     let rs: CGFloat = 22.0
     let a = bounds.size.height
     let size = CGSize(width: a, height: a)
     let rect = CGRect(origin: .zero, size: size)
     
     let b = UIButton(frame: rect)
    
     b.imageEdgeInsets = UIEdgeInsets(top: a / 3, left: a / 3 + rs, bottom: a / 3, right: a / 3 - rs)
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), and: size), for: .normal)
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), and: size), for: .highlighted)
     b.setImage(getDisclosureImage(of: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), and: size), for: .focused)
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

