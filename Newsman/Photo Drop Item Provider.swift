
import Foundation
import UIKit
import CoreData
import MobileCoreServices

extension PhotoFolderItem
{
    func getPhotoRect (photoSize: CGSize) -> CGRect
    {
      let rx = PDFContextSize.width
      let ry = PDFContextSize.height
        
      let w = photoSize.width
      let h = photoSize.height
      
      if (w <= rx && h <= ry)
      {
        return CGRect(x: (rx - w) / 2, y: (ry - h) / 2, width: w, height: h)
      }
      else if (rx/ry < w/h)
      {
        let l = h * rx / w
        return CGRect(x: 0, y: (ry - l) / 2, width: rx, height: l)
      }
      else if (rx/ry > w/h)
      {
        let l = h * rx / w
        return CGRect(x: (rx - l) / 2, y: 0, width: l, height: ry)
      }
      else
      {
        return CGRect(x: 0, y: 0, width: rx, height: ry)
      }
     
    }
    enum UTIError : Error
    {
        case UnknownType
    }
    static var writableTypeIdentifiersForItemProvider: [String]
    {
        return [folderItemUTI, kUTTypePDF as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
    {
        switch typeIdentifier
        {
         case kUTTypePDF as String as String:
            
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
             /*let irf = UIGraphicsImageRendererFormat.default()
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
            
             }*/
             
             /*if let aniImage = UIImage.animatedImage(with: imageSet, duration: 1)
             {
              let data = UIImagePNGRepresentation(aniImage)
              completionHandler(data, nil)
             }
             else
             {
               completionHandler(nil, UTIError.UnknownType)
             }*/
            
             let PDFRendSize = CGRect(origin: CGPoint.zero, size: PDFContextSize)
             let PDFRend = UIGraphicsPDFRenderer(bounds: PDFRendSize)
             let PDFData = PDFRend.pdfData
             {context in
                imageSet.forEach
                {image in
                 context.beginPage()
                 let drawRect = getPhotoRect(photoSize: image.size)
                 image.resized(withPercentage: 0.3)?.draw(in: drawRect)
                    
                }
             }
             
             completionHandler(PDFData, nil)
            
        case PhotoFolderItem.folderItemUTI:
            
            do
            {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(self)
                completionHandler(data, nil)
            }
            catch
            {
                completionHandler(nil, error)
                
            } //do-try-catch...
            
        default: completionHandler(nil, UTIError.UnknownType)
            
       }
        
      return nil
    }
    
    static var readableTypeIdentifiersForItemProvider: [String]
    {
        return [folderItemUTI]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
    {
       switch typeIdentifier
       {
        case folderItemUTI:
            
            do
            {
                let decoder = PropertyListDecoder()
                let item = try decoder.decode(self, from: data)
                return item
            }
            catch
            {
                throw error
                
            } //do-try-catch...
            
        default: throw UTIError.UnknownType
       }
        
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
        return [photoItemUTI, kUTTypeJPEG as String]
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
           

         case PhotoItem.photoItemUTI:
            
           do
           {
               let encoder = PropertyListEncoder()
               let data = try encoder.encode(self)
               completionHandler(data, nil)
           }
           catch
           {
               completionHandler(nil, error)
            
           } //do-try-catch...
        
           
            
         default: completionHandler(nil, UTIError.UnknownType)
            
        }
        
        return nil
    }
    
    static var readableTypeIdentifiersForItemProvider: [String]
    {
      return [photoItemUTI]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
    {
        switch typeIdentifier
        {
          case photoItemUTI:
            
            do
            {
                let decoder = PropertyListDecoder()
                let item = try decoder.decode(self, from: data)
                return item
            }
            catch
            {
                throw error
                
            } //do-try-catch...
        
          default: throw UTIError.UnknownType
        }
        
    }
    
    
} //extension PhotoItem: NSItemProviderWriting...


