import Foundation
import UIKit
import CoreData

extension UIImage
{
    func resized(withPercentage percentage: CGFloat) -> UIImage?
    {
       
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
   
}
class PhotoItem: NSObject
{
    static let queue =
    { () -> OperationQueue in
     let queue = OperationQueue()
     return queue
    }()
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let moc = appDelegate.persistentContainer.viewContext
    
    static var imageCacheDict = [Int: NSCache<NSString, UIImage>]()
    
    var photo: Photo
    
    var photoSnippet: PhotoSnippet
    {
      get
      {
        return photo.photoSnippet!
      }
    }
    
    var photoID: String
    {
      get
      {
        return photo.id!.uuidString
      }
    }
    
    var photoURL: URL
    {
      get
      {
        let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
        return snippetURL.appendingPathComponent(photoID)
      }
    }
    
    init(photo : Photo)
    {
        self.photo = photo
        super.init()
    }
    
    @discardableResult func cacheThumbnailImage(imageID: String, image: UIImage, width: Int) -> UIImage?
    {
        if let res_img = image.resized(withPercentage: CGFloat(width)/image.size.width)
        {
            if let cache = PhotoItem.imageCacheDict[width]
            {
                cache.setObject(res_img, forKey: imageID as NSString)
                //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)")
            }
            else
            {
                let newImageWidthCache = NSCache<NSString, UIImage>()
                newImageWidthCache.name = "(\(width) x \(width))"
                newImageWidthCache.delegate = PhotoItem.appDelegate
                newImageWidthCache.setObject(res_img, forKey: imageID as NSString)
                PhotoItem.imageCacheDict[width] = newImageWidthCache
                //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
            }
            
            return res_img
        }
        else
        {
            print ("IMAGE PROCESSING ERROR...")
            return nil
        }
    }
    
    convenience init(photoSnippet: PhotoSnippet, image: UIImage, cachedImageWidth: CGFloat)
    {
      let newPhoto = Photo(context: PhotoItem.moc)
      let newPhotoID = UUID()
      newPhoto.date = Date() as NSDate
      newPhoto.photoSnippet = photoSnippet
      newPhoto.id = newPhotoID
      photoSnippet.addToPhotos(newPhoto)
        
      self.init(photo: newPhoto)
        
      cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))

      PhotoItem.queue.addOperation
      {
         do
         {
          if let data = UIImagePNGRepresentation(image)
          {
           try data.write(to: self.photoURL, options: [.atomic])
           //print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY AT PATH:\n\(self.photoURL.path)")
          }
         }
         catch
         {
          print ("JPEG WRITE ERROR: \(error.localizedDescription)")
         }
      }

      PhotoItem.appDelegate.saveContext()
        
    }
    
    func getImage(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
    {
     
     PhotoItem.queue.addOperation
     {
       if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
          let cachedImage = imageCache.object(forKey: self.photoID as NSString)
       {
        OperationQueue.main.addOperation
        {
          completion(cachedImage)
        }
        //print("IMAGE LOADED FROM EXISTING CACHE: \(imageCache.name), SIZE: \(cachedImage.size)")
        return
       }
       else
       {
        let caches = PhotoItem.imageCacheDict.filter
        {pair in
          if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: self.photoID as NSString)
          {
            return true
          }
          else
          {
            return false
          }
        }
        if let cache = caches.min(by: {$0.key < $1.key})?.value, let biggerImage = cache.object(forKey: self.photoID as NSString)
        {
            OperationQueue.main.addOperation
            {
             let cachedImage = self.cacheThumbnailImage(imageID: self.photoID, image: biggerImage, width: Int(requiredImageWidth))
              completion(cachedImage)
            }
            
            //print("IMAGE RESIZED FROM CACHED IMAGE IN EXISTING CACHE: \(cache.name), SIZE: \(biggerImage.size)")
            
            return
        }
    
       }
     
        do
        {
         let data = try Data(contentsOf: self.photoURL)
         if let savedImage = UIImage(data: data, scale: 1)
         {
          //print("IMAGE DATA SIZE:\(data.count) bytes LOADED FROM DISK! SIZE: \(savedImage.size)")
          OperationQueue.main.addOperation
          {
           let cachedImage = self.cacheThumbnailImage(imageID: self.photoID, image: savedImage, width: Int(requiredImageWidth))
           completion(cachedImage)
          }
         }
         else
         {
          print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL!")
          OperationQueue.main.addOperation{completion(nil)}
         }
        }
        catch
        {
          print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
          OperationQueue.main.addOperation{completion(nil)}
        }
      }
      
    
     } //func getImage(...)

    
    func deleteImage()
    {
        PhotoItem.moc.delete(photo)
        
        for item in PhotoItem.imageCacheDict
        {
          item.value.removeObject(forKey: photoID as NSString)
        }
    
        do
        {
          try FileManager.default.removeItem(at: photoURL)
          print("IMAGE FILE DELETED SUCCESSFULLY AT PATH:\n\(photoURL.path)")
        }
        catch
        {
          print("ERROR DELETING IMAGE FILE AT PATH:\n\(photoURL.path)\n\(error.localizedDescription)")
        }
        
        PhotoItem.appDelegate.saveContext()
    }
    
}
