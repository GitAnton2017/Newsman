
import Foundation
import UIKit

//MARK: ---------------- Image Risize Extension ---------------
extension UIImage
//-------------------------------------------------------------
{
    func resized(withPercentage percentage: CGFloat) -> UIImage?
    {
    
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = UIGraphicsImageRendererFormat.default()
        //format.scale = 1
        format.preferredRange = .extended
        let render = UIGraphicsImageRenderer(size: canvasSize, format: format)
        let image = render.image
        {_ in
            
            draw(in: CGRect(origin: .zero, size: canvasSize))
        }
        return image
        
        
        /*UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
         defer { UIGraphicsEndImageContext() }
         draw(in: CGRect(origin: .zero, size: canvasSize))
         return UIGraphicsGetImageFromCurrentImageContext()*/
    }
 
    func resized(withPercentage percentage: CGFloat,
                 with loadContext: ImageContextLoadProtocol? = nil,
                 queue: OperationQueue,
                 completion: @escaping (UIImage?) -> Void)
    {
     if loadContext?.isLoadTaskCancelled ?? false
     {
      print ("Aborted UIImage Resized")
      completion(nil)
      return
     }
     
     queue.addOperation
     {
      if loadContext?.isLoadTaskCancelled ?? false
      {
       print ("Aborted UIImage Resized from Queue")
       completion(nil)
       return
      }
      
      let canvasSize = CGSize(width: self.size.width * percentage, height: self.size.height * percentage)
      let format = UIGraphicsImageRendererFormat.default()
      //format.scale = 1
      //format.prefersExtendedRange = false
      let render = UIGraphicsImageRenderer(size: canvasSize, format: format)
      let image = render.image {_ in self.draw(in: CGRect(origin: .zero, size: canvasSize))}
      completion(image)
     
     }
     
    }
 
 
    func setSquared (in view: UIView)
    {
        view.layer.contentsGravity = CALayerContentsGravity.resizeAspect
        
        if size.height > size.width
        {
            let r = size.width/size.height
            view.layer.contentsRect = CGRect(x: 0, y: (1 - r)/2, width: 1, height: r)
        }
        else if size.height < size.width
        {
            let r = size.height/size.width
            view.layer.contentsRect = CGRect(x: (1 - r)/2, y: 0, width: r, height: 1)
        }
    }
    
}//extension UIImage....
//-------------------------------------------------------------
//MARK: -

