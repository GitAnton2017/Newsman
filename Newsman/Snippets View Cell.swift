
import Foundation
import UIKit
import GameplayKit


@IBDesignable class SnippetsViewCell: UITableViewCell, DropViewProvidable, DragWaggleAnimatable
{
 lazy var dropView: UIView = self.setDropView(ratio: 0.75)
 
 var waggleView: UIView { return self }
 
 var animate: ((TimeInterval) -> Void)?
 var transDuration = 0.0
 var animationID: UUID?
 
 
 let snippetRowSelectedAlpha: CGFloat = 0.5
 
 var _selected = false

 final var snippetID: String
 {
  hostedSnippet?.id?.uuidString ?? "No Snippet Assigned"
 }

 final weak var tableView: UITableView?
 {
  return self.superview as? UITableView
 }
 
 final weak var currentFRC: SnippetsFetchController?
 {
  (tableView?.dataSource as? SnippetsViewDataSource)?.currentFRC
 }


 final var snippet: BaseSnippet? { hostedSnippet }
 
 final var discloseView: UIImageView?
 {
  (accessoryView as? UIButton)?.imageView
 }
 
 
 final var priorityViewConstraints: [NSLayoutConstraint] = []
 
 final lazy var priorityView: SnippetPriorityView =
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
   pv.trailingAnchor.constraint (equalTo: contentView.trailingAnchor, constant: 0),
   pv.widthAnchor.constraint    (equalToConstant:  90)
  ]
  


  NSLayoutConstraint.activate(priorityViewConstraints)
  
  return pv
 }()
 
 

 func reloadIconView()
 {
  print(#function)
  loadFirstImage(size: flipperView.frame.width)
 }
 
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
   
   isSnippetRowSelected = snippet.isSelected
   isDragAnimating = snippet.isDragAnimating
   
   priorityView.priority = snippet.snippetPriority
   
   discloseView?.transform = snippet.disclosedCell ? .rotate90p: .identity
   
   flipperViewBottom.constant = snippet.disclosedCell ? Disclosed.bottom : Normal.bottom
 
   locationLabel.transform = snippet.disclosedCell ? .identity: Normal.locationAT
  
   locationLabel.text = snippet.snippetLocation
   
   snippetTextTag.font = snippet.disclosedCell ? Disclosed.nameFont : Normal.nameFont
   snippetDateTag.font = snippet.disclosedCell ? Disclosed.dateFont : Normal.dateFont
   
   loadFirstImage(size: flipperView.frame.width)
   
  }
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
  set { layer.borderWidth = newValue }
  get { layer.borderWidth }
 }

 @IBInspectable var borderColor: UIColor
 {
  set { layer.borderColor = newValue.cgColor }
  get { UIColor(cgColor: layer.borderColor!) }
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

 

 final lazy var locationLabel: UILabel =
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

 private var cellPaddings: UIEdgeInsets = .zero
 
 @IBInspectable var topPadding: CGFloat
 {
  get { cellPaddings.top }
  set { cellPaddings.top = newValue }
 }
 
 @IBInspectable var bottomPadding: CGFloat
 {
  get { cellPaddings.bottom }
  set { cellPaddings.bottom = newValue }
 }
 
 @IBInspectable var leftPadding: CGFloat
 {
  get { cellPaddings.left }
  set { cellPaddings.left = newValue }
 }
 
 @IBInspectable var rightPadding: CGFloat
 {
  get { cellPaddings.right }
  set { cellPaddings.right = newValue }
 }
 
 override var frame: CGRect
 {
  get { super.frame }
  set { super.frame = newValue.inset(by: cellPaddings) }
 }
 
 override func awakeFromNib()
 {
  super.awakeFromNib()

  configueDropInteraction()
  configueSpringInteraction()
  snippetImage.layer.masksToBounds = true
  configueDisclosure()
  
 }


 func stopImageProvider()
 {
   hostedSnippet?.imageProvider.cancelRandomImagesOperations()
 }


 func clear()
 {
 
  hostedSnippet = nil
  snippetImage.layer.removeAllAnimations()
  animate = nil
  transDuration = 0.0
  animationID = nil
  imageSpinner.startAnimating()
  snippetImage.image = nil
  flipperViewBottom.constant = Normal.bottom
  
  _selected = false
  contentView.alpha = 1
  backgroundColor = backgroundColor?.withAlphaComponent(snippetRowSelectedAlpha)
  
 }

 
 
 override func prepareForReuse()
 {
  super.prepareForReuse()
  clear()
 }


 

 override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
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

