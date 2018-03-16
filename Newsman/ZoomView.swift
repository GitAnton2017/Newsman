
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
    
    func openAnim()
    {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations:
                       {[unowned self] in
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
      openAnim()
      return iv
      
    }
    
    func openWithCV (in mainView: UIView) -> UICollectionView
    {
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
      let cellNib = UINib(nibName: "ZoomCollectionViewCell", bundle: nil)
      cv.register(cellNib, forCellWithReuseIdentifier: "ZoomCollectionViewCell")
      
      self.addSubview(cv)
      setConstraints(of: cv)
       
      openAnim()
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



extension ZoomView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize
    {
      return CGSize(width: imageSize, height: imageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        let fl = collectionViewLayout as! UICollectionViewFlowLayout
        let w = collectionView.bounds.width
        let li = fl.sectionInset.left
        let ri = fl.sectionInset.right
        let s  = fl.minimumInteritemSpacing
        
        let wr = (w - li - ri - s * CGFloat(nphoto - 1)).truncatingRemainder(dividingBy: CGFloat(nphoto)) / CGFloat(nphoto - 1)
        
        return s + wr
        
    }
   
    
}
extension ZoomView:  UICollectionViewDataSource
{
    
    var imageSize: CGFloat
    {
      let w = self.bounds.width
      let cv = self.subviews.first as! UICollectionView
      let fl = cv.collectionViewLayout as! UICollectionViewFlowLayout
      let li = fl.sectionInset.left
      let ri = fl.sectionInset.right
      let s = fl.minimumInteritemSpacing
        
      let size = (w - li - ri - s * CGFloat(nphoto - 1)) / CGFloat(nphoto)
        
      return trunc(size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        // print ("LOADING FOLDER CELL WITH IP - \(indexPath)")
        // print ("VISIBLE CELLS: \(collectionView.visibleCells.count)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomCollectionViewCell", for: indexPath) as! ZoomViewCollectionViewCell
        
        let photoItem = photoItems[indexPath.row]
        cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
        
        cell.photoIconView.layer.cornerRadius = ceil(7 * (1 - 1/exp(CGFloat(nphoto) / 5)))
        
        photoItem.getImage(requiredImageWidth:  imageSize)
        {(image) in
            cell.photoIconView.image = image
            cell.photoIconView.layer.contentsGravity = kCAGravityResizeAspect
            
            if let img = image
            {
                // print ("IMAGE LOADED FOR CELL WITH IP - \(indexPath)")
                if img.size.height > img.size.width
                {
                    
                    let r = img.size.width/img.size.height
                    cell.photoIconView.layer.contentsRect = CGRect(x: 0, y: (1 - r)/2, width: 1, height: r)
                    
                    
                }
                else
                {
                    
                    let r = img.size.height/img.size.width
                    cell.photoIconView.layer.contentsRect = CGRect(x: (1 - r)/2, y: 0, width: r, height: 1)
                    
                    
                }
            }
            
            cell.spinner.stopAnimating()
        }
        
        
        return cell
    }
    
}
