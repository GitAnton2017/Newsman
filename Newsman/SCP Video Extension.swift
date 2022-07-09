//
//  SCP Video Extension.swift
//  Newsman
//
//  Created by Anton2016 on 18/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension PhotoSnippetCellProtocol 
{
 
 func refreshVideoMarkers()
 {
  guard let hosted = hostedItem as? PhotoItem else { return }
  guard let videoURL = hosted.url else { return }
  
  if (hosted.type == .video)
  {
   showPlayIcon(iconColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.65))
   showVideoDuration(textColor: UIColor.red, duration: AVURLAsset(url: videoURL).duration)
  }
 }
 
 
 func drawVideoDuration (textColor: UIColor, duration: CMTime)
 {
  let HH = Int(duration.seconds/3600)
  let MM = Int((duration.seconds - Double(HH) * 3600) / 60)
  let SS = Int(duration.seconds - Double(HH) * 3600 - Double(MM) * 60)
  
  let timeText = (HH > 0 ? "\(HH < 10 ? "0" : "")\(HH):" : "\u{20}\u{20}\u{20}") +
   (HH > 0 || MM > 0 ? "\(MM < 10 ? "0" : "")\(MM):" : "\u{20}\u{20}:") +
  "\(SS < 10 ? "0" : "")\(SS)"
  
  if let time = contentView.subviews.first(where: {$0.tag == 1}) as? UILabel
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
  
  contentView.addSubview(time)
  time.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    time.bottomAnchor.constraint       (equalTo:  contentView.bottomAnchor,   constant:  -5),
    time.trailingAnchor.constraint     (equalTo:  contentView.trailingAnchor, constant: -5),
    time.widthAnchor.constraint        (equalTo:  contentView.widthAnchor,    multiplier: 0.4),
    time.firstBaselineAnchor.constraint(equalTo:  time.bottomAnchor, constant: 5)
    
   ]
  )
 }
 
 func clearVideoDuration()
 {
  if let time = contentView.subviews.first(where: {$0.tag == 1}) as? TimeStampView
  {
   time.duration = CMTime.zero
  }
 }
 
 func showVideoDuration (textColor: UIColor, duration: CMTime)
 {
  func animateShowDuration (_ time: TimeStampView)
  {
   time.alpha = 0
   time.transform = CGAffineTransform(translationX: -contentView.bounds.width, y: 0)
   UIView.animate(withDuration: 0.2,
                  delay: 0.0,
                  usingSpringWithDamping: 10,
                  initialSpringVelocity: 50,
                  options: [.curveEaseInOut],
                  animations: {time.alpha = 1; time.transform = .identity},
                  completion: nil)
  }
  
  if let time = contentView.subviews.first(where: {$0.tag == 1}) as? TimeStampView
  {
   time.duration = CMTime.zero
   time.duration = duration
   animateShowDuration(time)
   return
  }
  
  let time = TimeStampView()
  time.tag = 1
  
  time.textColor = textColor
  time.duration = duration
  contentView.addSubview(time)
  time.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    time.bottomAnchor.constraint   (equalTo:  contentView.bottomAnchor,   constant:  -5),
    time.trailingAnchor.constraint (equalTo:  contentView.trailingAnchor, constant: -5),
    time.widthAnchor.constraint    (equalTo:  contentView.widthAnchor,    multiplier: 0.67),
    time.heightAnchor.constraint   (equalTo:  contentView.widthAnchor,    multiplier: 0.125)
   ]
  )
  
  animateShowDuration(time)
 }
 
 func hidePlayIcon()
 {
  if let playIcon = contentView.subviews.first(where: {$0.tag == 2}) as? PlayIconView
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
  
  if let playIcon = contentView.subviews.first(where: {$0.tag == 2}) as? PlayIconView
  {
   animateShowPlayIcon(playIcon)
   return
   
  }
  
  let playIcon = PlayIconView(iconColor: iconColor, r: r, shift: shift, width: width)
  playIcon.tag = 2
  playIcon.isUserInteractionEnabled = true
  contentView.addSubview(playIcon)
  playIcon.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    playIcon.bottomAnchor.constraint   (equalTo:  contentView.bottomAnchor  ),
    playIcon.trailingAnchor.constraint (equalTo:  contentView.trailingAnchor),
    playIcon.topAnchor.constraint      (equalTo:  contentView.topAnchor     ),
    playIcon.leadingAnchor.constraint  (equalTo:  contentView.leadingAnchor )
    
   ]
  )
  
  animateShowPlayIcon(playIcon)
 }
 
 
 
}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell...
