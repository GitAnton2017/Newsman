
import Foundation
import UIKit

class CornerSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimatable
{
 var duration: TimeInterval
 var presenting = true
 var animator: UIViewPropertyAnimator?
 var originFrame: CGRect = .zero
 
 init (with duration: TimeInterval)
 {
  self.duration = duration
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
  
  let containerView = transitionContext.containerView
  
  let toView = transitionContext.view(forKey: .to)!
  let fromView = transitionContext.view(forKey: .from)!
  
  let toVC = transitionContext.viewController(forKey: .to)!
  let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
  
  toView.transform = .identity
  toView.frame = toViewFinalFrame
  
  containerView.addSubview(toView)
  
  if (presenting)
  {
   toView.transform = CGAffineTransform(translationX: containerView.bounds.width, y: containerView.bounds.height)
  }
  else
  {
   fromView.transform = .identity
   containerView.bringSubview(toFront: fromView)
  }
  
  let animator = UIViewPropertyAnimator(duration: duration, curve: .linear)
  
  animator.addAnimations
  {
    if (self.presenting)
    {
     toView.transform = .identity
    }
    else
    {
     fromView.transform = CGAffineTransform(translationX: containerView.bounds.width, y: containerView.bounds.height)
    }
  }
  
  animator.addCompletion
  {finish in
    
    let success = !transitionContext.transitionWasCancelled
    if ((self.presenting && !success) || (!self.presenting && success))
    {
     toView.removeFromSuperview()
    }
    transitionContext.completeTransition(success)
    
    
  }
  
  self.animator = animator
  return animator
 }
 
 func animationEnded(_ transitionCompleted: Bool)
 {
  self.animator = nil
 }
 
}
