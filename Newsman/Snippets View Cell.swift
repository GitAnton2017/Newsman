
import Foundation
import UIKit
import GameplayKit

protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
}

@IBDesignable class SnippetsViewCell: UITableViewCell, CAAnimationDelegate, ImageContextLoadProtocol
{
 private struct Normal
 {
  static let bottom: CGFloat = 10
  static let nameFont = UIFont.systemFont(ofSize: 17)
  static let dateFont = UIFont.systemFont(ofSize: 15)
  static let shift: CGFloat = 30
  static let locationAT = CGAffineTransform(translationX: 0, y: shift)
 }
 
 private struct Disclosed
 {
  static let bottom: CGFloat = 30
  static let nameFont = UIFont.boldSystemFont(ofSize: 20)
  static let dateFont = UIFont.boldSystemFont(ofSize: 18)
 }
 
 var animate: ((TimeInterval) -> Void)?
 var transDuration = 0.0
 var animationID: UUID?

 var snippetID: String {return (hostedSnippet as? BaseSnippet)?.id?.uuidString ?? "No Snippet Assigned"}

 private weak var tableView: UITableView? {return self.superview as? UITableView}
 
 private weak var currentFRC: SnippetsFetchController?
 {
  return (tableView?.dataSource as? SnippetsViewDataSource)?.currentFRC
 }
 
 final var groupType: GroupSnippets? {return currentFRC?.groupType}

 private var snippet: BaseSnippet? {return hostedSnippet as? BaseSnippet}
 private var discloseView: UIImageView? {return (accessoryView as? UIButton)?.imageView}


 
 private  var priorityViewConstraints: [NSLayoutConstraint] = []
 
 
 private lazy var priorityView: SnippetPriorityView =
 {
  
  let pv = SnippetPriorityView(frame: .zero)
  guard let snippet = snippet else {return pv}
  
  pv.backgroundColor = .clear
  
  contentView.addSubview(pv)
  
  pv.translatesAutoresizingMaskIntoConstraints = false
 
  priorityViewConstraints  =
  [
   pv.topAnchor.constraint      (equalTo: snippetTextTag.topAnchor, constant: 0),
   pv.bottomAnchor.constraint   (equalTo: snippetDateTag.bottomAnchor, constant:  0),
   pv.trailingAnchor.constraint (equalTo: contentView.trailingAnchor, constant: 30),
   pv.widthAnchor.constraint    (equalToConstant:  90)
  ]
  


  NSLayoutConstraint.activate(priorityViewConstraints)
  
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
   
   flipperViewBottom.constant = snippet.disclosedCell ? Disclosed.bottom : Normal.bottom
 
   locationLabel.transform = snippet.disclosedCell ? .identity: Normal.locationAT
  
   locationLabel.text = snippet.snippetLocation
   
   snippetTextTag.font = snippet.disclosedCell ? Disclosed.nameFont : Normal.nameFont
   snippetDateTag.font = snippet.disclosedCell ? Disclosed.dateFont : Normal.dateFont
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
 @IBOutlet var flipperView: UIView!
 
 @IBOutlet var flipperViewBottom: NSLayoutConstraint!
 
 let discCellConst: CGFloat = 30.0
 let normCellConst: CGFloat = 10.0
 
 
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
     title.topAnchor.constraint       (equalTo: flipperView.bottomAnchor, constant: 5),
     title.leadingAnchor.constraint   (equalTo: flipperView.leadingAnchor, constant: 0),
     title.trailingAnchor.constraint  (equalTo: priorityView.trailingAnchor, constant: 0)
    ]
   )
  
   return title
 }()

 
 
 
 
 private func animateFontSize(disclosure: Bool)
 {
  UIView.transition(with: snippetTextTag, duration: 0.25,
                    options: [.transitionFlipFromTop, .allowAnimatedContent, .curveEaseInOut],
                    animations:
                    {[weak self] in
                     self?.snippetTextTag.font = disclosure ? Disclosed.nameFont : Normal.nameFont
                    }, completion: nil)
  
  UIView.transition(with: snippetDateTag, duration: 0.25,
                    options: [.transitionFlipFromBottom, .allowAnimatedContent, .curveEaseInOut],
                    animations:
                    {[weak self] in
                     self?.snippetDateTag.font = disclosure ? Disclosed.dateFont : Normal.dateFont
                    }, completion: nil)
  
 }
 
 
 
 private func animateLocation(disclosure: Bool, comletion: (()->())? = nil)
 {
  
  UIView.animate(withDuration: 0.25, delay: 0,
                 usingSpringWithDamping: 0.75,
                 initialSpringVelocity: 10, options: [.curveEaseIn],
                 animations:
                 {[weak self] in self?.locationLabel.transform = disclosure ? .identity : Normal.locationAT },
                 completion:
                 {_ in comletion?() })
 }
 
 
 private func animateRowDisclosure(completion: (()->())? = nil)
 {
  flipperViewBottom.constant = Disclosed.bottom
  tableView?.performBatchUpdates(nil)
  {[weak self] _ in
   self?.updateCellImageSet(with: self?.flipperView.bounds.width)
   self?.animateFontSize(disclosure: true)
   self?.animateLocation(disclosure: true)
   {
    completion?()
   }
  }
 }
 
 private func animateRowClosure(completion: (()->())? = nil)
 {
  animateLocation(disclosure: false)
  {[weak self] in
   self?.flipperViewBottom.constant = Normal.bottom
   self?.tableView?.performBatchUpdates(nil)
   {_ in
    self?.animateFontSize(disclosure: false)
    completion?()
   }
  }
 }
 
 private func refreshRowHeight(with state: Bool, completion: (()->())? = nil)
 {
  switch state
  {
   case true: animateRowDisclosure() {completion?()}
   case false: animateRowClosure() {completion?()}
  }
 }
 
 private func toggleCellDisclosure(with snippet: BaseSnippet, completion: (()->())? = nil)
 {
  guard let moc = snippet.managedObjectContext else { return }
  currentFRC?.deactivateDelegate()
  moc.persist(block: {snippet.disclosedCell.toggle()})
  {flag in
   self.currentFRC?.activateDelegate()
   guard flag else { return }
   self.refreshRowHeight(with: snippet.disclosedCell)
   {
    completion?()
   }
  }
 }

 @objc private func disclosurePressed(_ sender: UIButton)
 {
  
  guard let snippet = snippet else {return}

  discloseView?.transform = snippet.disclosedCell ? .rotate90p: .identity
  sender.isUserInteractionEnabled = false
  UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                 initialSpringVelocity: 10, options: [.curveEaseOut],
                 animations:
                 {[weak self] in
                  guard let cell = self else {return}
                  cell.discloseView?.transform = snippet.disclosedCell ? .identity : .rotate90p
                 },
                 completion: nil)
  
  toggleCellDisclosure(with: snippet)
  {
   sender.isUserInteractionEnabled = true
  }
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
  {[weak snippet, weak self] image in
   guard let cell = self, cell.hostedSnippet === snippet else {return}
   cell.snippetImage.image = image
   cell.imageSpinner.stopAnimating()
   cell.snippetImage.layer.removeAllAnimations()
   
   cell.hostedSnippet?.imageProvider.getRandomImages(requiredImageWidth: newSize)
   {[weak snippet, weak self] images in
    guard var images = images else {return}
    guard let cell = self else {return}
    guard cell.hostedSnippet === snippet else {return}
    
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
   hostedSnippet?.imageProvider.cancelRandomImagesOperations()
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
  {[weak self, weak snippet] in
   guard let cell = self else {return}
   guard cell.animationID == anim.value(forKey: "animationID") as? UUID else {return}
   guard cell.hostedSnippet === snippet else {return}
   cell.animate?(0.25 * cell.transDuration)
  }
 }

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
  //print ("Snippet cell with ID \(snippetID.quoted) DESTROYED!")
 }
}

