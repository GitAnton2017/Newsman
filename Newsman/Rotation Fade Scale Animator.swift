

import Foundation
import UIKit


class RotationFadeScaleAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimatable, CAAnimationDelegate
{
 var duration: TimeInterval
 var presenting = true
 var context: UIViewControllerContextTransitioning?
 
 init (with duration: TimeInterval)
 {
  self.duration = duration
 }
 
 func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
 {
  if let context = context
  {
   let success = !context.transitionWasCancelled
   let toView = context.view(forKey: .to)!
   if ((self.presenting && !success) || (!self.presenting && success))
   {
    toView.removeFromSuperview()
   }
   context.completeTransition(success)
  }
  
  context = nil
 }
 
 func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
 {
  return duration
 }
 
 func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
 {
  context = transitionContext
  
  let containerView = transitionContext.containerView
  
  let toView = transitionContext.view(forKey: .to)!
  let fromView = transitionContext.view(forKey: .from)!
  
  let toVC = transitionContext.viewController(forKey: .to)!
  let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
  
  toView.frame = toViewFinalFrame
  
  let animGroup = CAAnimationGroup()
  animGroup.delegate = self
  animGroup.duration = duration
  
  var perspective = CATransform3DIdentity
  perspective.m34 = -1/100
  
  containerView.layer.sublayerTransform = perspective
  
  let fadeAnim = CABasicAnimation(keyPath: "opacity")
  fadeAnim.fromValue = presenting ? 0.5 : 1.0
  fadeAnim.toValue   = presenting ? 1.0 : 0.5
  
  let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
  scaleAnim.fromValue = presenting ? 0.0 : 1.0
  scaleAnim.toValue   = presenting ? 1.0 : 0.0
  
  let rotateAnimX = CABasicAnimation(keyPath: "transform.rotation.x")
  let NTurnes: CGFloat = 3
  rotateAnimX.fromValue = 0
  rotateAnimX.toValue   = NTurnes * (presenting ? 2 * CGFloat.pi  : -2 * CGFloat.pi)
  
  let rotateAnimY = CABasicAnimation(keyPath: "transform.rotation.y")
  rotateAnimY.fromValue = 0
  rotateAnimY.toValue   = presenting ? 2 * CGFloat.pi : -2 * CGFloat.pi
  
  animGroup.animations = [scaleAnim, rotateAnimX, fadeAnim]
  animGroup.fillMode = kCAFillModeForwards
  animGroup.isRemovedOnCompletion = false
  
  containerView.addSubview(toView)
  
  if (presenting)
  {
   toView.layer.add(animGroup, forKey: "animGroup")
  }
  else
  {
   containerView.bringSubview(toFront: fromView)
   fromView.layer.add(animGroup, forKey: "animGroup")
   
  }
  
 }
 
 func animationEnded(_ transitionCompleted: Bool)
 {
  if let context = context
  {
   if presenting
   {
    let toView = context.view(forKey: .to)!
    toView.layer.removeAnimation(forKey: "animGroup")
   }
   else
   {
    let fromView = context.view(forKey: .from)!
    fromView.layer.removeAnimation(forKey: "animGroup")
   }
  }
 }
 
}
