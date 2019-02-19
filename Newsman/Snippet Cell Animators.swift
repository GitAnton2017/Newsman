
import Foundation
import UIKit
import GameplayKit

enum SnippetsAnimator
{
  static let movie = "movie"
  static let transitions1 = "trans1"
  static let transitions2 = "trans2"
 
  private typealias AnimatorBlockType = ([UIImage], SnippetsViewCell, TimeInterval, TimeInterval) -> Void
 
  static func startRandom (for images: [UIImage],cell: SnippetsViewCell, duration: TimeInterval, delay: TimeInterval)
  {
   let max_b = imagesAnimators.count - 1
   let a4rnd = GKRandomDistribution(lowestValue: 0, highestValue: max_b)
   imagesAnimators[a4rnd.nextInt()](images, cell, duration, delay)
  }
 
  private static var imagesAnimators: [AnimatorBlockType] =
  [
//   {imgs, cell, duration, delay in
//    
//    cell.snippetImage.layer.removeAllAnimations()
//    
//    let kfa = CAKeyframeAnimation(keyPath: #keyPath(CALayer.contents))
//    let animationID = UUID()
//    kfa.setValue(animationID, forKey: "animationID")
//    cell.animationID = animationID
//    
//    kfa.fillMode = kCAFillModeBoth
//    kfa.beginTime = CACurrentMediaTime() + delay
//    kfa.values = imgs.map{$0.cgImage!}
//    kfa.duration = duration * Double(imgs.count)
//    kfa.repeatCount = .infinity
//    kfa.autoreverses = true
//    
//    kfa.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//    kfa.calculationMode = kCAAnimationCubic
//    cell.snippetImage.layer.add(kfa, forKey: movie)
//    
//   },
   
   {imgs, cell, duration, delay in
    
    cell.flipperView.layer.removeAllAnimations()
    
    guard let snippet = cell.hostedSnippet as? BaseSnippet else {return}
    
    let groupType = cell
    
    var i = 0
    
    let animationID = UUID()
    cell.animationID = animationID
    
    let options: [UIViewAnimationOptions] = [.transitionFlipFromTop,
                                             .transitionFlipFromBottom,
                                             .transitionFlipFromRight,
                                             .transitionFlipFromLeft]
    
    let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: options.count - 1)
    
    func animate ()
    {
     let option = options[arc4rnd.nextInt()]
     UIView.transition(with: cell.flipperView, duration: 0.25 * duration,
                       options: [option, .curveEaseInOut],
                       animations: {cell.snippetImage.image = imgs[i]},
                       completion:
                       {[weak w_cell = cell, weak w_snippet = snippet] finished  in
                        guard finished else {return}
                        guard let wc = w_cell, let ws = w_snippet else {return}
                        guard wc.animationID == animationID else {return}
                        guard wc.hostedSnippet === ws else {return}
                        if let gt = wc.groupType, ws[gt] {return}
                        if (i < imgs.count - 1) {i += 1} else {i = 0}
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75 * duration)
                        {[weak w_cell = cell, weak w_snippet = snippet] in
                         guard let wc = w_cell, let ws = w_snippet else {return}
                         guard wc.animationID == animationID else {return}
                         guard wc.hostedSnippet === ws else {return}
                         if let gt = wc.groupType, ws[gt] {return}
                         animate()
                        }
                      })
    }
    
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
    {[weak w_cell = cell, weak w_snippet = snippet] in
     guard let wc = w_cell, let ws = w_snippet else {return}
     guard wc.animationID == animationID else {return}
     guard wc.hostedSnippet === ws else {return}
     if let gt = wc.groupType, ws[gt] {return}
     animate()
    }
    
   },
   
   {imgs, cell, duration, delay in
    
    cell.flipperView.layer.removeAllAnimations()
    
    guard let snippet = cell.hostedSnippet as? BaseSnippet else {return}

    var i = 0
    
    let animationID = UUID()
    cell.animationID = animationID
    
    let types = [kCATransitionPush, kCATransitionMoveIn, kCATransitionReveal]
    let a4rnd_t = GKRandomDistribution(lowestValue: 0, highestValue: types.count - 1)
    
    let subtypes = [kCATransitionFromTop, kCATransitionFromBottom, kCATransitionFromRight, kCATransitionFromLeft]
    let a4rnd_st = GKRandomDistribution(lowestValue: 0, highestValue: subtypes.count - 1)
    
    func animate (_ duration: TimeInterval)
    {
     let trans = CATransition()
     trans.setValue(animationID, forKey: "animationID")
     trans.delegate = cell
     trans.type = types[a4rnd_t.nextInt()]
     trans.subtype = subtypes[a4rnd_st.nextInt()]
     trans.duration = duration
     cell.flipperView.layer.add(trans, forKey: transitions2)
     cell.snippetImage.image = imgs[i]
     if (i < imgs.count - 1) {i += 1} else {i = 0}
     
    }
    
    cell.transDuration = duration
    cell.animate = animate
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
    {[weak w_cell = cell, weak w_snippet = snippet] in
     guard let wc = w_cell, let ws = w_snippet else {return}
     guard wc.animationID == animationID else {return}
     guard wc.hostedSnippet === ws else {return}
     if let gt = wc.groupType, ws[gt] {return}
     animate(duration * 0.25)
    }
    
   }
   
 ]
}
