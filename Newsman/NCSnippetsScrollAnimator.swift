

import UIKit

class NCSnippetsScrollAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
 
 var animator: UIViewPropertyAnimator?
 var duration: TimeInterval
 var scrollDirection: Int
 
 
 init (with duration: TimeInterval, for scrollDirection: Int)
 {
  self.duration = duration
  self.scrollDirection = scrollDirection
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
  
  let blurEffect = UIBlurEffect(style: .dark)
  let blurToView = UIVisualEffectView(effect: blurEffect)
  let blurFromView = UIVisualEffectView(effect: nil)
  blurToView.frame = toView.bounds
  blurFromView.frame = fromView.bounds
  blurToView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  blurFromView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  toView.addSubview(blurToView)
  fromView.addSubview(blurFromView)
  
  let dir = CGFloat(self.scrollDirection)
  
  toView.transform = CGAffineTransform(translationX: 0,  y: -dir * toView.bounds.height)
  let timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.10, y: 0.5), controlPoint2: CGPoint(x: 0.5, y: 0.5))
  let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
  
  animator.addAnimations
  {
    toView.alpha = 1
    blurToView.effect = nil
    toView.transform = CGAffineTransform.identity
    
    fromView.alpha = 0
    blurFromView.effect = blurEffect
    fromView.transform = CGAffineTransform(translationX: 0,  y: dir * toView.bounds.height)
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
