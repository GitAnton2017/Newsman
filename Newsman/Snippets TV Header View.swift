
import Foundation
import UIKit

class SnippetsTableViewHeaderView: SnippetsTableViewSupplemenaryView
{
 static let reuseID = "snippetsTableViewHeader"
 
 var isHiddenSection = false
 {
  didSet
  {
   
   titleLabel.font = UIFont.boldSystemFont(ofSize: isHiddenSection ? 22 : 18)
   titleLabel.textColor = titleLabel.textColor.withAlphaComponent(isHiddenSection ? 0.75 : 1.0)
   backView.backgroundColor = backView.backgroundColor?.withAlphaComponent(isHiddenSection ? 0.5 : 1.0)
   
   arrowView.transform = isHiddenSection ? .identity : CGAffineTransform(rotationAngle: .pi/2)
  
   UIView.animate(withDuration: 0.35)
   {[weak self] in
    guard let view = self else {return}
    view.arrowView.transform = view.isHiddenSection ? CGAffineTransform(rotationAngle: .pi/2) : .identity
   }

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
