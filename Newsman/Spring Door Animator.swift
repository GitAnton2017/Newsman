

import Foundation
import UIKit


class SpringDoorAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimatable, CAAnimationDelegate
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
  animGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0, 1.3, 0.9, 0.75)
  
  var perspective = CATransform3DIdentity
  perspective.m34 = 1/1000
  
  
  containerView.layer.sublayerTransform = perspective
  
  let fadeAnim = CABasicAnimation(keyPath: "opacity")
  fadeAnim.fromValue = presenting ? 0.0 : 1.0
  fadeAnim.toValue   = presenting ? 1.0 : 0.0
  
  let rotateAnim = CABasicAnimation(keyPath: "transform")
  
  rotateAnim.fromValue = presenting ? CATransform3DMakeRotation( .pi/1.5 , 1, 0, 0) : CATransform3DIdentity
  rotateAnim.toValue   = presenting ? CATransform3DIdentity : CATransform3DMakeRotation(.pi/1.5, 1, 0, 0)
  
  //rotateAnim.duration = rotateAnim.settlingDuration
  //rotateAnim.stiffness = 100000
  //rotateAnim.mass = 1000
  //rotateAnim.initialVelocity = 1
  //rotateAnim.damping = 10000
  
  animGroup.animations =  [fadeAnim, rotateAnim]
  animGroup.duration = duration
  
  animGroup.fillMode = kCAFillModeForwards
  animGroup.isRemovedOnCompletion = false
  
  containerView.addSubview(toView)
  
  
  if (presenting)
  {
   
   toView.layer.position = CGPoint(x: toView.layer.position.x , y: toView.layer.position.y - toView.layer.bounds.height/2)
   toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
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
    fromView.layer.position = CGPoint(x: fromView.layer.position.x , y: fromView.layer.position.y + fromView.layer.bounds.height/2)
    fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
   }
  }
 }
 
}
