
import Foundation
import UIKit

protocol NCSnippetsScrollProtocol: SnippetsBaseRepresentable
{
 var currentViewController: UIViewController { get }
 
 func itemUpBarButtonPress(_ sender: UIBarButtonItem)
 func itemDownBarButtonPress(_ sender: UIBarButtonItem)
}


extension NCSnippetsScrollProtocol
{
 func moveToNextSnippet (in direction: Int)
 {
  if let nc = currentViewController.navigationController,
     let snippetsVC = nc.children[nc.children.count - 2] as? SnippetsViewController,
     let items = snippetsVC.snippetsDataSource.items,
     let thisIndex = items.firstIndex(where: {$0.id == currentSnippet.id})
  {
   var index = thisIndex + direction
   if (index > items.count - 1) { index = 0 }
   if (index < 0) { index = items.count - 1 }
   
   let nextSnippet = items[index]
   let snippetType = SnippetType(rawValue: nextSnippet.type!)!
   
   var nextVC: UIViewController?
   
   switch snippetType
   {
    case .text:
     guard let toVC = currentViewController.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController
      else
     {
      return
     }
     nextVC = toVC
     toVC.textSnippet = nextSnippet as? TextSnippet
    
    case .photo: fallthrough
    
    case .video:
     guard let toVC = currentViewController.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController
      else
     {
      return
     }
     nextVC = toVC
     toVC.photoSnippet = nextSnippet as? PhotoSnippet
    
    case .audio: break
    case .sketch: break
    case .report: break
    case .undefined: break
    
   }
   
   guard nextVC != nil else {return}
   
   (currentViewController.navigationController?.delegate as! NCTransitionsDelegate).isPageMode = true
   (currentViewController.navigationController?.delegate as! NCTransitionsDelegate).scrollDirection = direction
   
   currentViewController.navigationController?.pushViewController(nextVC!, animated: true)
   
   (currentViewController.navigationController?.delegate as! NCTransitionsDelegate).isPageMode = false
   
   let ind = currentViewController.navigationController!.viewControllers.count - 2
   nextVC?.navigationController?.viewControllers.remove(at: ind)
   
  }
 }
 
}
