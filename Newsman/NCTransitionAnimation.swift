
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




