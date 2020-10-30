
import Foundation
import AVKit

class PlayerView: UIView
{
 var progressHideDuration = 0.5
 var progressShowDuration = 0.5
 
 var playbackHideDuration = 0.5
 var playbackShowDuration = 0.5
 
 lazy var doubleTapGR: UITapGestureRecognizer =
 {
  let gr = UITapGestureRecognizer(target: self, action: #selector(viewDoubleTap))
  gr.numberOfTapsRequired = 2
  self.addGestureRecognizer(gr)
  return gr
 }()
 
 override static var layerClass: AnyClass {return AVPlayerLayer.self}
 
 @objc dynamic var playerLayer: AVPlayerLayer {return layer as! AVPlayerLayer}
 
 lazy var playbackButton: PlaybackButton =
 {
  let insX = 0.35 * self.bounds.width
  let insY = 0.35 * self.bounds.height
  let sq = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self.bounds.insetBy(dx: insX, dy: insY))
  let playButton = PlaybackButton(frame: sq)
  playButton.addTarget(self, action: #selector(self.playbackPress), for: .touchDown)
  playButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
  self.addSubview(playButton)
  return playButton
  
 }()
 
 lazy var progressView: UIProgressView =
 {
  addEndObserver()
  addPlayProgressObserver()
  
  let progress = PlaybackProgressView(progressViewStyle: .default)
  progress.progress = 0.0
  let render = UIGraphicsImageRenderer(size: CGSize(width: 15, height: 15))
  progress.trackImage = render.image
  {context in
    context.cgContext.setFillColor(UIColor.black.cgColor)
    context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15))
    context.cgContext.setStrokeColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor)
    context.cgContext.setLineWidth(1)
    context.cgContext.strokeEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15).insetBy(dx: 0.5, dy: 0.5))
  }.resizableImage(withCapInsets: UIEdgeInsets.init(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5), resizingMode: .stretch)
  
  progress.progressImage = render.image
  {context in
   context.cgContext.setFillColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor)
   context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 15, height: 15).insetBy(dx: 2, dy: 2))
  
  }.resizableImage(withCapInsets: UIEdgeInsets.init(top: 5.5, left: 5.5, bottom: 5.5, right: 5.5), resizingMode: .stretch)
  
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
 
 
 lazy var timer: UILabel =
 {
  let timer = UILabel(frame: CGRect.zero)
  timer.backgroundColor = UIColor.clear
  timer.textAlignment = .right
  timer.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
  self.addSubview(timer)
  timer.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    timer.topAnchor.constraint  (equalTo:  topAnchor,  constant:  15),
    timer.trailingAnchor.constraint (equalTo:  trailingAnchor, constant: -15),
    timer.widthAnchor.constraint(equalToConstant: 150),
    timer.heightAnchor.constraint (equalToConstant: 30)
   ]
  )
  
  return timer
 }()
 
 lazy var scrubView: VideoScrubView =
 {
  let sv = VideoScrubView(frame: CGRect.zero, markersColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), markersDistance: 16)
  
  self.addSubview(sv)
 
  sv.translatesAutoresizingMaskIntoConstraints = false
 
  
  NSLayoutConstraint.activate(
   [
    sv.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
    sv.widthAnchor.constraint(equalToConstant: 25),
    sv.heightAnchor.constraint(equalToConstant: 50),
    sv.centerXAnchor.constraint(equalTo: progressView.leadingAnchor)
   ]
  )
  return sv
 }()
 
 func showProgressView()
 {
  progressView.progress = 0.0
  timer.alpha = 0.0
  timer.transform = CGAffineTransform(translationX: 0, y: -100)
  timer.text = "00:00:00"
  progressView.alpha = 0.0
  scrubView.alpha = 0.0
  progressView.transform = CGAffineTransform(translationX: 0, y: 100)
  
  UIView.animate(withDuration: progressShowDuration,
                 delay: 0.0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut],
                 animations:
                 {[weak self] in
                  self?.timer.alpha = 1.0
                  self?.timer.transform = .identity
                  self?.progressView.transform = .identity
                  self?.progressView.alpha = 1.0
                 },
                 completion: {[weak self] _ in self?.playFromStart()})
  
 }
 
 func hideProgressView()
 {
  UIView.animate(withDuration: progressHideDuration,
                 delay: 0.0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut],
                 animations:
                 {[weak self] in
                  self?.progressView.transform = CGAffineTransform(translationX: 0, y: 100)
                  self?.progressView.alpha = 0.0
                  self?.timer.alpha = 0.0
                  self?.timer.transform = CGAffineTransform(translationX: 0, y: -100)
                 },
                 completion: nil)
 }
 
 func showPlayButton()
 {
  doubleTapGR.isEnabled = false
  playbackButton.alpha = 0
  playbackButton.transform = CGAffineTransform(scaleX: 3, y: 3)
  UIView.animate(withDuration: playbackShowDuration,
                 delay: 0,
                 usingSpringWithDamping: 50,
                 initialSpringVelocity: 0,
                 options: [.curveEaseInOut, .allowUserInteraction],
                 animations:
                 {[weak self] in
                  self?.playbackButton.transform = .identity
                  self?.playbackButton.alpha = 1
                 },
                 completion:
                 {[weak self] _ in
                  self?.hideProgressView()
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
                 {[weak self] in
                  self?.playbackButton.transform = CGAffineTransform(scaleX: 3, y: 3)
                  self?.playbackButton.alpha = 0

                 },
                 completion:
                 {[weak self] _ in self?.showProgressView()})
  
 }
 
 var endObserver: Any?
 var progressObserver: Any?
 
 @objc func playbackPress(_sender: UIButton)
 {
  hidePlayButton()
 }
 
 func playFromStart()
 {
  doubleTapGR.isEnabled = true
  player?.seek(to: CMTime.zero)
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
  {[weak self] time in
   guard let pv = self?.progressView else {return}
   let HH = Int(time.seconds/3600)
   let MM = Int((time.seconds - Double(HH) * 3600) / 60)
   let SS = Int(time.seconds - Double(HH) * 3600 - Double(MM) * 60)
  
   self?.timer.text = "\(HH < 10 ? "0" : "")\(HH):\(MM < 10 ? "0" : "")\(MM):\(SS < 10 ? "0" : "")\(SS)"
   
   let progress = Float(time.seconds/duration.seconds)
   pv.progress = progress
   let newX = pv.frame.minX + pv.bounds.width  * CGFloat(progress)
   let dx = abs(newX - (self?.scrubView.center.x ?? 0))
   
   if (dx < 5) {self?.scrubView.center.x = newX}
   else
   {
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 10,
                   initialSpringVelocity: 50,
                   options: [.curveEaseInOut],
                   animations: {[weak self] in self?.scrubView.center.x = newX},
                   completion: nil)
   }
  }
 }
 
 func addEndObserver()
 {
  guard let duration = player?.currentItem?.asset.duration else
  {
   return
  }
  endObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: duration)], queue: DispatchQueue.main)
  {[weak self] in
   self?.showPlayButton()
  }
 }
 
 
 @objc func viewDoubleTap(_ sender: UITapGestureRecognizer)
 {
  
  guard let player = self.player else {return}
  
  if player.rate > 0
  {
   player.rate = 0
   scrubView.alpha = 1
  }
  else
  {
   player.rate = 1
   scrubView.alpha = 0
  }
 
 }
 
 
 init(frame: CGRect, with gravity: AVLayerVideoGravity)
 {
  super.init(frame: frame)
  autoresizingMask = [.flexibleWidth, .flexibleHeight]
  (layer as! AVPlayerLayer).videoGravity = gravity
  playerLayer.contentsScale = UIScreen.main.scale
  
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
