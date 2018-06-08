
import UIKit

extension AppDelegate: UINavigationControllerDelegate
{
 func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask
 {
  return .all
 }
 
 func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation
 {
  return .portrait
 }
 
 /*func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
 {
  return operation == .push ? NCPushAnimator(duration: 0.5) : NCPopAnimator(duration: 0.5)
 }*/

}

extension AppDelegate: UIViewControllerAnimatedTransitioning
{
 func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
 {
  return 0.5
 }
 
 func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
 {
  //let anim = interruptibleAnimator(using: transitionContext)
  //anim.startAnimation()
  
  let toView = transitionContext.view(forKey: .to)!
  let fromView = transitionContext.view(forKey: .from)!
  UIView.transition(with: transitionContext.containerView,
                    duration: 0.5,
                    options: [.curveEaseOut, .transitionCurlDown],
                    animations: {
                                 fromView.removeFromSuperview()
                                 transitionContext.containerView.addSubview(toView)
                     
                                },
                    completion: {_ in transitionContext.completeTransition(true)})
 }
 
 /*func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
 {
  if self.anim != nil {return self.anim!}
  
 }*/
 
 /*func animationEnded(_ transitionCompleted: Bool)
 {
  anim = nil
 }*/
 
}
