//
//  SCP Row Position Extension.swift
//  Newsman
//
//  Created by Anton2016 on 01/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{

 func refreshRowPositionMarker(_ animated: Bool = true)
 {
  //(mainView as? PhotoSnippetCellMainView)?.rowPositionTag.cardinal = hostedItem?.rowPosition
  
//  guard let mainView = mainView as? PhotoSnippetCellMainView else { return }
//  guard let hosted = hostedItem else { return }
//  guard hosted.photoManagedObject.isDeleted == false else { return }
//  guard hosted.photoManagedObject.managedObjectContext != nil else { return }
//  guard hosted.photoManagedObject.photoSnippet != nil else { return }
//  guard let groupType = photoSnippet?.photoGroupType else { return }
//
//  mainView.rowPositionTag.cardinal = groupType.isRowPositioned ? hosted.rowPosition : nil
 
  
//  switch hostedItem?.photoGroupType
//  {
//   case let groupType? where groupType.isRowPositioned: rowPosView.cardinal = hostedItem?.rowPosition
//    //showRowPosition(textColor: UIColor.white, rowPosition: hostedItem!.rowPosition, animated: animated )
//   default:
//    rowPosView.cardinal
//    //clearRowPosition(animated)
//  }
//
  
 }
 
 func clearRowPosition(_ animated: Bool)
 {
  
//  guard let mainView = mainView as? PhotoSnippetCellMainView else { return }
//  mainView.rowPositionTag.cardinal = nil
//  
//  let shiftX = -mainView.rowPositionTag.bounds.width * 2
//  
//  mainView.$rowPositionTag = .constraint(anchor: .centerX(shiftX, nil, 0.22))
//  mainView.layoutIfNeeded()
  
//  guard let pos = mainView.subviews.first(where:{ $0.tag == 4 }) else { return }
//
//  guard animated else
//  {
//   pos.removeFromSuperview()
//   return
//  }
//
//  UIView.animate(withDuration: 0.25, delay: 0.0,
//                 usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
//                 options: [.curveEaseInOut],
//                 animations:
//                 {
//                  pos.transform = CGAffineTransform(translationX: 0, y: pos.bounds.height * 2)
//                 },
//                 completion: {_ in pos.removeFromSuperview() })
 }
 
// func showRowPosition(textColor: UIColor, rowPosition: Int, animated: Bool = true)
// {
//  func animateShowRowPosition (_ pos: DigitalTag)
//  {
//   pos.alpha = 0
//   pos.transform = CGAffineTransform(translationX: mainView.bounds.width, y: 0)
//   UIView.animate(withDuration: 0.15, delay: 0.0,
//                  usingSpringWithDamping: 0.8,
//                  initialSpringVelocity: 20,
//                  options: [.curveEaseInOut],
//                  animations: {pos.alpha = 1; pos.transform = .identity},
//                  completion: {_ in  pos.cardinal = rowPosition })
//  }
//  
//  
//  clearRowPosition(false)
//  
//  let cr = mainView.layer.cornerRadius * 0.45
//  let pos = DigitalTag(textColor: textColor, cornerRadius: cr)
//  
//  pos.tag = 4
//  
//  mainView.addSubview(pos)
//  
//  let margin = 1 + (mainView.bounds.width * 0.02).rounded(.up)
//  
//  
//  pos.translatesAutoresizingMaskIntoConstraints = false
//  
//  NSLayoutConstraint.activate(
//  [
//    pos.bottomAnchor.constraint   (equalTo:  mainView.bottomAnchor,   constant:  -margin),
//    pos.leadingAnchor.constraint  (equalTo:  mainView.leadingAnchor,  constant:   margin),
//    pos.widthAnchor.constraint    (equalTo:  mainView.widthAnchor,    multiplier: 0.14),
//    pos.heightAnchor.constraint   (equalTo:  pos.widthAnchor,         multiplier: 1)
//   
//  ])
//  
//  guard animated else { pos.cardinal = rowPosition; return }
//  
//  animateShowRowPosition(pos)
// }

 
}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell...


