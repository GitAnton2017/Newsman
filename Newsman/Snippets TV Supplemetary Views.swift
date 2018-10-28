import Foundation
import UIKit

extension UIBezierPath
{
 convenience init(points: [CGPoint])
 {
  self.init()
  guard let p0 = points.first else {return}
  move(to: p0)
  points.dropFirst().forEach{addLine(to: $0)}
  close()
 }
}

class SnippetsTableViewSupplemenaryView: UITableViewHeaderFooterView
{
 var section = 0
 
 lazy var backView: UIView =
 {
  let view = UIView()
  view.translatesAutoresizingMaskIntoConstraints = false
  view.layer.cornerRadius = 10.0
  contentView.addSubview(view)
  NSLayoutConstraint.activate(
   [
    view.topAnchor.constraint  (equalTo:  contentView.topAnchor, constant: 3),
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
   ])
  
  return view
  
 }()
 
 lazy var titleLabel: UILabel =
 {
  
  let title = UILabel(frame: CGRect.zero)
  title.backgroundColor = UIColor.clear
  title.textAlignment = .left
  title.textColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
  title.font = UIFont.boldSystemFont(ofSize: 18)
  backView.addSubview(title)
  
  title.translatesAutoresizingMaskIntoConstraints = false
  
  NSLayoutConstraint.activate(
   [
    title.topAnchor.constraint  (equalTo:  backView.topAnchor),
    title.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
    title.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
   ]
  )
  
  return title
 }()
 
 
 var title: String?
 {
  get {return titleLabel.text}
  set {titleLabel.text = newValue}
 }
 
 var titleColor: UIColor?
 {
  get {return backView.backgroundColor}
  set {backView.backgroundColor = newValue}
 }
 
}

