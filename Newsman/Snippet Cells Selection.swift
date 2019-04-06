//
//  Snippet Cells Selection.swift
//  Newsman
//
//  Created by Anton2016 on 19/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell
{
 var isSnippetRowSelected: Bool
 {
  set
  {
   _selected = newValue
   touchKeySpring
   {
    self.contentView.alpha = newValue ? self.snippetRowSelectedAlpha : 1
    self.backgroundColor = self.backgroundColor?.withAlphaComponent(newValue ? 1 : self.snippetRowSelectedAlpha)
   }
  }
  
  get { return _selected }
 }
 
 
 func touchKeySpringAnimator (completion: (() -> Void)? = nil)
 {
  let spring = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: CGVector(dx: 50, dy: 50))
  let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: spring)
  
  animator.addAnimations
   {
    UIView.animateKeyframes(withDuration: 0, delay: 0, /* zero timing parameters! */
     animations:
     {
      UIView.addKeyframe(withRelativeStartTime: 0,
                         relativeDuration: 0.5,
                         animations:
       { self.contentView.transform = CGAffineTransform(scaleX: 0.97, y: 0.95) })
      
      UIView.addKeyframe(withRelativeStartTime: 0.5,
                         relativeDuration: 0.5,
                         animations: { self.contentView.transform = .identity })
      
    },
     completion: nil)
  }
  
  animator.addCompletion { _ in completion?() }
  
  animator.startAnimation()
 }
 
 func touchKeySpring(completion: (() -> Void)? = nil)
 {
  UIView.animateKeyframes(withDuration: 0.5, delay: 0,  //options: [.calculationModeCubic],
   animations:
   {
    UIView.addKeyframe(withRelativeStartTime: 0,
                       relativeDuration: 0.5,
                       animations:
                       { UIView.animate(withDuration: 0.25, delay: 0,
                                        usingSpringWithDamping: 0.3,
                                        initialSpringVelocity: 10,
                                        options: [.curveLinear],
                                        animations:
                        {
                         self.transform = CGAffineTransform(scaleX: 0.7, y: 0.6)
                       },completion: nil)
                      })
    
    UIView.addKeyframe(withRelativeStartTime: 0.5,
                       relativeDuration: 0.5,
                       animations:
                       {
                        UIView.animate(withDuration: 0.25, delay: 0,
                                       usingSpringWithDamping: 0.3,
                                       initialSpringVelocity: 10,
                                       options: [.curveLinear],
                                       animations: {self.transform = .identity},
                                       completion: nil)
                        
                      })
    
  }, completion: { _ in completion?() })
  
 }
 
 func touchSpringView(completion: (() -> Void)? = nil)
 {
  
  UIView.animate(withDuration: 0.25,
                 delay: 0,
                 usingSpringWithDamping: 0.3,
                 initialSpringVelocity: 1,
                 options: [.curveLinear],
                 animations:
                 {
                  self.transform = CGAffineTransform(scaleX: 0.97, y: 0.95)
                  UIView.animate(withDuration: 0.25,
                                 delay: 0.25,
                                 usingSpringWithDamping: 0.3,
                                 initialSpringVelocity: 1,
                                 options: [.curveLinear],
                                 animations: { self.transform = .identity }, completion: nil)
                 },
                 completion: { _ in completion?() })
  
  
 }
 
 func touchSpringTrans(completion: (() -> Void)? = nil)
 {
  
  let animate = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
  {
   self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
  }
  
  animate.addAnimations({ self.transform = .identity }, delayFactor: 0.5)
  animate.addCompletion { _ in completion?() }
  
  animate.startAnimation()
 }
 
 
 
 func touchShiftTrans(completion: (() -> Void)? = nil)
 {
  
  let animate = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
  {
   self.transform = CGAffineTransform(translationX: -100, y: 0)
  }
  
  animate.addAnimations(
   {
    self.transform = .identity
  }, delayFactor: 0.5)
  
  animate.startAnimation()
 }
 
 func touchShift(completion: (() -> Void)? = nil)
 {
  let xorig = self.center.x
  let animate = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
  {
   self.center.x -= 100
  }
  
  animate.addAnimations(
   {
    self.center.x = xorig
  }, delayFactor: 0.5)
  
  animate.startAnimation()
 }
 
 func touchSpringContent(completion: (() -> Void)? = nil)
 {
  
  let animateDown = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
  {
   self.contentView.transform = self.transform.scaledBy(x: 0.95, y: 0.95)
  }
  
  let animateUp = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
  {
   self.contentView.transform = .identity
   
  }
  
  animateUp  .addCompletion {_ in completion?()}
  animateDown.addCompletion {_ in animateUp.startAnimation()}
  
  animateDown.startAnimation()
 }
 

}
