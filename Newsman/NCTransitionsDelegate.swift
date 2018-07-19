
import UIKit
import GameplayKit

class NCTransitionsDelegate: NSObject, UINavigationControllerDelegate, UIGestureRecognizerDelegate
{
 
 var isPageMode = false
 var scrollDirection = 0
 var currentSnippet: BaseSnippet!
 private var _prevSnippet: BaseSnippet!
 var interactiveController: UIPercentDrivenInteractiveTransition?
 var navigationController: UINavigationController
 var animator: UIViewPropertyAnimator?
 var touchEdges = UIEdgeInsets(top: 150, left: 50, bottom: 150, right: 0)
 
 init (with nc: UINavigationController)
 {
  
  self.navigationController = nc
  super.init()
  
  let edgePanGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
  edgePanGR.name = "NCTransitionPan"
  self.navigationController.view.addGestureRecognizer(edgePanGR)
  edgePanGR.delegate = self
  
 
 }
 
 func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
 {
  return !(otherGestureRecognizer.view is ZoomView || otherGestureRecognizer.view is VideoScrubView)
 }
 
 @objc func handlePan(gr: UIPanGestureRecognizer)
 {
  guard let view = self.navigationController.view else {return}
 
  let dX = gr.translation(in: view).x
  let dY = gr.translation(in: view).y
  
  //print ("(dx: \(dX), dy: \(dY)")
  
  let progress = abs(isPageMode ? dY/view.bounds.height : dX/view.bounds.width)
  
  switch (gr.state)
  {
  case .began:
   
   let tp = gr.location(in: view)
   
   let count = navigationController.viewControllers.count
   
   if (count > 1 && tp.x < touchEdges.left && tp.y > touchEdges.top && tp.y < view.bounds.height - touchEdges.bottom)
   {
    interactiveController = UIPercentDrivenInteractiveTransition()
    navigationController.popViewController(animated: true)
   }
   
   if (count == 3 && tp.x > touchEdges.left && (tp.y < touchEdges.top || tp.y > view.bounds.height - touchEdges.bottom))
   {
    _prevSnippet = currentSnippet
    scrollDirection = tp.y < touchEdges.top ? 1 : -1
    isPageMode = true
    
    if let snippetsVC = navigationController.viewControllers[count - 2] as? SnippetsViewController,
     let thisIndex = snippetsVC.snippetsDataSource.items.index(where: {$0.id == currentSnippet.id}),
     let nextVC = configueNextVC(for: thisIndex , in: snippetsVC)
    {
     interactiveController = UIPercentDrivenInteractiveTransition()
     navigationController.pushViewController(nextVC, animated: true)
    }
   }
   
  case .changed: interactiveController?.update(progress)
  case .ended:
   if (progress < 0.5)
   {
    if (isPageMode)
    {
     currentSnippet = _prevSnippet
     isPageMode = false
    }
    interactiveController?.cancel()
   }
   else
   {
    if (isPageMode)
    {
     let ind = navigationController.viewControllers.count - 2
     navigationController.viewControllers.remove(at: ind)
     isPageMode = false
    }
    
    interactiveController?.finish()
    
   }
   
   interactiveController = nil
   
  default:
   
   if (isPageMode)
   {
    currentSnippet = _prevSnippet
    isPageMode = false
   }
   interactiveController?.cancel()
   interactiveController = nil
   
  }
 }
 func configueNextVC(for thisIndex: Int, in snippetsVC: SnippetsViewController) -> UIViewController?
 {
  var index = thisIndex + self.scrollDirection
  if (index > snippetsVC.snippetsDataSource.items.count - 1) {index = 0}
  if (index < 0) {index = snippetsVC.snippetsDataSource.items.count - 1}
  
  let nextSnippet = snippetsVC.snippetsDataSource.items[index]
  let snippetType = SnippetType(rawValue: nextSnippet.type!)!
  
  var nextVC: UIViewController?
  
  switch snippetType
  {
  case .text:
   guard let toVC = snippetsVC.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController
    else
   {
    return nil
   }
   let textSnippet = snippetsVC.snippetsDataSource.items[index] as! TextSnippet
   toVC.textSnippet = textSnippet
   currentSnippet = textSnippet
   nextVC = toVC
   
   
  case .photo: fallthrough
   
  case .video:
   guard let toVC = snippetsVC.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController
    else
   {
    return nil
   }
   
   let photoSnippet = snippetsVC.snippetsDataSource.items[index] as! PhotoSnippet
   toVC.photoSnippet = photoSnippet
   currentSnippet = photoSnippet
   nextVC = toVC
   
  
  case .audio: break
  case .sketch: break
  case .report: break
   
  }
  
  
  return nextVC
 }
 
 func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask
 {
  return .all
 }
 
 /*func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation
 {
  return .portrait
 }*/
 
 func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
 {
  return isPageMode ? NCSnippetsScrollAnimator(with: 0.5, for: self.scrollDirection) :
                      NCСrossDissolveAnimator(with: 0.5, for: operation)
 }
 
 func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
 {
  return  interactiveController
 }

}
