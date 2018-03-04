
import Foundation
import UIKit
import CoreData
import MobileCoreServices

extension PhotoFolderItem
{
    enum UTIError : Error
    {
        case UnknownType
    }
    static var writableTypeIdentifiersForItemProvider: [String]
    {
        return [kUTTypeJPEG as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
    {
        switch typeIdentifier
        {
         case kUTTypeJPEG as String as String:
            
             var imageSet: [UIImage] = []
             singlePhotoItems?.forEach
             {photoItem in
                    do
                    {
                        print("******************************************************************************")
                        print ("ATTEMPT OF READING IMAGE FOR DRAG AND DROP FROM PHOTO FOLDER URL : \n \(url.path)...")
                        print("******************************************************************************")
                        
                        let data = try Data(contentsOf: photoItem.url)
                        if let image = UIImage(data: data, scale: 1)
                        {
                          imageSet.append(image)
                        }
                
                        
                    }
                    catch
                    {
                        print("******************************************************************************")
                        print("ERROR OCCURED WHEN READING IMAGE DATA FROM PHOTO FOLDER URL!\n\(error.localizedDescription)")
                        print("******************************************************************************")
                        completionHandler(nil, error)
                        return
                        
                    } //do-try-catch...
                
                
             }
             let irf = UIGraphicsImageRendererFormat.default()
             irf.scale = 1
             let w = imageSet.map{$0.size.width}.max() ?? 0
             let h = imageSet.map{$0.size.height}.reduce(0, {$0 + $1})
        
             let ir = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: irf)
             
             let data = ir.jpegData(withCompressionQuality: 0.5)
             {_ in
              var y: CGFloat = 0.0
              imageSet.forEach
              {image in
                image.draw(at: CGPoint(x: 0, y: y));  y += image.size.height
              }
            
             }
             
             completionHandler(data, nil)
            
            
        default: completionHandler(nil, UTIError.UnknownType)
            
       }
        
                    return nil
    }
    
    
} //extension PhotoItem: NSItemProviderWriting...


extension PhotoItem
{
    enum UTIError : Error
    {
        case UnknownType
    }
    static var writableTypeIdentifiersForItemProvider: [String]
    {
        return [kUTTypeJPEG as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
    {
        switch typeIdentifier
        {
         case kUTTypeJPEG as String as String:
            
            
                    do
                    {
                        print("******************************************************************************")
                        print ("ATTEMPT OF READING IMAGE FOR DRAG AND DROP FROM URL : \n \(url.path)...")
                        print("******************************************************************************")
                        
                        let data = try Data(contentsOf: self.url)
                        completionHandler(data, nil)
                        
                    }
                    catch
                    {
                        print("******************************************************************************")
                        print("ERROR OCCURED WHEN READING IMAGE DATA FOR DRAG AND DROP FROM URL!\n\(error.localizedDescription)")
                        print("******************************************************************************")
                        completionHandler(nil, error)
                        
                    } //do-try-catch...
                    

            
         default: completionHandler(nil, UTIError.UnknownType)
            
        }
        
        return nil
    }
    
    
} //extension PhotoItem: NSItemProviderWriting...


