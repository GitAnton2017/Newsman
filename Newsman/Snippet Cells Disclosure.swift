//
//  Snippet Cells Disclosure.swift
//  Newsman
//
//  Created by Anton2016 on 27/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell
{
 
 struct Normal
 {
  static let bottom: CGFloat = 10
  static let nameFont = UIFont.systemFont(ofSize: 17)
  static let dateFont = UIFont.systemFont(ofSize: 15)
  static let shift: CGFloat = 30
  static let locationAT = CGAffineTransform(translationX: 0, y: shift)
 }
 
 struct Disclosed
 {
  static let bottom: CGFloat = 30
  static let nameFont = UIFont.boldSystemFont(ofSize: 20)
  static let dateFont = UIFont.boldSystemFont(ofSize: 18)
 }
 
 
 final func getDisclosureImage(of color: UIColor, and size: CGSize) -> UIImage
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
 
 
 final func animateFontSize(disclosure: Bool)
 {
  UIView.transition(with: snippetTextTag, duration: 0.25,
                    options: [.transitionFlipFromTop, .allowAnimatedContent, .curveEaseInOut],
                    animations:
                    { [weak self] in
                     self?.snippetTextTag.font = disclosure ? Disclosed.nameFont : Normal.nameFont
                    }, completion: nil)
  
  UIView.transition(with: snippetDateTag, duration: 0.25,
                    options: [.transitionFlipFromBottom, .allowAnimatedContent, .curveEaseInOut],
                    animations:
                    { [weak self] in
                     self?.snippetDateTag.font = disclosure ? Disclosed.dateFont : Normal.dateFont
                    }, completion: nil)
  
 }
 
 
 
 final func animateLocation(disclosure: Bool, comletion: ( () -> () )? = nil)
 {
  
  UIView.animate(withDuration: 0.25, delay: 0,
                 usingSpringWithDamping: 0.75,
                 initialSpringVelocity: 10, options: [.curveEaseIn],
                 animations:
                 {[weak self] in self?.locationLabel.transform = disclosure ? .identity : Normal.locationAT },
                  completion:
                 {_ in comletion?() })
 }
 
 
 private func animateRowDisclosure(completion: ( () -> () )? = nil)
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
 
 private func animateRowClosure(completion: ( () -> () )? = nil)
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
 
 private func refreshRowHeight(with state: Bool, completion: ( () -> () )? = nil)
 {
  switch state
  {
   case true:  animateRowDisclosure() {completion?()}
   case false: animateRowClosure()    {completion?()}
  }
 }
 
 
 
 final func toggleCellDisclosure(with snippet: BaseSnippet, completion: ( () -> () )? = nil)
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
 
 
 
 @objc final func disclosurePressed(_ sender: UIButton)
 {
  
  guard let snippet = snippet else {return}
  
  discloseView?.transform = snippet.disclosedCell ? .rotate90p: .identity
  
  sender.isUserInteractionEnabled = false
  UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                 initialSpringVelocity: 10, options: [.curveEaseOut],
                 animations:
                 { [weak self] in
                  guard let cell = self else {return}
                  cell.discloseView?.transform = snippet.disclosedCell ? .identity : .rotate90p
                 },
                 completion: nil)
  
  toggleCellDisclosure(with: snippet) { sender.isUserInteractionEnabled = true }
 }
 
 
 
 final func configueDisclosure()
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

}
