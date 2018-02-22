import Foundation
import UIKit
import CoreData

//MARK: ---------------- Image Risize Extension ---------------
extension UIImage
//-------------------------------------------------------------
{
    func resized(withPercentage percentage: CGFloat) -> UIImage?
    {
       
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}//extension UIImage....
//-------------------------------------------------------------
//MARK: -

//MARK: ----------------- Photo Item Protocol ----------------
protocol PhotoItemProtocol
//------------------------------------------------------------
{
    var photoSnippet: PhotoSnippet     { get     }
    var date: Date                     { get     }
    var position: Int16                { get set }
    var priority: Int                  { get     }
    var priorityFlag: String?          { get set }
    var isSelected: Bool               { get set }
    var id: UUID                       { get     }
    var url: URL                       { get     }
    
    func deleteImages()

}//protocol PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -

//MARK: ----------------- Photo Item Protocol Extension ----------------
extension PhotoItemProtocol
//----------------------------------------------------------------------
{
    static var appDelegate: AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static func saveContext()
    {
        appDelegate.saveContext()
    }
    
    static var MOC: NSManagedObjectContext
    {
        return appDelegate.persistentContainer.viewContext
    }

}//extension PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -

//MARK: ----------------- Photo Folder Item Class ----------------
class PhotoFolderItem: NSObject, PhotoItemProtocol
//-------------------------------------------------------------
{
//-----------------------------------------
    var folder: PhotoFolder
//-----------------------------------------
    
    var url: URL
    {
      let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
      return snippetURL.appendingPathComponent(id.uuidString)
    }
    
    var id: UUID {return folder.id!}
    
    func deleteImages()
    {
       if let photos = folder.photos
       {
        //remove images from all size caches...
          for photo in photos
          {
            let photoID = (photo as! Photo).id!.uuidString
            for item in PhotoItem.imageCacheDict
            {
              item.value.removeObject(forKey: photoID as NSString)
            }
          }
        
        //delete folder with photos as directory on disk...
        do
        {
          try FileManager.default.removeItem(at: url)
          print("IMAGE FOLDER DIRECTORY DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
        }
        catch
        {
          print("ERROR DELETING IMAGE FOLDER DIRECTORY AT PATH:\n\(url.path)\n\(error.localizedDescription)")
        }
        
        //delete cascade the folder and photos from context and save...
        PhotoFolderItem.MOC.delete(folder)
        PhotoFolderItem.saveContext()
        
       }
    }
    
    var priorityFlag: String?
    {
      get {return folder.priorityFlag}
      set {folder.priorityFlag = newValue}
    }

    var priority: Int {return PhotoPriorityFlags(rawValue: folder.priorityFlag ?? "")?.rateIndex ?? -1}
    
    var date: Date {return folder.date! as Date}
    
    var position: Int16
    {
      get {return folder.position}
      set {folder.position = newValue}
    }
    
    var isSelected: Bool
    {
      get {return folder.isSelected}
      set
      {
        folder.isSelected = newValue
        folder.photos?.forEach{($0 as! Photo).isSelected = newValue}
      }
    }

    var photoSnippet: PhotoSnippet {return folder.photoSnippet!}

    init (folder: PhotoFolder)
    {
      self.folder = folder
      super.init()
    }
    
    convenience init?(photoSnippet: PhotoSnippet)
    {
     if let selectedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected})
     {
      let newFolder = PhotoFolder(context: PhotoFolderItem.MOC)
      self.init(folder: newFolder)
      newFolder.id = UUID()
      newFolder.photoSnippet = photoSnippet
      newFolder.date = Date() as NSDate
      newFolder.isSelected = false
      let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
      newFolder.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
    
      do
      {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        print ("PHOTO SNIPPET NEW PHOTO FOLDER DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(url.path)")
        
        try selectedPhotos.map{PhotoItem(photo: $0)}.forEach
        {
         let newPhotoFolderURL = url.appendingPathComponent($0.id.uuidString)
         try FileManager.default.moveItem(at: $0.url, to: newPhotoFolderURL)
         print("IMAGE FILE MOVED SUCCESSFULLY TO NEW PHOTO FOLDER AT PATH:\n\(newPhotoFolderURL.path)")
        }
      }
      catch
      {
        print("ERROR MOVING IMAGES TO NEW FOLDER:\n \(error.localizedDescription)")
      }
      
      newFolder.addToPhotos(NSSet(array: selectedPhotos))
        
      PhotoFolderItem.saveContext()
     
     }
     else
     {
      return nil
     }
    
    }
    
    class func removeEmptyFolders(from photoSnippet: PhotoSnippet)
    {
      if let emptyFolders = (photoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({($0.photos?.count ?? 0) == 0})
      {
        emptyFolders.map{PhotoFolderItem(folder: $0)}.forEach{$0.deleteImages()}
      }
        
      PhotoFolderItem.saveContext()
    }
    
}
//MARK: -

//MARK: ----------------- Single Photo Item Class ----------------

class PhotoItem: NSObject, PhotoItemProtocol
{
//------------------------------------------
    var photo: Photo
//------------------------------------------
    
    var url: URL
    {
      let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
        
      if let photoFolderID = photo.folder?.id?.uuidString
      {
        return snippetURL.appendingPathComponent(photoFolderID).appendingPathComponent(id.uuidString)
      }
      else
      {
        return snippetURL.appendingPathComponent(id.uuidString)
      }
        
    }
    
    var id: UUID {return photo.id!}
    
    var isSelected: Bool
    {
      get {return photo.isSelected}
      set {photo.isSelected = newValue}
    }
    
    var priorityFlag: String?
    {
      get {return photo.priorityFlag}
      set {photo.priorityFlag = newValue}
    }
    
    var priority: Int {return PhotoPriorityFlags(rawValue: photo.priorityFlag ?? "")?.rateIndex ?? -1}
    
    var date: Date {return photo.date! as Date}
    
    var position: Int16
    {
        get {return photo.position}
        set {photo.position = newValue}
    }
    
    static let queue =
    { () -> OperationQueue in
     let queue = OperationQueue()
     return queue
    }()
    
    typealias ImagesCache = NSCache<NSString, UIImage>
    
    static var imageCacheDict = [Int: ImagesCache]()
    
    var photoSnippet: PhotoSnippet {return photo.photoSnippet!}
    
    init(photo : Photo)
    {
        self.photo = photo
        super.init()
    }
    
    @discardableResult func cacheThumbnailImage(imageID: String, image: UIImage, width: Int) -> UIImage?
    {
        if let resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
        {
            if let cache = PhotoItem.imageCacheDict[width]
            {
             cache.setObject(resizedImage, forKey: imageID as NSString)
             //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)"
            }
            else
            {
             let newImageWidthCache = ImagesCache()
             newImageWidthCache.name = "(\(width) x \(width))"
             /*OperationQueue.main.addOperation
             {
              newImageWidthCache.delegate = PhotoItem.appDelegate
             }*/
        
             newImageWidthCache.setObject(resizedImage, forKey: imageID as NSString)
             PhotoItem.imageCacheDict[width] = newImageWidthCache
             //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
            }
            
            return resizedImage
        }
        else
        {
            print ("IMAGE PROCESSING ERROR...")
            return nil
        }
    }
    
    convenience init(photoSnippet: PhotoSnippet, image: UIImage, cachedImageWidth: CGFloat)
    {
      let newPhoto = Photo(context: PhotoItem.MOC)
      self.init(photo: newPhoto)
        
      let newPhotoID = UUID()
      newPhoto.date = Date() as NSDate
      newPhoto.photoSnippet = photoSnippet
      newPhoto.isSelected = false
      newPhoto.id = newPhotoID
      let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
      newPhoto.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
        
      photoSnippet.addToPhotos(newPhoto)
        
      cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))

      PhotoItem.queue.addOperation
      {
         do
         {
          if let data = UIImagePNGRepresentation(image)
          {
           try data.write(to: self.url, options: [.atomic])
           //print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY AT PATH:\n\(self.photoURL.path)")
          }
         }
         catch
         {
          print ("JPEG WRITE ERROR: \(error.localizedDescription)")
         }
      }

      PhotoItem.saveContext()
        
    }
    
    
//----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM SYNCRONOUSLY --------------------------------
//-----------------------------------------------------------------------------------------------------------------
    func getImage(requiredImageWidth: CGFloat) -> UIImage?
//-----------------------------------------------------------------------------------------------------------------
    {
     if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
        let cachedImage = imageCache.object(forKey: id.uuidString as NSString)
     {
        return cachedImage // if there is an of image of required size in exisisting size cache return it...
     }
     else //otherwise we try to make in from exisiting bigger one in corresponding size cache...
     {
      //filtering caches holding the images with sizes bigger than required...
      let caches = PhotoItem.imageCacheDict.filter
      {pair in
       if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: self.id.uuidString as NSString)
       {return true} else {return false}
      }
        
      if let cache = caches.min(by: {$0.key < $1.key})?.value,//getting the minimum size cache bigger than required image size...
         let biggerImage = cache.object(forKey: id.uuidString as NSString),//has this cache hold required image???
         let newCachedImage = cacheThumbnailImage(imageID: id.uuidString, image: biggerImage, width: Int(requiredImageWidth))
         //if yes try to resize it to required one and if ok with resize we return it...
      {
       return newCachedImage
      }
        
      //otherwise try to load it from disk URL and cache it...
      do
      {
        let data = try Data(contentsOf: url)
        if let savedImage = UIImage(data: data, scale: 1),
           let newCachedImage = cacheThumbnailImage(imageID: id.uuidString, image: savedImage, width: Int(requiredImageWidth))
        {
         return newCachedImage
        }
        else
        {
         print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL!")
         return nil
        }
       }
       catch
       {
         print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
         return nil
       } //do-try-catch...
     } //if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)]...
    } //func getImage(...)
//-----------------------------------------------------------------------------------------------------------------
    
    
    
//----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM ASYNCRONOUSLY -------------------------------
//-----------------------------------------------------------------------------------------------------------------
    func getImage(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
//-----------------------------------------------------------------------------------------------------------------
    {
     PhotoItem.queue.addOperation
     {
       if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
          let cachedImage = imageCache.object(forKey: self.id.uuidString as NSString)
       {
        OperationQueue.main.addOperation {completion(cachedImage)}
        //print("IMAGE LOADED FROM EXISTING CACHE: \(imageCache.name), SIZE: \(cachedImage.size)")
        return
       }
       else
       {
        let caches = PhotoItem.imageCacheDict.filter
        {pair in
          if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: self.id.uuidString as NSString)
          {return true} else {return false}
        }
        
        if let cache = caches.min(by: {$0.key < $1.key})?.value,
           let biggerImage = cache.object(forKey: self.id.uuidString as NSString),
           let cachedImage = self.cacheThumbnailImage(imageID: self.id.uuidString, image: biggerImage, width: Int(requiredImageWidth))
        {
          OperationQueue.main.addOperation{completion(cachedImage)}
          //print("IMAGE RESIZED FROM CACHED IMAGE IN EXISTING CACHE: \(cache.name), SIZE: \(biggerImage.size)")
          return
        }
        //otherwise try to load it from disk URL and cache it...
        
        do
        {
         let data = try Data(contentsOf: self.url)
         if let savedImage = UIImage(data: data, scale: 1),
         let cachedImage = self.cacheThumbnailImage(imageID: self.id.uuidString, image: savedImage, width: Int(requiredImageWidth))
         {
          //print("IMAGE DATA SIZE:\(data.count) bytes LOADED FROM DISK! SIZE: \(savedImage.size)")
          OperationQueue.main.addOperation{completion(cachedImage)}
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
        } //do-try-catch...
        
       } //main if-else...if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)]...
      } //PhotoItem.queue.addOperation...
     } //func getImage(...)
//-----------------------------------------------------------------------------------------------------------------
    
    func deleteImages()
    {
        PhotoItem.MOC.delete(photo)
        for item in PhotoItem.imageCacheDict
        {
          item.value.removeObject(forKey: id.uuidString as NSString)
        }
    
        do
        {
          try FileManager.default.removeItem(at: url)
          print("IMAGE FILE DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
        }
        catch
        {
          print("ERROR DELETING IMAGE FILE AT PATH:\n\(url.path)\n\(error.localizedDescription)")
        }
        
        PhotoItem.saveContext()
    }
    
    @discardableResult
    class func movePhotos (from sourcePhotoSnippet: PhotoSnippet, to destPhotoSnippet: PhotoSnippet) -> [PhotoItem]?
    {
     if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected && $0.folder == nil})
     {
      sourcePhotoSnippet.removeFromPhotos(NSSet(array: sourceSelectedPhotos))
      destPhotoSnippet.addToPhotos(NSSet(array: sourceSelectedPhotos))
        
      let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
      let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
    
      sourceSelectedPhotos.forEach
      {
        $0.isSelected = false
        let sourcePhotoURL = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
        let destPhotoURL   =   destSnippetURL.appendingPathComponent($0.id!.uuidString)
        
        do
        {
          try FileManager.default.moveItem(at: sourcePhotoURL, to: destPhotoURL)
          print("IMAGE FILE MOVED SUCCESSFULLY TO PATH:\n\(destSnippetURL.path)")
        }
        catch
        {
          print("ERROR MOVING IMAGE FILE FROM:\n\(sourcePhotoURL.path) TO \(destSnippetURL.path) \n\(error.localizedDescription)")
        }
      }
      
    
      PhotoItem.saveContext()
        
      return sourceSelectedPhotos.map{PhotoItem(photo: $0)}
        
     }
     else
     {
       return nil
     }
    }
    
    @discardableResult
    class func moveFolders (from sourcePhotoSnippet: PhotoSnippet, to destPhotoSnippet: PhotoSnippet) -> [PhotoFolderItem]?
    {
        if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected})
        {
            sourcePhotoSnippet.removeFromFolders(NSSet(array: sourceSelectedFolders))
            destPhotoSnippet.addToFolders(NSSet(array: sourceSelectedFolders))
            
            let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
            let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
            
            sourceSelectedFolders.forEach
            {
             $0.isSelected = false
             let sourcePhotoURL = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
             let destPhotoURL   =   destSnippetURL.appendingPathComponent($0.id!.uuidString)
                    
             do
             {
                try FileManager.default.moveItem(at: sourcePhotoURL, to: destPhotoURL)
                print("IMAGE FOLDER MOVED SUCCESSFULLY TO PATH:\n\(destSnippetURL.path)")
             }
             catch
             {
                 print("ERROR MOVING IMAGE FOLDER FROM:\n\(sourcePhotoURL.path) TO \(destSnippetURL.path) \n\(error.localizedDescription)")
             }
            }
            
            
            PhotoItem.saveContext()
            
            return sourceSelectedFolders.map{PhotoFolderItem(folder: $0)}
            
        }
        else
        {
            return nil
        }
    }
    
    class func deselectSelectedItems (at sourcePhotoSnippet: PhotoSnippet)
    {
     if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected})
     {
      sourceSelectedPhotos.forEach {$0.isSelected = false}
     }
        
     if let sourceSelectedFolders = (sourcePhotoSnippet.photos?.allObjects as? [PhotoFolder])?.filter({$0.isSelected})
     {
      sourceSelectedFolders.forEach {$0.isSelected = false}
     }
    }
    
}
//MARK: -
