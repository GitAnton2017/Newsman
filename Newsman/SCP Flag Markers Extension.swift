//
//  SCP Flag Markers Extension.swift
//  Newsman
//
//  Created by Anton2016 on 18/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{
 func refreshFlagMarker()
 {
  if let flag = hostedItem?.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
  {
   drawFlagMarker(flagColor: color)
  }
  else
  {
   clearFlagMarker()
  }
 }
 
 func unsetFlagMarker()
 {
  if let flag = contentView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   UIView.animate(withDuration: 0.85,
                  delay: 0.0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations:
    {[weak self] in
     flag.alpha = 0
     flag.transform = CGAffineTransform(translationX:  (self?.contentView.bounds.width  ?? 0) * 0.20,
                                        y: -(self?.contentView.bounds.height ?? 0) * 0.25)
    },
                  completion: {_ in flag.flagColor = UIColor.clear})
   
   
  }
 }
 
 func clearFlagMarker()
 {
  
  if let flag = contentView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = UIColor.clear
  }
 }
 
 func drawFlagMarker (flagColor: UIColor)
 {
  func animateShowFlagMarker (_ flag: FlagMarkerView)
  {
   flag.alpha = 0
   flag.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.height * 0.25).scaledBy(x: 1.25, y: 4.25)
   UIView.animate(withDuration: 0.5,
                  delay: 0.0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations:
                  {
                   flag.alpha = 1
                   flag.transform = .identity
                  }, completion: nil)
  }
  
  if let flag = contentView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = flagColor
   animateShowFlagMarker(flag)
   return
  }
  
  let flag = FlagMarkerView(frame: .zero)
  flag.flagColor = flagColor
  flag.tag = 3
  
  contentView.addSubview(flag)
  flag.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    flag.widthAnchor.constraint    (equalTo:  contentView.widthAnchor, multiplier: 0.2),
    flag.heightAnchor.constraint   (equalTo:  contentView.heightAnchor, multiplier: 0.25),
    flag.trailingAnchor.constraint (equalTo:  contentView.trailingAnchor),
    flag.topAnchor.constraint      (equalTo:  contentView.topAnchor     )
    
   ]
  )
  
  animateShowFlagMarker(flag)
 }
 
 
 
}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell....
