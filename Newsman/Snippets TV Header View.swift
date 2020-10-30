
import Foundation
import UIKit

class SnippetsTableViewHeaderView: SnippetsTableViewSupplemenaryView
{
 static let reuseID = "snippetsTableViewHeader"
 
 override func prepareForReuse()
 {
   super.prepareForReuse()
   isHiddenSection = false
 }
 
 @objc func sectionTapped(_ gr: UIGestureRecognizer)
 {
  guard let section = sectionNumber else { return }
  isHiddenSection.toggle()
  gr.isEnabled = false
  currentFRC?.toggleFoldSection(section: section)
  {_ in
   gr.isEnabled = true
  }
 }
 
 override init(reuseIdentifier: String?)
 {
  super.init(reuseIdentifier: reuseIdentifier)
  let tgr = UITapGestureRecognizer(target: self, action: #selector(sectionTapped))
  tgr.numberOfTapsRequired = 2
  addGestureRecognizer(tgr)
  
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 var isHiddenSection = false
 {
  didSet
  {
   UIView.transition(with: titleLabel, duration: 0.3,
                     options: [.transitionFlipFromTop, .allowUserInteraction ],
                     animations: {[ weak self ] in
                      guard let self = self else { return }
                      self.titleLabel.font = UIFont.boldSystemFont(ofSize: self.isHiddenSection ? 22 : 18)
                      self.titleLabel.textColor =
                       self.titleLabel.textColor.withAlphaComponent(self.isHiddenSection ? 0.75 : 1.0)
                     }, completion: nil)
   
   
   arrowView.transform = isHiddenSection ? .identity : .rotate90p
  
   let backColor = backView.backgroundColor
   backView.backgroundColor = .newsmanRed
   
   UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
                  options: [.curveEaseInOut, .allowUserInteraction ],
                  animations: {[ weak self ] in
                   guard let self = self else { return }
                   self.arrowView.transform = self.isHiddenSection ? .rotate90p : .identity
                   self.backView.backgroundColor = backColor?.withAlphaComponent(self.isHiddenSection ? 0.5 : 1.0)
                  }, completion: nil
   )
 
   

  }
 }
 
 
 
 private lazy var arrowView: UIImageView =
 {
  let format = UIGraphicsImageRendererFormat.preferred()
  let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
  let render = UIGraphicsImageRenderer(bounds: rect, format: format)
  let image = render.image
  {_ in
   
  
   let p1 = CGPoint.zero
   let p2 = CGPoint(x: rect.width / 2 , y: rect.height / 4)
   let p3 = CGPoint(x: rect.width, y: 0)
   let p4 = CGPoint(x: rect.width / 2, y: rect.height)
   
   let path = UIBezierPath(points: [p1, p2, p3, p4])
  
   #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1).setFill()
   path.fill()
  }

  
  let arrowView = UIImageView(image: image)
  arrowView.contentMode = .scaleToFill
  
  backView.addSubview(arrowView)
  
  arrowView.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    arrowView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -13),
    arrowView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 13),
    arrowView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -13),
    arrowView.widthAnchor.constraint(equalTo: arrowView.heightAnchor, multiplier: 1)
   ]
  )
  
  return arrowView
  
 }()

 
}
