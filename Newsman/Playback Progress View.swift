
import Foundation
import UIKit
import AVKit

class PlaybackProgressView: UIProgressView
{
 
 @objc func progressTap (_ gr: UITapGestureRecognizer)
 {
  
  guard gr.state == .ended,
        let pv = superview as? PlayerView,
        let player = pv.player, player.rate == 0,
        let duration = pv.player?.currentItem?.asset.duration
  else
  {
   return
  }
  
  let tpX = gr.location(ofTouch: 0, in: self).x
  let progress = Double(tpX / bounds.width)
  let time = CMTime(seconds: duration.seconds * progress, preferredTimescale: duration.timescale)
  let tol = CMTime(seconds: 0.1, preferredTimescale: duration.timescale)
  player.seek(to: time, toleranceBefore: tol, toleranceAfter: tol)
 
  
 }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
  addObserver(self, forKeyPath: #keyPath(PlaybackProgressView.bounds), options: [.new], context: nil)
  let tapGR = UITapGestureRecognizer(target: self, action: #selector(progressTap))
  addGestureRecognizer(tapGR)
  
 }
 
 override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                            change: [NSKeyValueChangeKey : Any]?,
                            context: UnsafeMutableRawPointer?)
 {
  if keyPath == #keyPath(PlaybackProgressView.bounds),
     let sv = (superview as? PlayerView)?.scrubView,
     let newWidth = (change?[.newKey] as? CGRect)?.width
  {
   sv.center.x += CGFloat(progress) * newWidth
  }
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 deinit
 {
  removeObserver(self, forKeyPath: #keyPath(PlaybackProgressView.bounds))
 }
}
