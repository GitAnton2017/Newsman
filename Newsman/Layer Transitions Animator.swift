
import Foundation
import UIKit

class LayerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CustomTransitionAnimatable, CAAnimationDelegate
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
  //let fromView = transitionContext.view(forKey: .from)!
  
  let toVC = transitionContext.viewController(forKey: .to)!
  //let fromVC = transitionContext.viewController(forKey: .from)!
  
  //let containerFrame = containerView.frame
  //var toViewStartFrame = transitionContext.initialFrame(for: toVC)
  let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
  //var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)
  
  toView.frame = toViewFinalFrame
  
  let trans = CATransition()
  trans.duration = duration
  trans.type = CATransitionType.push
  trans.subtype = CATransitionSubtype.fromRight
  trans.delegate = self
  
  
  containerView.layer.add(trans, forKey: nil)
  containerView.addSubview(toView)
  
 }
 
}

