//
//  Animation Helpers.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

protocol AnimationOptionsRepresentable
{
 var duration: TimeInterval           { get }
 var delay: TimeInterval              { get }
 var options: UIView.AnimationOptions { get }
 
 func animate( block: @escaping () -> (), completion:  ((Bool) -> ())?)
}

extension AnimationOptionsRepresentable
{
 static func withSmallJump(_ duration: TimeInterval) -> SpringAnimationOptions
 {
  SpringAnimationOptions(duration, 0, 0.9, 10, [.curveEaseInOut])
 }
 
 static func withAverageJump(_ duration: TimeInterval) -> SpringAnimationOptions
 {
  SpringAnimationOptions(duration, 0, 0.8, 20, [.curveEaseInOut])
 }
 
 static func withLargeJump(_ duration: TimeInterval) -> SpringAnimationOptions
 {
  SpringAnimationOptions(duration, 0, 0.7, 50, [.curveEaseInOut])
 }
}

struct BatchAnimationOptions: AnimationOptionsRepresentable
{
 func animate(block: @escaping () -> (), completion: ((Bool) -> ())? = nil)
 {
  UIView.animate(withDuration: duration,
                 delay: delay,
                 options: options,
                 animations: block,
                 completion: completion)
 }
 
 
 let duration: TimeInterval
 let delay: TimeInterval
 let options: UIView.AnimationOptions
 
 init (_ duration: TimeInterval,
       _ delay: TimeInterval = 0.0,
       _ options: UIView.AnimationOptions = [])
 {
  self.duration = duration
  self.delay = delay
  self.options = options
 }
}

struct SpringAnimationOptions: AnimationOptionsRepresentable
{
 func animate(block: @escaping () -> (), completion: ((Bool) -> ())? = nil )
 {
  UIView.animate(withDuration: duration,
                 delay: delay,
                 usingSpringWithDamping: dumping,
                 initialSpringVelocity: velocity,
                 options: options,
                 animations: block,
                 completion: completion)
 }
 
 let duration: TimeInterval
 let delay: TimeInterval
 let dumping: CGFloat
 let velocity: CGFloat
 let options: UIView.AnimationOptions
 
 init (_ duration: TimeInterval,
       _ delay: TimeInterval = 0.0,
       _ dumping: CGFloat = 0.0,
       _ velocity: CGFloat = 0.0,
       _ options: UIView.AnimationOptions = [])
 {
  self.duration = duration
  self.delay = delay
  self.dumping = dumping
  self.velocity = velocity
  self.options = options
 }
 
 
}
extension UICollectionView
{
 func performAnimatedBatchUpdates(_ options: AnimationOptionsRepresentable,
                                  _ block: (() -> ())? = nil ,
                                  _ completion: ((Bool) -> ())? = nil)
 {
  options.animate(block:
                  {[weak self] in
                   self?.performBatchUpdates(block, completion: completion)
                  }, completion: nil)

 }
 
 func performUnanimatedBatchUpdates(_ block: (() -> ())? = nil, _ completion: ((Bool) -> ())? = nil)
 {
  UIView.performWithoutAnimation {[weak self] in
   self?.performBatchUpdates(block, completion: completion)
  }
 }
}

extension UITableView
{
 func performAnimatedBatchUpdates(_ options: AnimationOptionsRepresentable,
                                  _ block: (() -> ())? = nil ,
                                  _ completion: ((Bool) -> ())? = nil)
 {
  options.animate(block:
                  {[weak self] in
                   self?.performBatchUpdates(block, completion: completion)
                  }, completion: nil)

 }
 
 func performUnanimatedBatchUpdates(_ block: (() -> ())? = nil, _ completion: ((Bool) -> ())? = nil)
 {
  UIView.performWithoutAnimation {[weak self] in
   self?.performBatchUpdates(block, completion: completion)
  }
 }
}
