
import Foundation
import AVKit

class PlayerView: UIView
{
 override static var layerClass: AnyClass {return AVPlayerLayer.self}
 
 @objc dynamic var playerLayer: AVPlayerLayer {return layer as! AVPlayerLayer}
 
 @objc func playbackPress(_sender: UIButton)
 {
  UIView.animate(withDuration: 0.5,
                 delay: 0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut],
                 animations:
   {[unowned self] in
    if let pbb = self.playbackButton
    {
     pbb.transform = CGAffineTransform(scaleX: 3, y: 3)
     pbb.alpha = 0
    }
   },
   completion:
   {[unowned self] _ in
    self.playbackButton?.removeFromSuperview()
    self.playerLayer.player?.seek(to: kCMTimeZero)
    self.playerLayer.player?.play()
   })
  
  
 }
 
 var player: AVPlayer?
 {
  get {return playerLayer.player}
  set
  {
   playerLayer.player = newValue
   addEndObserver()
  }
 }
 
 var endObserver: Any?
 
 func addEndObserver()
 {
  guard let duration = playerLayer.player?.currentItem?.asset.duration else {return}
  endObserver = playerLayer.player?.addBoundaryTimeObserver(forTimes: [NSValue(time: duration)], queue: DispatchQueue.main)
  {[unowned self] in
   let insX = 0.1 * self.bounds.width
   let insY = 0.1 * self.bounds.height
   let sq = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self.bounds.insetBy(dx: insX, dy: insY))
   let playButton = PlaybackButton(frame: sq)
   playButton.backgroundColor = UIColor.clear
   playButton.addTarget(self, action: #selector(self.playbackPress), for: .touchDown)
   playButton.drawPlayIcon(iconColor: UIColor.red)
   playButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
   playButton.alpha = 0
   playButton.transform = CGAffineTransform(scaleX: 3, y: 3)
   self.addSubview(playButton)
   
   self.playbackButton = playButton
   
   UIView.animate(withDuration: 0.5,
                  delay: 0,
                  usingSpringWithDamping: 50,
                  initialSpringVelocity: 0,
                  options: [.curveEaseInOut, .allowUserInteraction],
                  animations:
                  {
                   playButton.transform = .identity
                   playButton.alpha = 1
                  },
                  completion: nil)
   
  }
 }
 
 var playbackButton: PlaybackButton?
 
 init(frame: CGRect, with gravity: AVLayerVideoGravity)
 {
  super.init(frame: frame)
  autoresizingMask = [.flexibleWidth, .flexibleHeight]
  (layer as! AVPlayerLayer).videoGravity = gravity

  
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 deinit
 {
  if let observer = endObserver
  {
   playerLayer.player?.removeTimeObserver(observer)
  }
 }
 
}
