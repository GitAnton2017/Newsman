
import Foundation
import UIKit

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
 
    weak var photoSnippetVC: PhotoSnippetViewController!
    weak var zoomedPhotoItem: PhotoItemProtocol?
 
    var zoomedCellIndexPath: IndexPath!
    var presentSubview: UIView!
    
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
    
    var zoomSize: CGFloat {return 0.9 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)}

    init()
    {
        super.init(frame: CGRect.zero)
        swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(zoomViewSwipe))
        self.addGestureRecognizer(swipeGR)
        
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(zoomViewPan))
        self.addGestureRecognizer(panGR)
        panGR.require(toFail: swipeGR)
        
        pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(zoomViewPinch))
        self.addGestureRecognizer(pinchGR)
        
        layer.cornerRadius = 10.0
        layer.borderWidth = 5
        layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
        layer.masksToBounds = true
        
        
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
                       {[unowned self] in
                        self.removingZoomView = true
                        self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        self.center = CGPoint(x: UIScreen.main.bounds.maxX, y: UIScreen.main.bounds.maxY)
                       },
                       completion:
                       {[unowned self] _ in
                        self.removeFromSuperview()
                        self.removingZoomView = false
                       })
    }
 
    func changeAnim(to subView: UIView)
    {
     UIView.transition(with: self,
                       duration: 1,
                       options: [.curveEaseOut, .transitionFlipFromBottom, .transitionCrossDissolve],
                       animations: {[unowned self]   in self.addSubview(subView)},
                       completion: {[unowned self] _ in self.setConstraints(of: subView)})
    }
 
 
    func openAnim()
    {
     
     UIView.animate(withDuration: 1,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 12,
                    options: [.curveEaseInOut],
                    animations: {[unowned self] in
                                  self.transform = CGAffineTransform.identity
                                  self.center = self.superview!.center
                                 }, completion: nil)
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
      spinner.startAnimating()
      self.addSubview(spinner)
      self.addSubview(iv)
      setConstraints(of: iv)
      setConstraints(of: spinner)
        
      let dragger = UIDragInteraction(delegate: self)
      addInteraction(dragger)
      dragger.isEnabled = true
        
      let dropper = UIDropInteraction(delegate: self)
      addInteraction(dropper)
      
        
      openAnim()
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
        
      cv.dragInteractionEnabled = true
      cv.dropDelegate = self
      cv.dragDelegate = self
        
      let cellNib = UINib(nibName: "ZoomCollectionViewCell", bundle: nil)
      cv.register(cellNib, forCellWithReuseIdentifier: "ZoomCollectionViewCell")
     
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





