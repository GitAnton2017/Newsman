//
//  PhotoSnippetCellProtocol.swift
//  Newsman
//
//  Created by Anton2016 on 19.07.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//


import UIKit

protocol PhotoSnippetCellProtocol: class
{
 var isPhotoItemSelected: Bool                          { get set }
 
 var hostedItem: PhotoItemProtocol?                     { get set }
 //the generic model item (folder or photo) that will be displayed by the conformer...
 
 var hostedView: UIView                      {get}
 
 var hostedAccessoryView: UIView?            {get}
 
 var hostedViewSelectedAlpha: CGFloat        {get}
 
 func refresh(with image: UIImage?)
 
 func cancelImageOperations()
 
 var isDragAnimating: Bool                  {get set}
 
 func dragWaggleBegin()
 func dragWaggleEnd()
 
 func drawFlagMarker (flagColor: UIColor)
 func clearFlagMarker()
 func unsetFlagMarker()
 
}

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{
 var cornerRadius: CGFloat
 {
  get {return contentView.layer.cornerRadius    }
  set {contentView.layer.cornerRadius = newValue}
 }
 
 
 func refreshSpring(completion: ((Bool) -> Void)? = nil)
 {
  self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
  
  UIView.animate(withDuration: 0.5, delay: 0,
                 usingSpringWithDamping: 2500,
                 initialSpringVelocity: 0,
                 options: .curveEaseInOut,
                 animations: {self.transform = .identity},
                 completion: completion)
 }
 
 func touchSpring(completion: (() -> Void)? = nil)
 {
  
  //print (#function, self.description)
  let animateDown = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 0.95)
  {
   self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
  }
  
  let animateUp = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 0.95)
  {
   self.transform = .identity
   self.hostedView.alpha = self.isPhotoItemSelected ? self.hostedViewSelectedAlpha : 1
  }
  
  animateUp  .addCompletion {_ in completion?()}
  animateDown.addCompletion {_ in animateUp.startAnimation()}
  animateDown.startAnimation()
 }
 
 
 func clearFlag ()
 {
  if let prevFlagLayer = contentView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   prevFlagLayer.removeFromSuperlayer()
  }
  
 }
 
 func imageRoundClip(cornerRadius: CGFloat)
 {
  contentView.layer.cornerRadius = cornerRadius
  contentView.layer.borderWidth = 1.0
  contentView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
  contentView.layer.masksToBounds = true
 }
 

 func drawFlag (flagColor: UIColor)
 {
  let flagLayer = FlagLayer()
  flagLayer.fillColor = flagColor
  flagLayer.name = "FlagLayer"
  
  let imageSize = bounds.width
  flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
  flagLayer.contentsScale = UIScreen.main.scale
  
  if let prevFlagLayer = contentView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   contentView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
  }
  else
  {
   contentView.layer.addSublayer(flagLayer)
  }
  
  flagLayer.setNeedsDisplay()
 }
 
 

 
}

