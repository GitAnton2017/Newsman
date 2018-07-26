//
//  PhotoSnippetCellProtocol.swift
//  Newsman
//
//  Created by Anton2016 on 19.07.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


protocol PhotoSnippetCellProtocol: AnyObject
{
 var photoItemView: UIView     {get    }
 var cellFrame: CGRect         {get    }
 var isPhotoItemSelected: Bool {get set}
}

extension PhotoSnippetCellProtocol
{
 var cornerRadius: CGFloat
 {
  get {return photoItemView.layer.cornerRadius}
  set
  {
   photoItemView.layer.cornerRadius = newValue
  }
 }
 
 
 
 func clearFlag ()
 {
  if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   prevFlagLayer.removeFromSuperlayer()
  }
  
 }
 
 func imageRoundClip(cornerRadius: CGFloat)
 {
  photoItemView.layer.cornerRadius = cornerRadius
  photoItemView.layer.borderWidth = 1.0
  photoItemView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
  photoItemView.layer.masksToBounds = true
 }
 
 func unsetFlagMarker()
 {
  if let flag = photoItemView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   UIView.animate(withDuration: 0.85,
                  delay: 0.0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations:
                  {[weak self] in
                   flag.alpha = 0
                   flag.transform = CGAffineTransform(translationX:  (self?.photoItemView.bounds.width  ?? 0) * 0.20,
                                                                 y: -(self?.photoItemView.bounds.height ?? 0) * 0.25)
                  },
                  completion: {_ in flag.flagColor = UIColor.clear})
   
   
  }
 }
 
 func clearFlagMarker()
 {

  if let flag = photoItemView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = UIColor.clear
  }
 }
 
 func drawFlagMarker (flagColor: UIColor)
 {
  func animateShowFlagMarker (_ flag: FlagMarkerView)
  {
   flag.alpha = 0
   flag.transform = CGAffineTransform(translationX: 0, y: -photoItemView.bounds.height * 0.25).scaledBy(x: 1.25, y: 4.25)
   UIView.animate(withDuration: 0.5,
                  delay: 0.0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations: {flag.alpha = 1; flag.transform = .identity},
                  completion: nil)
  }
  
  if let flag = photoItemView.subviews.first(where: {$0.tag == 3}) as? FlagMarkerView
  {
   flag.flagColor = flagColor
   animateShowFlagMarker(flag)
   return
  }
  
  let flag = FlagMarkerView(frame: .zero)
  flag.flagColor = flagColor
  flag.tag = 3
  
  photoItemView.addSubview(flag)
  flag.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    flag.widthAnchor.constraint    (equalTo:  self.photoItemView.widthAnchor, multiplier: 0.2),
    flag.heightAnchor.constraint   (equalTo:  self.photoItemView.heightAnchor, multiplier: 0.25),
    flag.trailingAnchor.constraint (equalTo:  self.photoItemView.trailingAnchor),
    flag.topAnchor.constraint      (equalTo:  self.photoItemView.topAnchor     )
    
   ]
  )
  
  animateShowFlagMarker(flag)
 }
 
 func drawFlag (flagColor: UIColor)
 {
  let flagLayer = FlagLayer()
  flagLayer.fillColor = flagColor
  flagLayer.name = "FlagLayer"
  
  let imageSize = cellFrame.width
  flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
  flagLayer.contentsScale = UIScreen.main.scale
  
  if let prevFlagLayer = photoItemView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   photoItemView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
  }
  else
  {
   photoItemView.layer.addSublayer(flagLayer)
  }
  
  flagLayer.setNeedsDisplay()
 }
 
 
 func drawVideoDuration (textColor: UIColor, duration: CMTime)
 {
  let HH = Int(duration.seconds/3600)
  let MM = Int((duration.seconds - Double(HH) * 3600) / 60)
  let SS = Int(duration.seconds - Double(HH) * 3600 - Double(MM) * 60)
  
  let timeText = (HH > 0 ? "\(HH < 10 ? "0" : "")\(HH):" : "\u{20}\u{20}\u{20}") +
   (HH > 0 || MM > 0 ? "\(MM < 10 ? "0" : "")\(MM):" : "\u{20}\u{20}:") +
  "\(SS < 10 ? "0" : "")\(SS)"
  
  if let time = photoItemView.subviews.first(where: {$0.tag == 1}) as? UILabel
  {
   time.text = timeText
   return
  }
  
  let time = UILabel(frame: CGRect.zero)
  time.tag = 1
  time.font = UIFont.systemFont(ofSize: 25)
  time.adjustsFontForContentSizeCategory = true
  //time.minimumScaleFactor = 0.01
  time.numberOfLines = 1
  time.baselineAdjustment = .alignBaselines
  
  time.text = timeText
  
  time.backgroundColor = UIColor.clear
  time.textAlignment = .right
  time.adjustsFontSizeToFitWidth = true
  time.textColor = textColor
  
  photoItemView.addSubview(time)
  time.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    time.bottomAnchor.constraint  (equalTo:  photoItemView.bottomAnchor,  constant:  -5),
    time.trailingAnchor.constraint (equalTo:  photoItemView.trailingAnchor, constant: -5),
    time.widthAnchor.constraint(equalTo: photoItemView.widthAnchor, multiplier: 0.4),
    time.firstBaselineAnchor.constraint(equalTo: time.bottomAnchor, constant: 5)
    
   ]
  )
 }
 
 func clearVideoDuration()
 {
  if let time = photoItemView.subviews.first(where: {$0.tag == 1}) as? TimeStampView
  {
   time.duration = kCMTimeZero
  }
 }
 
 func showVideoDuration (textColor: UIColor, duration: CMTime)
 {
  func animateShowDuration (_ time: TimeStampView)
  {
   time.alpha = 0
   time.transform = CGAffineTransform(translationX: -photoItemView.bounds.width, y: 0)
   UIView.animate(withDuration: 0.2,
                  delay: 0.0,
                  usingSpringWithDamping: 10,
                  initialSpringVelocity: 50,
                  options: [.curveEaseInOut],
                  animations: {time.alpha = 1; time.transform = .identity},
                  completion: nil)
  }
  
  if let time = photoItemView.subviews.first(where: {$0.tag == 1}) as? TimeStampView
  {
   time.duration = kCMTimeZero
   time.duration = duration
   animateShowDuration(time)
   return
  }
  
  let time = TimeStampView()
  time.tag = 1
  
  time.textColor = textColor
  time.duration = duration
  photoItemView.addSubview(time)
  time.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    time.bottomAnchor.constraint  (equalTo:  photoItemView.bottomAnchor,  constant:  -5),
    time.trailingAnchor.constraint (equalTo:  photoItemView.trailingAnchor, constant: -5),
    time.widthAnchor.constraint(equalTo: photoItemView.widthAnchor, multiplier: 0.67),
    time.heightAnchor.constraint(equalTo: photoItemView.widthAnchor, multiplier: 0.125)
   ]
  )
  
  animateShowDuration(time)
 }
 
 func hidePlayIcon()
 {
  if let playIcon = photoItemView.subviews.first(where: {$0.tag == 2}) as? PlayIconView
  {
   playIcon.alpha = 0
  }
 }
 
 func showPlayIcon (iconColor: UIColor, r: CGFloat = 0.3, shift: CGFloat = 0.07, width: CGFloat = 0.03)
 {
  func animateShowPlayIcon (_ playIcon: PlayIconView)
  {
   playIcon.alpha = 0
   playIcon.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).rotated(by: .pi)
   UIView.animate(withDuration: 0.35,
                  delay: 0.15,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut],
                  animations: {playIcon.alpha = 1; playIcon.transform = .identity},
                  completion: nil)
  }
  
  if let playIcon = photoItemView.subviews.first(where: {$0.tag == 2}) as? PlayIconView
  {
   animateShowPlayIcon(playIcon)
   return
   
  }
  
  let playIcon = PlayIconView(iconColor: iconColor, r: r, shift: shift, width: width)
  playIcon.tag = 2
  playIcon.isUserInteractionEnabled = true
  photoItemView.addSubview(playIcon)
  playIcon.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    playIcon.bottomAnchor.constraint   (equalTo:  photoItemView.bottomAnchor  ),
    playIcon.trailingAnchor.constraint (equalTo:  photoItemView.trailingAnchor),
    playIcon.topAnchor.constraint      (equalTo:  photoItemView.topAnchor     ),
    playIcon.leadingAnchor.constraint  (equalTo:  photoItemView.leadingAnchor )
    
   ]
  )
  
  animateShowPlayIcon(playIcon)
 }
 
}

