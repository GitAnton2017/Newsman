
import UIKit
import GameplayKit

class NCTransitionsDelegate: NSObject, UINavigationControllerDelegate
{
 
 var interactiveController: UIPercentDrivenInteractiveTransition?
 var navigationController: UINavigationController
 var animator: UIViewPropertyAnimator?
 
 init (with nc: UINavigationController)
 {
  self.navigationController = nc
  super.init()
  let panGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
  panGR.edges = .left
  self.navigationController.view.addGestureRecognizer(panGR)
 }
 
 @objc func handlePan(gr: UIScreenEdgePanGestureRecognizer)
 {
  guard let view = self.navigationController.view else {return}
  
  let deltaX = gr.translation(in: view).x
  let progress = abs(deltaX/view.bounds.width)
  
  switch gr.state
  {
   case .began:
    //let location = gr.location(in: view)
    if self.navigationController.viewControllers.count > 1
    {
     self.interactiveController = UIPercentDrivenInteractiveTransition()
     self.navigationController.popViewController(animated: true)
    
     
    }
    break
   case .changed:
     self.interactiveController?.update(progress)
     break
   case .ended:
    if progress < 0.5
    {
     self.interactiveController?.cancel()
    }
    else
    {
     self.interactiveController?.finish()
    }
    self.interactiveController = nil
    break
   default:
    
    self.interactiveController?.cancel()
    self.interactiveController = nil
    break
  }
 }
 
 static let curlUp: NCAnimator.TAnimBlock =
 {ctx, dur in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionCurlUp],
                    animations: {
                                  ctx.containerView.addSubview(ctx.view(forKey: .to)!)
       
                                },
                    completion: {_ in ctx.completeTransition(!ctx.transitionWasCancelled)})
  
 }
 
 static let curlDown: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionCurlDown],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 
 static let crossDis: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionCrossDissolve],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 
 static let flipTop: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionFlipFromTop],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 
 static let flipBottom: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionFlipFromBottom],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 
 static let flipLeft: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionFlipFromLeft],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 
 static let flipRight: NCAnimator.TAnimBlock =
 {ctx, dur  in
  UIView.transition(with: ctx.containerView,
                    duration: dur,
                    options: [.curveEaseOut, .transitionFlipFromRight],
                    animations: {ctx.containerView.addSubview(ctx.view(forKey: .to)!)},
                    completion: {_ in ctx.completeTransition(true)})
 }
 

 static let fadeOut: NCAnimator.TAnimBlock =
 {ctx, dur  in
  let toView = ctx.viewController(forKey: .to)!.view!
  let fromView = ctx.viewController(forKey: .from)!.view!
  ctx.containerView.addSubview(toView)
  ctx.containerView.addSubview(fromView)
  toView.alpha = 0
  fromView.alpha = 1
  let timing = UICubicTimingParameters(animationCurve: .easeInOut)
  let animator = UIViewPropertyAnimator(duration: dur, timingParameters: timing)
  animator.addAnimations
  {
   toView.alpha = 1
   fromView.alpha = 0
  }
  
  animator.addCompletion
  {finish in
   ctx.completeTransition(!ctx.transitionWasCancelled)
   if finish == .end
   {
    
    ctx.finishInteractiveTransition()
   }
   else
   {
    
    ctx.cancelInteractiveTransition()
   }
   
  }
  animator.startAnimation()
 }
 
 
 
 static let animBlocks : [(forPush: NCAnimator.TAnimBlock, forPop: NCAnimator.TAnimBlock)] =
 [
  (forPush: curlDown, forPop: curlUp     ),
  (forPush: crossDis, forPop: crossDis   ),
  (forPush: flipTop,  forPop: flipBottom ),
  (forPush: flipLeft, forPop: flipRight  ),
  
 ]
 
 static let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: animBlocks.count - 1)
 
 func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask
 {
  return .all
 }
 
 func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation
 {
  return .portrait
 }
 
 func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
 {
  
  /*let index = 1//NCTransitionsDelegate.arc4rnd.nextInt()
  let block = NCTransitionsDelegate.animBlocks[index]
  return operation == .push ? NCAnimator(duration: 0.5, animBlock: block.forPush) :
                              NCAnimator(duration: 0.5, animBlock: block.forPop)
  //return animator*/
  return NCСrossDissolveAnimator(with: 0.5, for: operation)
 }
 
 func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
 {
  return interactiveController
 }

}
