
import Foundation
import UIKit

class NCAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
 typealias TAnimBlock = (UIViewControllerContextTransitioning, TimeInterval) -> Void
 
 var duration: TimeInterval
 var animBlock: TAnimBlock
 var animator: UIViewPropertyAnimator?
 
 init (duration: TimeInterval, animBlock: @escaping TAnimBlock)
 {
  self.duration = duration
  self.animBlock = animBlock
  super.init()
 }
 
 func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
 {
  return duration
 }
 
 func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
 {
  let animator = interruptibleAnimator(using: transitionContext)
  animator.startAnimation()
 }
 
 func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
 {
  if let animator = self.animator
  {
   return animator
  }
  
  let timing = UICubicTimingParameters(animationCurve: .easeInOut)
  let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
  
  animator.addAnimations
  {
   self.animBlock(transitionContext, self.duration)
  }
  
  animator.addCompletion
   {finish in
 
    if finish == .end
    {
     transitionContext.finishInteractiveTransition()
     transitionContext.completeTransition(true)
    }
    else
    {
     transitionContext.cancelInteractiveTransition()
     transitionContext.completeTransition(false)
    }
    
  }
  
  self.animator = animator
  return animator
 }
 
 func animationEnded(_ transitionCompleted: Bool)
 {
  self.animator = nil
 }
 
}

class NCСrossDissolveAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
 
 var animator: UIViewPropertyAnimator?
 var duration: TimeInterval
 var ncOperation: UINavigationControllerOperation
 
 var direction: CGFloat
 {
  return ncOperation == .push ? -1.0 : 1.0
 }
 
 init (with duration: TimeInterval, for operation: UINavigationControllerOperation)
 {
  self.duration = duration
  ncOperation = operation
 }
 
 func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
 {
  return duration
 }
 
 func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
 {
  let animator = interruptibleAnimator(using: transitionContext)
  animator.startAnimation()
 }
 
 func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
 {
  if let animator = self.animator
  {
   return animator
  }
  
  let toView = transitionContext.view(forKey: .to)!
  let fromView = transitionContext.view(forKey: .from)!
  
  transitionContext.containerView.addSubview(toView)
  transitionContext.containerView.addSubview(fromView)
  
  toView.alpha = 0
  fromView.alpha = 1
  
  fromView.transform = CGAffineTransform.identity
  var transform = CGAffineTransform.identity
  
  let blurEffect = UIBlurEffect(style: .dark)
  let blurToView = UIVisualEffectView(effect: blurEffect)
  let blurFromView = UIVisualEffectView(effect: nil)
  blurToView.frame = toView.bounds
  blurFromView.frame = fromView.bounds
  blurToView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  blurFromView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  toView.addSubview(blurToView)
  fromView.addSubview(blurFromView)
  
  
  transform = transform.concatenating(CGAffineTransform(translationX: -direction * toView.bounds.width, y: 0))
  transform = transform.concatenating(CGAffineTransform(scaleX: 0.75, y: 0.75))
  toView.transform = transform
  let timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.10, y: -0.25), controlPoint2: CGPoint(x: 0.5, y: 0.5))
  let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
  
  animator.addAnimations
  {
   toView.alpha = 1
   blurToView.effect = nil
   toView.transform = CGAffineTransform.identity
   
   fromView.alpha = 0
   blurFromView.effect = blurEffect
   fromView.transform = CGAffineTransform(translationX: self.direction * fromView.bounds.width, y: 0).concatenating(CGAffineTransform(scaleX: 0.75, y: 0.75))
  }
  
  animator.addCompletion
  {finish in
    if finish == .end
    {
     fromView.transform = CGAffineTransform.identity
     transitionContext.finishInteractiveTransition()
     transitionContext.completeTransition(true)
     
    }
    else
    {
     toView.transform = CGAffineTransform.identity
     transitionContext.cancelInteractiveTransition()
     transitionContext.completeTransition(false)
    }
   
   
   blurToView.removeFromSuperview()
   blurFromView.removeFromSuperview()
   
  }
  
  self.animator = animator
  return animator
 }
 
 func animationEnded(_ transitionCompleted: Bool)
 {
  self.animator = nil
 }
 
}

