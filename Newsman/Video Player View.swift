
import Foundation
import AVKit

class PlayerView: UIView
{
 var progressHideDuration = 0.5
 var progressShowDuration = 0.5
 
 var playbackHideDuration = 0.5
 var playbackShowDuration = 0.5
 
 override static var layerClass: AnyClass {return AVPlayerLayer.self}
 
 @objc dynamic var playerLayer: AVPlayerLayer {return layer as! AVPlayerLayer}
 
 lazy var playbackButton: PlaybackButton =
 {
  let insX = 0.1 * self.bounds.width
  let insY = 0.1 * self.bounds.height
  let sq = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self.bounds.insetBy(dx: insX, dy: insY))
  let playButton = PlaybackButton(frame: sq)
  playButton.backgroundColor = UIColor.clear
  playButton.addTarget(self, action: #selector(self.playbackPress), for: .touchDown)
  playButton.drawPlayIcon(iconColor: UIColor.red)
  playButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
  self.addSubview(playButton)
  return playButton
  
 }()
 
 lazy var progressView: UIProgressView =
 {
  let progress = UIProgressView(progressViewStyle: .default)
  progress.progress = 0.0
  let render = UIGraphicsImageRenderer(size: CGSize(width: 15, height: 15))
  progress.trackImage = render.image
   {context in
    context.cgContext.setFillColor(UIColor.black.cgColor)
    context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15))
    context.cgContext.setStrokeColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor)
    context.cgContext.setLineWidth(1)
    context.cgContext.strokeEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15).insetBy(dx: 0.5, dy: 0.5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ))
   }.resizableImage(withCapInsets: UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5), resizingMode: .stretch)
  
  progress.progressImage = render.image
  {context in
   context.cgContext.setFillColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor)
   context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15).insetBy(dx: 2, dy: 2))
  
  }.resizableImage(withCapInsets: UIEdgeInsetsMake(5.5, 5.5, 5.5, 5.5), resizingMode: .stretch)
  
  self.addSubview(progress)
  progress.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    progress.leadingAnchor.constraint  (equalTo:  leadingAnchor,  constant:  30),
    progress.trailingAnchor.constraint (equalTo:  trailingAnchor, constant: -30),
    progress.bottomAnchor.constraint   (equalTo:  bottomAnchor,   constant: -30),
    progress.heightAnchor.constraint   (equalToConstant: 15)
   ]
  )
  return progress
 }()
 
 func showProgressView()
 {
  progressView.progress = 0.0
  progressView.alpha = 0.0
  progressView.transform = CGAffineTransform(translationX: 0, y: 100)
  UIView.animate(withDuration: progressShowDuration,
                 delay: 0.0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut, .allowUserInteraction],
                 animations:
                 {[unowned self] in
                  self.progressView.transform = .identity
                  self.progressView.alpha = 1.0
                 },
                 completion: {[weak self] _ in self?.playFromStart()})
  
 }
 
 func hideProgressView()
 {
  UIView.animate(withDuration: progressHideDuration,
                 delay: 0.0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut, .allowUserInteraction],
                 animations:
                 {[unowned self] in
                  self.progressView.transform = CGAffineTransform(translationX: 0, y: 100)
                  self.progressView.alpha = 0.0
                 },
                 completion: nil)
 }
 
 func showPlayButton()
 {
  playbackButton.alpha = 0
  playbackButton.transform = CGAffineTransform(scaleX: 3, y: 3)
  UIView.animate(withDuration: playbackShowDuration,
                 delay: 0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut, .allowUserInteraction],
                 animations:
                 {[unowned self] in
                  self.playbackButton.transform = .identity
                  self.playbackButton.alpha = 1
                 },
                 completion:
                 {[unowned self] _ in
                  self.hideProgressView()
                 })
  
 }
 
 func hidePlayButton()
 {
  UIView.animate(withDuration: playbackHideDuration,
                 delay: 0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut],
                 animations:
                 {[unowned self] in
                  self.playbackButton.transform = CGAffineTransform(scaleX: 3, y: 3)
                  self.playbackButton.alpha = 0

                 },
                 completion:
                 {[unowned self] _ in self.showProgressView()})
  
 }
 
 var endObserver: Any?
 var progressObserver: Any?
 
 @objc func playbackPress(_sender: UIButton)
 {
  hidePlayButton()
 }
 
 func playFromStart()
 {
  addEndObserver()
  addPlayProgressObserver()
  player?.seek(to: kCMTimeZero)
  player?.play()
 }
 
 
 var player: AVPlayer?
 {
  get {return playerLayer.player}
  set
  {
   playerLayer.player = newValue
   
   
  }
 }
 

 func addPlayProgressObserver()
 {
  let interval = CMTime(seconds: 0.001, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
  guard let duration = player?.currentItem?.asset.duration else
  {
    return
  }
  progressObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main)
  {[unowned self] time in
   self.progressView.progress = Float(time.seconds/duration.seconds)
  }
 }
 
 func addEndObserver()
 {
  guard let duration = player?.currentItem?.asset.duration else
  {
   return
  }
  endObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: duration)], queue: DispatchQueue.main)
  {[unowned self] in
   self.showPlayButton()
  }
 }

 override func didMoveToSuperview()
 {
  super.didMoveToSuperview()
 }
 
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
   player?.removeTimeObserver(observer)
  }
  
  if let observer = progressObserver
  {
   player?.removeTimeObserver(observer)
  }
 }
 
}
