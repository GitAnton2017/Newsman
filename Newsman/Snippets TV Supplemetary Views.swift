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
 var sectionNumber: Int?
 {
  guard let tv = tableView else {return nil}
  let N = tv.numberOfSections
  return (0..<N).map{($0, tv.headerView(forSection: $0))}.first{$0.1 === self}?.0
 }
 
 weak var tableView: UITableView? {return self.superview as? UITableView}
 
 weak var currentFRC: SnippetsFetchController?
 {
  return (tableView?.dataSource as? SnippetsViewDataSource)?.currentFRC
 }
 
// var section: Int?
 
 lazy var backView: UIView =
 {
  let view = UIView()
  
  view.layer.cornerRadius = 10.0
  contentView.addSubview(view)
  
  view.translatesAutoresizingMaskIntoConstraints = false
  
  let const = [
   view.topAnchor.constraint      (equalTo: contentView.topAnchor,      constant:  3),
   view.trailingAnchor.constraint (equalTo: contentView.trailingAnchor, constant: -1),
   view.leadingAnchor.constraint  (equalTo: contentView.leadingAnchor,  constant:  1),
   view.bottomAnchor.constraint   (equalTo: contentView.bottomAnchor,   constant: -2)
  ]
  const.forEach{$0.priority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)}
  NSLayoutConstraint.activate(const)
  
  return view
  
 }()
 
 lazy var titleLabel: UILabel =
 {
  
  let title = UILabel(frame: CGRect.zero)
  title.lineBreakMode = .byTruncatingMiddle
  title.backgroundColor = UIColor.clear
  title.textAlignment = .left
  title.textColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
  title.font = UIFont.boldSystemFont(ofSize: 18)
  backView.addSubview(title)
  
  title.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    title.topAnchor.constraint    (equalTo: backView.topAnchor                   ),
    title.bottomAnchor.constraint (equalTo: backView.bottomAnchor                ),
    title.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant:  10),
    title.widthAnchor.constraint  (equalTo: backView.widthAnchor,   constant: -60)
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

