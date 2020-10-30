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
  if let flag = hostedItem?.priorityFlag, !flag.isEmpty, let color = PhotoPriorityFlags(rawValue: flag)?.color
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
  if let flag = mainView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   UIView.animate(withDuration: 0.85,
                  delay: 0.0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations:
    {[weak self] in
     flag.alpha = 0
     flag.transform = CGAffineTransform(translationX:  (self?.mainView.bounds.width  ?? 0) * 0.20,
                                        y: -(self?.mainView.bounds.height ?? 0) * 0.25)
    },
                  completion: {_ in flag.flagColor = UIColor.clear})
   
   
  }
 }
 
 func clearFlagMarker()
 {
  
  if let flag = mainView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = UIColor.clear
  }
 }
 
 func drawFlagMarker (flagColor: UIColor?)
 {
  guard flagColor != nil else
  {
   clearFlagMarker()
   return
  }
  
  func animateShowFlagMarker (_ flag: FlagMarkerView)
  {
   flag.alpha = 0
   flag.transform = CGAffineTransform(translationX: 0,
                                      y: -mainView.bounds.height * 0.25).scaledBy(x: 1.25, y: 4.25)
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
  
  if let flag = mainView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = flagColor
   animateShowFlagMarker(flag)
   return
  }
  
  let flag = FlagMarkerView(frame: .zero)
  flag.flagColor = flagColor
  flag.tag = 3
  
  
  mainView.addSubview(flag)
  flag.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    flag.widthAnchor.constraint    (equalTo:  mainView.widthAnchor, multiplier: 0.2),
    flag.heightAnchor.constraint   (equalTo:  mainView.heightAnchor, multiplier: 0.25),
    flag.trailingAnchor.constraint (equalTo:  mainView.trailingAnchor),
    flag.topAnchor.constraint      (equalTo:  mainView.topAnchor     )
    
   ]
  )
  
  animateShowFlagMarker(flag)
 }
 
 
 
}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell....
