
import Foundation
import UIKit
import CoreData

class LayerDelegate: NSObject, CALayerDelegate
{
    func draw(_ layer: CALayer, in ctx: CGContext)
    {
        ctx.beginPath()
        
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 0, y: layer.bounds.height)
        let p3 = CGPoint(x: layer.bounds.width/2, y: layer.bounds.height * 0.75)
        let p4 = CGPoint(x: layer.bounds.width, y: layer.bounds.height)
        let p5 = CGPoint(x: layer.bounds.width, y: 0)
         
        ctx.addLines(between: [p1,p2,p3,p4,p5])
        ctx.setFillColor(UIColor.red.cgColor)
        ctx.closePath()
        
        ctx.fillPath()
        
    }
}
extension PhotoSnippetViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
      return photoItems.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
      
      cell.photoIconView.alpha = photoItems[indexPath.row].photo.isSelected ? 0.5 : 1
    
      cell.photoIconView.layer.cornerRadius = 10.0
      cell.photoIconView.layer.borderWidth = 1
      cell.photoIconView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
      cell.photoIconView.layer.masksToBounds = true
        
      let flagLayer = CALayer()
      flagLayer.delegate = (UIApplication.shared.delegate as! AppDelegate).layerDelegate
        
      flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
      flagLayer.contentsScale = UIScreen.main.scale
        
      if let prevFlagLayer = cell.photoIconView.layer.sublayers?.first
      {
       cell.photoIconView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
      }
      else
      {
       cell.photoIconView.layer.addSublayer(flagLayer)
      }
        
      flagLayer.display()
    

      photoItems[indexPath.row].getImage(requiredImageWidth:  imageSize)
      {(image) in
        
    
       cell.photoIconView.image = image

       cell.photoIconView.layer.contentsGravity = kCAGravityResizeAspect
        
       if let img = image
       {
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
