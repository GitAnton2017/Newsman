
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
        
    guard let snippet = cell.hostedSnippet else { return }
    
    let groupType = cell
    
    var i = 0
    
    let animationID = UUID()
    cell.animationID = animationID
    
    let options: [UIView.AnimationOptions] = [.transitionFlipFromTop,
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
                       {finished  in
                        guard finished else { return }
                        guard cell.animationID == animationID else { return }
                        guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
                        if (i < imgs.count - 1) {i += 1} else {i = 0}
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75 * duration)
                        {
                         guard cell.animationID == animationID else { return }
                         guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
                         animate()
                        }
                      })
    }
    
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
    {
     guard cell.animationID == animationID else { return }
     guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
     animate()
    }
    
   },
   
   {imgs, cell, duration, delay in
   
    guard let snippet = cell.hostedSnippet else {return}

    var i = 0
    
    let animationID = UUID()
    cell.animationID = animationID
    
    let types = [convertFromCATransitionType(CATransitionType.push), convertFromCATransitionType(CATransitionType.moveIn), convertFromCATransitionType(CATransitionType.reveal)]
    let a4rnd_t = GKRandomDistribution(lowestValue: 0, highestValue: types.count - 1)
    
    let subtypes = [convertFromCATransitionSubtype(CATransitionSubtype.fromTop), convertFromCATransitionSubtype(CATransitionSubtype.fromBottom), convertFromCATransitionSubtype(CATransitionSubtype.fromRight), convertFromCATransitionSubtype(CATransitionSubtype.fromLeft)]
    let a4rnd_st = GKRandomDistribution(lowestValue: 0, highestValue: subtypes.count - 1)
    
    func animate (_ duration: TimeInterval)
    {
     let trans = CATransition()
     trans.setValue(animationID, forKey: "animationID")
     trans.delegate = cell
     trans.type = convertToCATransitionType(types[a4rnd_t.nextInt()])
     trans.subtype = convertToOptionalCATransitionSubtype(subtypes[a4rnd_st.nextInt()])
     trans.duration = duration
     cell.flipperView.layer.add(trans, forKey: transitions2)
     cell.snippetImage.image = imgs[i]
     if (i < imgs.count - 1) { i += 1 } else { i = 0 }
     
    }
    
    cell.transDuration = duration
    cell.animate = animate
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
    {
     guard cell.animationID == animationID else { return }
     guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
     animate(duration * 0.25)
    }
    
   }
   
 ]
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionSubtype(_ input: CATransitionSubtype) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCATransitionSubtype(_ input: String?) -> CATransitionSubtype? {
	guard let input = input else { return nil }
	return CATransitionSubtype(rawValue: input)
}
