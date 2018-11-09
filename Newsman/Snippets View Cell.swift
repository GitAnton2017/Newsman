
import Foundation
import UIKit
import GameplayKit

protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
}

@IBDesignable class SnippetsViewCell: UITableViewCell, CAAnimationDelegate, ImageContextLoadProtocol
{
 var animate: ((TimeInterval) -> Void)?
 var transDuration = 0.0
 var animationID: UUID?

 var snippetID: String {return (hostedSnippet as? BaseSnippet)?.id?.uuidString ?? "No Snippet Assigned"}

 private var tableView: UITableView? {return self.superview as? UITableView}
 
 private var currentFRC: SnippetsFetchController?
 {
  return (tableView?.dataSource as? SnippetsViewDataSource)?.currentFRC
 }

 private var snippet: BaseSnippet? {return hostedSnippet as? BaseSnippet}
 private var discloseView: UIImageView? {return (accessoryView as? UIButton)?.imageView}

 private lazy var imageCenterYConstraint = {contentView.constraints.lazy.first{$0.identifier == "imageCenterY"}}()
 private lazy var imageHeightConstraint  = {snippetImage.constraints.lazy.first{$0.identifier == "imageHeight"}}()

 private lazy var imageHeight: CGFloat = {imageHeightConstraint?.constant ?? 0}()
 private lazy var dx:          CGFloat = {imageHeight * 0.75                  }()

 private var dy: CGFloat {return -(contentView.bounds.height / 4 - dx / 2)}
 
 private lazy var priorityView: SnippetPriorityView =
 {
  
  let pv = SnippetPriorityView(frame: .zero)
  
  pv.backgroundColor = .clear
  
  contentView.addSubview(pv)
  
  pv.translatesAutoresizingMaskIntoConstraints = false
  
  NSLayoutConstraint.activate(
   [
    pv.topAnchor.constraint      (equalTo: snippetTextTag.topAnchor, constant: 0 ),
    pv.bottomAnchor.constraint   (equalTo: snippetDateTag.bottomAnchor, constant: 0),
    pv.trailingAnchor.constraint (equalTo: contentView.trailingAnchor, constant:  0),
    pv.widthAnchor.constraint    (equalToConstant: 100)
   ]
  )
  
  return pv
 }()

 weak var hostedSnippet: SnippetImagesPreviewProvidable?
 {
  didSet
  {
   guard let snippet = snippet else {return}
   
   snippetDateTag.text = snippet.snippetDateTag
   snippetTextTag.text = snippet.snippetName
   
   snippetImage.layer.removeAllAnimations()
   animate = nil
   transDuration = 0.0
   
   priorityView.priority = snippet.snippetPriority
   
   discloseView?.transform = snippet.disclosedCell ? .rotate90p: .identity
   
   imageCenterYConstraint?.constant = snippet.disclosedCell ? dy : 0
   imageHeightConstraint?.constant = imageHeight  + (snippet.disclosedCell ? dx : 0)
 
   locationLabel.transform = snippet.disclosedCell ? .identity: CGAffineTransform(translationX: bounds.width, y: 0)
   locationLabel.isHidden = !snippet.disclosedCell
   locationLabel.text = snippet.snippetLocation
   
   snippetTextTag.font = snippet.disclosedCell ? UIFont.boldSystemFont(ofSize: 20) : UIFont.systemFont(ofSize: 17)
   snippetDateTag.font = snippet.disclosedCell ? UIFont.boldSystemFont(ofSize: 18) : UIFont.systemFont(ofSize: 15)
  }
 }

 private var _stop_flag = false
 var isLoadTaskCancelled: Bool
 {
  get
  {
   guard Thread.current != Thread.main else {return _stop_flag}
   return DispatchQueue.main.sync {return _stop_flag}
  }
  set {DispatchQueue.main.async {[weak self] in self?._stop_flag = newValue}}
 }


 @IBOutlet var snippetTextTag: UILabel!
 @IBOutlet var snippetDateTag: UILabel!
 @IBOutlet var snippetImage: BorderedImageView!
 @IBOutlet var imageSpinner: UIActivityIndicatorView!


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
   title.font = UIFont.systemFont(ofSize: 14)
   contentView.addSubview(title)
  
   title.translatesAutoresizingMaskIntoConstraints = false
   NSLayoutConstraint.activate(
    [
     title.topAnchor.constraint       (equalTo: snippetImage.bottomAnchor, constant: 12),
     title.leadingAnchor.constraint   (equalTo: snippetImage.leadingAnchor, constant: 0),
     title.trailingAnchor.constraint  (equalTo: contentView.trailingAnchor, constant: 10)
    ]
   )
  
   return title
 }()



 private func refresh()
 {
  guard let snippet = snippet else {return}
  currentFRC?.deactivateDelegate()
  snippet.managedObjectContext?.persistAndWait{snippet.disclosedCell = !snippet.disclosedCell}
  currentFRC?.activateDelegate()
  
  
  if snippet.disclosedCell
  {
   snippetImage.layer.removeAllAnimations()
   stopImageProvider()
   tableView?.performBatchUpdates(nil)
   {[weak self] _ in
    guard let cell = self else {return}
    let dy = cell.dy
    cell.imageCenterYConstraint?.constant = dy
    cell.imageHeightConstraint?.constant += cell.dx
    cell.updateCellImageSet(with: cell.imageHeightConstraint?.constant)
    
    let locationLabelAnim: (Bool) -> Void  =
    {[weak self] _ in
     guard let cell = self else {return}
     cell.locationLabel.transform = CGAffineTransform(translationX: 0, y: -dy * 2)
     cell.locationLabel.isHidden = false
     UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 10, options: [.curveEaseIn],
                    animations:
                    {[weak self] in
                     guard let cell = self else {return}
                     cell.locationLabel.transform = .identity
                    },
                    completion: nil)
     
    }
    
    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1.5,
                   initialSpringVelocity: 10, options: [.curveEaseIn],
                   animations:
                   {[weak self] in
                    guard let cell = self else {return}
                    cell.snippetTextTag.font = UIFont.boldSystemFont(ofSize: 20)
                    cell.snippetDateTag.font = UIFont.boldSystemFont(ofSize: 18)
                    cell.contentView.layoutIfNeeded()
                   },
                   completion: locationLabelAnim)
   }
  }
  else
  {
   imageCenterYConstraint?.constant = 0
   imageHeightConstraint?.constant -= dx
   
   UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4,
                  initialSpringVelocity: 10, options: [.curveEaseOut],
                  animations:
                  {[weak self] in
                   guard let cell = self else {return}
                   cell.contentView.layoutIfNeeded()
                   cell.locationLabel.transform = CGAffineTransform(translationX: cell.bounds.width, y: 0)
                   cell.snippetTextTag.font = UIFont.systemFont(ofSize: 17)
                   cell.snippetDateTag.font = UIFont.systemFont(ofSize: 15)
                 
                  },
                  completion:
                  {[weak self] _ in
                   guard let cell = self else {return}
                   cell.locationLabel.isHidden = true
                   cell.tableView?.performBatchUpdates(nil)
                  })
  }
  
  
 }

 @objc private func disclosurePressed(_ sender: UIButton)
 {
  
  guard let snippet = snippet else {return}

  discloseView?.transform = snippet.disclosedCell ? .rotate90p: .identity
  
  UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                 initialSpringVelocity: 10, options: [.curveEaseOut],
                 animations:
                 {[weak self] in
                  guard let cell = self else {return}
                  cell.discloseView?.transform = snippet.disclosedCell ? .identity : .rotate90p
                 },
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

 
 private func updateCellImageSet(with newSize: CGFloat?)
 {
  guard let newSize = newSize else {return}
  guard let snippet = hostedSnippet as? BaseSnippet else {return}
  
  snippetImage.layer.removeAllAnimations()
  stopImageProvider()
  imageSpinner.startAnimating()
  
  hostedSnippet?.imageProvider.getLatestImage(requiredImageWidth: newSize)
  {[weak w_snippet = snippet, weak self] image in
   guard let cell = self, let ws = w_snippet, cell.hostedSnippet === ws else {return}
   cell.snippetImage.image = image
   cell.imageSpinner.stopAnimating()
   cell.snippetImage.layer.removeAllAnimations()
   
   cell.hostedSnippet?.imageProvider.getRandomImages(requiredImageWidth: newSize)
   {[weak w_snippet = snippet, weak self] images in
    guard var images = images else {return}
    guard let cell = self, let ws = w_snippet else {return}
    guard cell.hostedSnippet === ws else {return}
    
    if let firstImage = image {images.insert(firstImage, at: 0)}
    
    SnippetsAnimator.startRandom(for: Array(Set(images)), cell: cell, duration: 2.0, delay: 5.0)
   }
   
  }
 }



 override func awakeFromNib()
 {
  super.awakeFromNib()
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
  transDuration = 0.0
  animationID = nil
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
  guard let snippet = hostedSnippet as? BaseSnippet else {return}
  guard flag else {return}
  
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + transDuration * 0.75)
  {[weak self, weak w_snippet = snippet] in
   guard let cell = self, let ws = w_snippet else {return}
   guard cell.animationID == anim.value(forKey: "animationID") as? UUID else {return}
   guard cell.hostedSnippet === ws else {return}
   cell.animate?(0.25 * cell.transDuration)
  }
 }

// override func draw(_ rect: CGRect)
// {
//  guard let section = snippet?.snippetPriority.section else {return}
//  
//  let S: CGFloat = rect.width * 0.9
//  let w: CGFloat = 13
//  let h: CGFloat = rect.height
//  let dw: CGFloat = 5
//  
//  for i in 0..<6 - section
//  {
//   let p1 = CGPoint(x: S - h / 2 - w * CGFloat(i + 1) - dw * CGFloat(i), y: h / 2)
//   
//   let p2 = CGPoint(x: S - w * CGFloat(i + 1) - dw * CGFloat(i), y: 0)
//   let p3 = CGPoint(x: S - (w + dw) * CGFloat(i), y: 0)
//   let p4 = CGPoint(x: S - h / 2 - (w + dw)  * CGFloat(i), y: h / 2)
//   let p5 = CGPoint(x: S - (w + dw) * CGFloat(i), y: h)
//   let p6 = CGPoint(x: S - w * CGFloat(i + 1) - dw * CGFloat(i) , y: h)
//   
//   let path = UIBezierPath(points: [p1, p2, p3, p4, p5, p6])
//   
//   #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1).setFill()
//   path.fill()
//  }
// }
 
 
 override init(style: UITableViewCellStyle, reuseIdentifier: String?)
 //Must be implemented together with other initilizers of the @IBDesignable class
 {
  super.init(style: style, reuseIdentifier: reuseIdentifier)
 }

 required init?(coder aDecoder: NSCoder)
 //Must be implemented together with other initilizers of the @IBDesignable class
 {
  super.init(coder: aDecoder)
 }

 deinit
 {
  print ("Snippet cell with ID \(snippetID.quoted) DESTROYED!")
 }
}

