
import Foundation
import UIKit
import AVKit
import CoreData

class ZoomView: UIView
{
    var photoItems: [PhotoItem]!
    var nphoto: Int = 3
    var swipeGR: UISwipeGestureRecognizer!
    var panGR:   UIPanGestureRecognizer!
    var pinchGR: UIPinchGestureRecognizer!
    var panInitTouchPoint: CGPoint!
    var zoomRatio: CGFloat = 1.0
    var minZoomRatio: CGFloat = 0.5
    var maxZoomRatio: CGFloat = 5.0
    var minPinchVelocity: CGFloat = 0.15
    var removingZoomView = false
 
    @objc dynamic var playerView: PlayerView?
 
    weak var photoSnippetVC: PhotoSnippetViewController!
 
    weak var zoomedPhotoItem: PhotoItemProtocol?
    {
     didSet
     {
      oldValue?.isZoomed = false
      zoomedPhotoItem?.isZoomed = true
     }
     //as soon as we open ZoomView with <zoomedPhotoItem> assigned here we set <isZoomed> state of PhotoItem
     //of PhotoFolderItem and consequently the underlying state of its MO...
    }
 
    deinit
    {
     zoomedPhotoItem?.isZoomed = false
     //before ZoomView is destructed we unset <isZoomed> state of zoomed photo item...
    }
 
    weak var zoomedManagedObject: NSManagedObject?
 
    var zoomedCellIndexPath: IndexPath!
    var presentSubview: UIView!
 
    var zoomSize: CGFloat {return 0.9 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)}
    
    var isShowingCV: Bool
    {
        for sv in subviews
        {
            if let _ = sv as? UICollectionView {return true}
        }
        
        return false
    }
    
    var isShowingIV: Bool
    {
        for sv in subviews
        {
            if let _ = sv as? UIImageView {return true}
        }
        
        return false
    }
 

    init()
    {
        super.init(frame: CGRect.zero)
     
        swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(zoomViewSwipe))
        swipeGR.name = "ZoomViewCloseSwipe"
        self.addGestureRecognizer(swipeGR)
        
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(zoomViewPan))
        panGR.name = "ZoomViewPan"
        self.addGestureRecognizer(panGR)
        panGR.require(toFail: swipeGR)
        
        pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(zoomViewPinch))
        pinchGR.name = "ZoomViewPinch"
        self.addGestureRecognizer(pinchGR)
        
        layer.cornerRadius = 10.0
        layer.borderWidth = 5
        layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.black.cgColor
        
        
        transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
    }

    
    func removeZoomView ()
    {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseIn],
                       animations:
                       {[weak self] in
                        self?.removingZoomView = true
                        self?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        self?.center = CGPoint(x: UIScreen.main.bounds.maxX, y: UIScreen.main.bounds.maxY)
                       },
                       completion:
                       {[weak self] _ in
                        self?.removeFromSuperview()
                        self?.removingZoomView = false
                       })
    }
 
    func changeAnim(to subView: UIView)
    {
     UIView.transition(with: self,
                       duration: 1,
                       options: [.curveEaseOut, .transitionFlipFromBottom, .transitionCrossDissolve],
                       animations: {[weak self]   in self?.addSubview(subView)},
                       completion: {[weak self] _ in self?.setConstraints(of: subView)})
    }
 
 
    func openAnim(completion: ((Bool) -> Void)? = nil)
    {
     
     UIView.animate(withDuration: 1,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 12,
                    options: [.curveEaseInOut],
                    animations: {[weak self] in
                                  guard let zv = self else {return}
                                  zv.transform = CGAffineTransform.identity
                                  zv.center = zv.superview!.center
                                 },
                                 completion: completion)
    }
    
    func setConstraints (to mainView: UIView)
    {
     translatesAutoresizingMaskIntoConstraints = false
     
     NSLayoutConstraint.activate(
      [
       widthAnchor.constraint   (equalToConstant: zoomSize),
       centerXAnchor.constraint (equalTo: mainView.centerXAnchor),
       centerYAnchor.constraint (equalTo: mainView.centerYAnchor),
       widthAnchor.constraint   (equalTo: heightAnchor)
      ]
     )
    }
 
 
    func setRectConstraints (to mainView: UIView)
    {
     translatesAutoresizingMaskIntoConstraints = false
  
      NSLayoutConstraint.activate(
      [
       topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor, constant: 5),
       leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 5),
       trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -5),
       bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor, constant: -5)
      ]
     )
    }
 
 
    func setConstraints (of subView: UIView)
    {
      subView.translatesAutoresizingMaskIntoConstraints = false
        
      NSLayoutConstraint.activate(
      [
       subView.bottomAnchor.constraint  (equalTo: bottomAnchor),
       subView.topAnchor.constraint     (equalTo: topAnchor),
       subView.leadingAnchor.constraint (equalTo: leadingAnchor),
       subView.trailingAnchor.constraint(equalTo: trailingAnchor)
      ]
     )
        
    }
    
    func stopSpinner()
    {
      for sv in subviews
      {
        if let spinner = sv as? UIActivityIndicatorView
        {
          spinner.stopAnimating()
        }
      }
    }
 
    func getVideoAspectRatio(asset: AVURLAsset, vtrack: AVAssetTrack)
    {
     print ("***** Video natural Size is: \(vtrack.naturalSize)")
    }
 
    func getAssetTracks(asset: AVURLAsset)
    {
      let vtrack = asset.tracks(withMediaType: .video).first!
      let ratio = #keyPath(AVAssetTrack.naturalSize)
      vtrack.loadValuesAsynchronously(forKeys: [ratio])
      {
       let status = asset.statusOfValue(forKey: ratio, error: nil)
       if (status == .loaded)
       {
        DispatchQueue.main.async
        {[unowned self] in
         self.getVideoAspectRatio(asset: asset, vtrack: vtrack)
        }
       }
      }
    }
 
    func loadAssetTracks(asset: AVURLAsset)
    {
     let track = #keyPath(AVURLAsset.tracks)
     asset.loadValuesAsynchronously(forKeys: [track])
     {
      let status = asset.statusOfValue(forKey: track, error: nil)
      if (status == .loaded)
      {
       DispatchQueue.main.async
       {[unowned self] in
        self.getAssetTracks(asset: asset)
       }
      }
     }
    }
 
   
    func configueVideoPlayback (for videoURL : URL)
    {
     let asset = AVURLAsset(url: videoURL)
    
     loadAssetTracks(asset: asset)
     let item = AVPlayerItem(asset: asset)
     let videoPlayer = AVPlayer(playerItem: item)
     playerView = PlayerView(frame: self.bounds, with: .resizeAspectFill)
     playerView!.player = videoPlayer
    
    }
 
 
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
     if (keyPath == #keyPath(playerView.playerLayer.isReadyForDisplay) && playerView!.playerLayer.isReadyForDisplay)
     {
      stopSpinner()
  
      
      UIView.transition(with: self,
                        duration: 1.0,
                        options: [.transitionCrossDissolve, .curveEaseInOut],
                        animations:
                        {[unowned self] in
                         self.addSubview(self.playerView!)
                         },
                        completion: {[weak self] _ in self?.playerView?.showProgressView()})
      
      removeObserver(self, forKeyPath: #keyPath(playerView.playerLayer.isReadyForDisplay))
      
     }
    }
 
    func openWithVideoPlayer(in mainView: UIView, for videoURL : URL)
    {
     mainView.addSubview(self)
     setRectConstraints(to: mainView)
     
     let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
     spinner.hidesWhenStopped = true
     self.addSubview(spinner)
     setConstraints(of: spinner)
     spinner.startAnimating()
     addObserver(self, forKeyPath: #keyPath(playerView.playerLayer.isReadyForDisplay), options: [.new], context: nil)
     openAnim(completion: {[unowned self] _ in self.configueVideoPlayback (for: videoURL)})
    
     
    }
 
    func openWithIV (in mainView: UIView) -> UIImageView
    {
        
      for sv in subviews
      {
        if let iv = sv as? UIImageView {return iv}
      }
        
      subviews.forEach{$0.removeFromSuperview()}
       
      mainView.addSubview(self)
      setConstraints(to: mainView)
      let iv = UIImageView()
     
      let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
      spinner.hidesWhenStopped = true
      self.addSubview(spinner)
      spinner.startAnimating()
     
      self.addSubview(iv)
      setConstraints(of: iv)
      setConstraints(of: spinner)
        
      let dragger = UIDragInteraction(delegate: self)
      addInteraction(dragger)
      dragger.isEnabled = true
        
      let dropper = UIDropInteraction(delegate: self)
      addInteraction(dropper)
     
     
      if (presentSubview != nil) {changeAnim(to: iv)}
      else
      {
       self.addSubview(iv)
       setConstraints(of: iv)
       openAnim()
      }
     
      presentSubview = iv
      return iv
      
    }
    
    func openWithCV (in mainView: UIView) -> UICollectionView
    {
      for sv in subviews
      {
       if let cv = sv as? UICollectionView {return cv}
      }
     
      subviews.forEach{$0.removeFromSuperview()}
        
      interactions.removeAll()
        
      mainView.addSubview(self)
      setConstraints(to: mainView)
      let cv_lo = UICollectionViewFlowLayout()
      
      let ins = layer.borderWidth + 2
      cv_lo.sectionInset = UIEdgeInsetsMake(ins, ins, ins, ins)
      cv_lo.minimumInteritemSpacing = 2
      cv_lo.minimumLineSpacing = 2
      
      let cv = UICollectionView(frame: bounds, collectionViewLayout: cv_lo)
        
      cv.delegate = self
      cv.dataSource = self
      cv.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
      cv.dragInteractionEnabled = true
      cv.dropDelegate = self
      cv.dragDelegate = self
      cv.contentInsetAdjustmentBehavior = .never //!!!
     // Constants indicating how safe area insets are added to the adjusted content inset.
     // .automatic - Automatically adjust the scroll view insets.
     // .scrollableAxes - Adjust the insets only in the scrollable directions.
     // .never - Do not adjust the scroll view insets.
     // .always -Always include the safe area insets in the content adjustment.
     
        
      let cellNib = UINib(nibName: "ZoomCollectionViewCell", bundle: nil)
      cv.register(cellNib, forCellWithReuseIdentifier: "ZoomCollectionViewCell")
      //cv.register(ZoomViewCollectionViewCell.self, forCellWithReuseIdentifier: "ZoomCollectionViewCell")
     
      if (presentSubview != nil) {changeAnim(to: cv)}
      else
      {
       self.addSubview(cv)
       setConstraints(of: cv)
       openAnim()
      }
     
      presentSubview = cv
      return cv
    }
 
    @objc func zoomViewPinch (_ gr: UIPinchGestureRecognizer)
    {
        guard abs(gr.velocity) > minPinchVelocity else {return}
        
        guard zoomRatio >= minZoomRatio else
        {
            if (!removingZoomView) {removeZoomView()}
            return
        }
        
        switch (gr.state)
        {
         case .changed:
            let delta: CGFloat = exp(zoomRatio/1.5)/100
            zoomRatio += (gr.scale > 1  ? (zoomRatio <= maxZoomRatio ? delta : 0) : (zoomRatio >= minZoomRatio ? -delta : 0))
            transform = CGAffineTransform(scaleX: zoomRatio, y: zoomRatio)
         default: break
        }
        
    }
    
    @objc func zoomViewSwipe(_ gr: UISwipeGestureRecognizer)
    {
        removeZoomView ()
    }
    
    @objc func zoomViewPan (_ gr: UIPanGestureRecognizer)
    {
       switch (gr.state)
       {
        case .began:
            panInitTouchPoint = gr.location(in: self)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations:
                           {[unowned self] in
                            self.alpha = 0.85
                           },
                           completion: nil)
             
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseIn, .`repeat`, .autoreverse, .allowUserInteraction],
                           animations:
                           {[unowned self] in
                             self.transform = CGAffineTransform(scaleX: 1.05 * self.zoomRatio, y: 1.05 * self.zoomRatio)
             
                           },
                           completion: nil)
            
        case .changed:
            let touchPoint = gr.location(in: self)
            let translation = gr.translation(in: self)
            if (touchPoint.x > panInitTouchPoint.x - 50  && touchPoint.y > panInitTouchPoint.y - 50  &&
                touchPoint.x < panInitTouchPoint.x + 50  && touchPoint.y < panInitTouchPoint.y + 50)
            {
                center.x += translation.x * zoomRatio
                center.y += translation.y * zoomRatio
            }
            gr.setTranslation(CGPoint.zero, in: self)
            
        default:
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations:
                           {[unowned self] in
                            self.transform = CGAffineTransform(scaleX: self.zoomRatio, y: self.zoomRatio)
                            self.alpha = 1.0
                           },
                           completion: nil)
        }
        
    }
    
}





