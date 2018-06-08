
import UIKit

protocol CustomTransitionAnimatable
{
 var presenting: Bool {get set}
}

class VCTransitionsDelegate: NSObject, UIViewControllerTransitioningDelegate
{
 var transition: CustomTransitionAnimatable
 
 init (animator: CustomTransitionAnimatable)
 {
  transition = animator
  super.init()
  
 }
 
 func animationController(forPresented presented: UIViewController,
                          presenting: UIViewController,
                          source: UIViewController) -> UIViewControllerAnimatedTransitioning?
 {
   transition.presenting = true
   return transition as? UIViewControllerAnimatedTransitioning
 }
 
 
 func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
 {
   transition.presenting = false
   return transition as? UIViewControllerAnimatedTransitioning
 }
}
