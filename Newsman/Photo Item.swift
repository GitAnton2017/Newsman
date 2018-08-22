import Foundation
import UIKit
import CoreData
import GameplayKit
import AVKit

class SafeMap<H: Hashable, T>
{
 let isq = DispatchQueue.global(qos: .userInitiated)// Read/Write map access
 
 private var map: [H : T] = [:] //internal map
 
 subscript (key: H) -> T?
 {
  get {return isq.sync {return map[key]}}
  set {isq.async(flags: .barrier) {self.map[key] = newValue}
  }
 }
 
 func filter (predicate: ((key: H, value: T)) -> Bool) -> [H : T]
 {
  return isq.sync {return map.filter(predicate)}
 }
 
 func forEach(body: @escaping ((key: H, value: T)) -> ())
 {
  isq.async(flags: .barrier) {self.map.forEach(body)}
 }
 
 var values: Dictionary<H, T>.Values {return isq.sync {return map.values}}
}

//MARK: ----------------- Single Photo Item Class ----------------

class PhotoItem: NSObject, PhotoItemProtocol
{
    static let videoFormatFile = ".mov"
 
    typealias ImagesCache = NSCache<NSString, UIImage>
    static var imageCacheDict = SafeMap<Int, ImagesCache>()

    static let queue =
    { () -> OperationQueue in
      let queue = OperationQueue()
      queue.qualityOfService = .userInitiated
      return queue
    }()
 
    static let uQueue =
    { () -> OperationQueue in
     let queue = OperationQueue()
     queue.qualityOfService = .utility
     //queue.underlyingQueue = DispatchQueue.global(qos: .userInitiated)
     return queue
    }()
 
    static let sQueue =
    { () -> OperationQueue in
     let queue = OperationQueue()
      queue.qualityOfService = .userInitiated
      //queue.maxConcurrentOperationCount = 10
      //queue.underlyingQueue = DispatchQueue.global(qos: .userInitiated)
     return queue
    }()

    static var taskCount: Int = 0
    static let MaxTask = 40
    //static let cvTimeOut = 1.0
 
    static let cv = NSCondition()
    static let dsQueue = DispatchQueue(label: "Images i/o", qos: .userInitiated)
    static let dsGroup = DispatchGroup()
 
 
    class var docFolder: URL {return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!}
 
    weak var dragSession: UIDragSession?
 
    static let photoItemUTI = "photoitem.newsman"

    var photo: Photo
 
    lazy var date: Date = {photo.date! as Date}()
    lazy var photoSnippet: PhotoSnippet = {photo.photoSnippet!}()
    lazy var id: UUID = {photo.id!}()
    lazy var type: SnippetType = {SnippetType(rawValue: photoSnippet.type!)!}()
 
    var url: URL
    {
      var snippetURL = PhotoItem.docFolder
     
       snippetURL = snippetURL.appendingPathComponent(photoSnippet.id!.uuidString)
       let fileName = id.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
     
       if let photoFolderID = photo.folder?.id?.uuidString
       {
         snippetURL = snippetURL.appendingPathComponent(photoFolderID).appendingPathComponent(fileName)
       }
       else
       {
        snippetURL =  snippetURL.appendingPathComponent(fileName)
       }
     
      return snippetURL
    }
 
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
 
    
    var position: Int16
    {
       get {return photo.position}
       set {photo.position = newValue}
    }
    
 
    
    enum PhotoMOKeys: CodingKey
    {
        case photoURL
    }
    
    func encode(to encoder: Encoder) throws
    {
        var cont = encoder.container(keyedBy: PhotoMOKeys.self)
        try cont.encode(url, forKey: .photoURL)
        
    }

 
 
    
    init(photo : Photo)
    {
        
        self.photo = photo
        super.init()
    }

 
 
    convenience required init(from decoder: Decoder) throws
    {
        let cont = try decoder.container(keyedBy: PhotoMOKeys.self)
        let newPhotoURL = try cont.decode(UUID.self, forKey: .photoURL)
        print (newPhotoURL)
        
        var newPhoto: Photo!
        
        PhotoItem.MOC.performAndWait
        {
            newPhoto = Photo(context: PhotoItem.MOC)
            newPhoto.date = Date() as NSDate
            newPhoto.isSelected = false
            newPhoto.id = UUID()
        }
        
        self.init(photo: newPhoto)
     
    }
 
    convenience init(photoSnippet: PhotoSnippet, image: UIImage, cachedImageWidth: CGFloat, newVideoID: UUID? = nil)
    {
      var newPhoto: Photo!
      let newPhotoID = newVideoID ?? UUID()
        
      PhotoItem.MOC.performAndWait
      {
       newPhoto = Photo(context: PhotoItem.MOC)
       newPhoto.date = Date() as NSDate
       newPhoto.photoSnippet = photoSnippet
       newPhoto.isSelected = false
       newPhoto.id = newPhotoID
       let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
       newPhoto.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
       photoSnippet.addToPhotos(newPhoto)
      }
        
      self.init(photo: newPhoto)
     
      PhotoItem.cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))

      if (newVideoID == nil && SnippetType(rawValue: photoSnippet.type!)! == .photo)
      {
         do
         {
          if let data = UIImagePNGRepresentation(image)
          {
           try data.write(to: self.url, options: [.atomic])
           print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY AT PATH:\n\(self.url.path)")
          }
         }
         catch
         {
          print ("JPEG WRITE ERROR: \(error.localizedDescription)")
         }
       }

    }
 
    class func renderVideoPreview (for videoURL: URL) -> UIImage?
    {
     do
     {
      let asset = AVURLAsset(url: videoURL, options: nil)
      let imgGenerator = AVAssetImageGenerator(asset: asset)
      imgGenerator.appliesPreferredTrackTransform = true
      let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
      let thumbnail = UIImage(cgImage: cgImage)
      return thumbnail
      
     }
     catch let error
     {
      print("**** Error generating thumbnail from video at URL:\n \"\(videoURL.path)\"\n\(error.localizedDescription)")
      return nil
     }
    }
 
   @discardableResult class func cacheThumbnailImage(imageID: String , image: UIImage, width: Int) -> UIImage?
   {
     if let resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
     {
      if let cache = imageCacheDict[width]
      {
       cache.setObject(resizedImage, forKey: imageID as NSString)
       //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)"
      }
      else
      {
       let newImagesCache = ImagesCache()
       newImagesCache.name = "(\(width) x \(width))"
       newImagesCache.setObject(resizedImage, forKey: imageID as NSString)
       imageCacheDict[width] = newImagesCache
       
       //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
      }
     
      return resizedImage
   
     }
     else
     {
      print("IMAGE PROCESSING ERROR!!!!!!!")
      return nil
     }
    }
 
 
 class func cacheThumbnailImage(imageID: String , image: UIImage,  width: Int,
                                with loadContext: ImageContextLoadProtocol? = nil,
                                queue: OperationQueue,
                                completion: @escaping (UIImage?) -> Void)
 {
  if loadContext?.isLoadTaskCancelled ?? false
  {
    print ("Aborted THUMBNAIL")
    completion(nil)
    return
  }
  
  queue.addOperation
  {
   if loadContext?.isLoadTaskCancelled ?? false
   {
    print ("Aborted THUMBNAIL from Queue")
    completion(nil)
    return
   }
   
   if let resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
   {
    if let cache = imageCacheDict[width]
    {
     cache.setObject(resizedImage, forKey: imageID as NSString)
    //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)"
    }
    else
    {
     let newImagesCache = ImagesCache()
     newImagesCache.name = "(\(width) x \(width))"
     newImagesCache.setObject(resizedImage, forKey: imageID as NSString)
     imageCacheDict[width] = newImagesCache
    
    //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
    }
   
    completion(resizedImage)
   }
   else
   {
    completion(nil)
   }
   
  }
  
 }
 
    class func getCachedImage(with imageID: UUID,
                              requiredImageWidth: CGFloat,
                              with loadContext: ImageContextLoadProtocol? = nil,
                              queue: OperationQueue,
                              completion: @escaping (UIImage?) -> Void)
    {
     
        if loadContext?.isLoadTaskCancelled ?? false
        {
         print ("Aborted CASHED")
         completion(nil)
         return
        }
     
        queue.addOperation
        {
           if loadContext?.isLoadTaskCancelled ?? false
           {
            print ("Aborted CASHED from Queue")
            completion(nil)
            return
           }
         
           if let imageCache = imageCacheDict[Int(requiredImageWidth)],
              let cachedImage = imageCache.object(forKey: imageID.uuidString as NSString)
           {
             completion(cachedImage)
             return
           }
           else
           {
             let caches = imageCacheDict.filter
             {pair in
              if pair.key > Int(requiredImageWidth),
                 let _ = pair.value.object(forKey: imageID.uuidString as NSString) {return true} else {return false}
             }
           
            
             if let cache = caches.min(by: {$0.key < $1.key})?.value,
                let biggerImage = cache.object(forKey: imageID.uuidString as NSString)/*,
                let cachedImage = cacheThumbnailImage(imageID: imageID.uuidString, image:
                                                      biggerImage,
                                                      width: Int(requiredImageWidth))*/
                
             {
               cacheThumbnailImage(imageID: imageID.uuidString,
                                   image: biggerImage,
                                   width: Int(requiredImageWidth),
                                   with: loadContext,
                                   queue: queue)
               {cachedImage in
                print("IMAGE RESIZED FROM CACHED IMAGE IN EXISTING CACHE: \(cache.name), SIZE: \(biggerImage.size)")
                completion(cachedImage)
                //return
               }
              
               return //!!!!!!!!!!!
             }
           }
         
          completion(nil)
        }
        
    }
 
    class func getRenderedPreview(with videoID: UUID, from videoURL: URL,
                                  requiredImageWidth: CGFloat,
                                  with loadContext: ImageContextLoadProtocol? = nil,
                                  queue: OperationQueue,
                                  completion: @escaping (UIImage?) -> Void)
    {
     
     if loadContext?.isLoadTaskCancelled ?? false
     {
      print ("Aborted VIDEO")
      completion(nil)
      return
     }
     
     queue.addOperation
     {
        if loadContext?.isLoadTaskCancelled ?? false
        {
         print ("Aborted VIDEO from Queue")
         completion(nil)
         return
        }
      
        if let preview = PhotoItem.renderVideoPreview(for: videoURL)/*,
           let cachedImage = PhotoItem.cacheThumbnailImage(imageID: videoID.uuidString,
                                                           image: preview,
                                                           width: Int(requiredImageWidth))*/
         
        {
         cacheThumbnailImage(imageID: videoID.uuidString,
                             image: preview,
                             width: Int(requiredImageWidth),
                             with: loadContext,
                             queue: queue) {completion($0)}
        }
        else
        {
         print("ERROR OCCURED WHEN PROCESSING VIDEO IMAGE PREVIEW!")
         completion(nil)
        }
       
     } //PhotoItem.queue.addOperation...
     
    }
 
    class func getSavedImage(with imageID: UUID,
                             from url: URL,
                             requiredImageWidth: CGFloat,
                             with loadContext: ImageContextLoadProtocol? = nil,
                             queue: OperationQueue,
                             completion: @escaping (UIImage?) -> Void)
    {
     if loadContext?.isLoadTaskCancelled ?? false
     {
      print ("Aborted SAVED")
      completion(nil)
      return
     }
     
      queue.addOperation
      {
          if loadContext?.isLoadTaskCancelled ?? false
          {
    
           print ("Aborted SAVED from Queue")
           completion(nil)
           return
          }
       
          /* cv.lock()
           while (taskCount >= MaxTask)
           {
             print ("TASK timed out Task Count \(taskCount)")
             cv.wait(/*until: Date() + cvTimeOut*/)
            
           }
       
           taskCount += 1
           cv.unlock()
          */
       
          do
          {
           
               let data = try Data(contentsOf: url)
           
               if let savedImage = UIImage(data: data)/*,
                  let cachedImage = PhotoItem.cacheThumbnailImage(imageID: imageID.uuidString,
                                                                  image: savedImage,
                                                                  width: Int(requiredImageWidth))*/
                
               {
                cacheThumbnailImage(imageID: imageID.uuidString, image: savedImage,
                                    width: Int(requiredImageWidth),
                                    with: loadContext, queue: queue)
                {
                 
                 
                 completion($0)
                 
                }
               
               }
               else
               {
                  print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL!")
                  completion(nil)
               }
      
          }
          catch
          {
              print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
              completion(nil)
          } //do-try-catch...
        
      } //PhotoItem.queue.addOperation...
    } //func getImage(...)
    
   
 //----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM ASYNCRONOUSLY -------------------------------
 //-----------------------------------------------------------------------------------------------------------------
 func getImage(requiredImageWidth: CGFloat, context: ImageContextLoadProtocol? = nil,
               queue: OperationQueue = PhotoItem.queue,
               completion: @escaping (UIImage?) -> Void)
 //-----------------------------------------------------------------------------------------------------------------
 {
  PhotoItem.dsQueue.async//serial queue!... ensure lock MO faults ...
  {
   if context?.isLoadTaskCancelled ?? false
   {
    print ("Aborted MAIN from serial Queue")
    OperationQueue.main.addOperation {completion(nil)}
    return
   }
   
   let photoID = self.id
   let photoURL = self.url
   let type = self.type
    
   PhotoItem.getCachedImage(with: photoID , requiredImageWidth: requiredImageWidth, with: context, queue: queue)
   {image in
    if let image = image
    {
     OperationQueue.main.addOperation {completion(image)}
    }
    else
    {
     switch (type)
     {
      case .photo:
       let savedQueue = queue.qualityOfService == .userInitiated ? queue : PhotoItem.sQueue
       PhotoItem.getSavedImage(with: photoID , from: photoURL,
                               requiredImageWidth: requiredImageWidth,
                               with: context, queue: savedQueue)
       {image in
        /*PhotoItem.cv.lock()
        PhotoItem.taskCount -= 1
        
        print ("TASK finished Task Count \(PhotoItem.taskCount)")
        if PhotoItem.taskCount < PhotoItem.MaxTask {PhotoItem.cv.broadcast()}
        PhotoItem.cv.unlock()*/
        
        OperationQueue.main.addOperation {completion(image)}

       }
      
      case .video:
       
       PhotoItem.getRenderedPreview(with: photoID , from: photoURL,
                                    requiredImageWidth: requiredImageWidth, with: context, queue: queue)
       {image in
        OperationQueue.main.addOperation {completion(image)}
       }
      
      default:
       OperationQueue.main.addOperation {completion(nil)}
     }
    }
   }
  }
 }

 
//MARK: -
 
/***************************************************************************************************************/
func deleteImages()
/***************************************************************************************************************/
{
  PhotoItem.imageCacheDict.forEach{$0.value.removeObject(forKey: self.id.uuidString as NSString)}
  PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: self)
  PhotoItem.deletePhotoItemFromDisk(at: url)
  PhotoItem.MOC.persistAndWait {[weak self] in PhotoItem.MOC.delete(self!.photo)}
}
/***************************************************************************************************************/
 class func deletePhotoItemFromDisk (at url: URL)
/***************************************************************************************************************/
 {
  do
  {
   try FileManager.default.removeItem(at: url)
   print("PHOTO ITEM IMAGE FILE OR FOLDER DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
  }
  catch
  {
   print("ERROR DELETING PHOTO ITEM OR IMAGE FILE AT PATH:\n\(url.path)\n\(error.localizedDescription)")
  }
 }
/***************************************************************************************************************/
 
 //MARK: -
 
/***************************************************************************************************************/
 class func movePhotoItemOnDisk (from sourceURL: URL, to destinationURL: URL)
/***************************************************************************************************************/
 {
  do
  {
   try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
   print("PHOTO ITEM IMAGE FILE OR FOLDER MOVED SUCCESSFULLY TO DESTINATION PATH:\n\(destinationURL.path)")
  }
  catch
  {
   print("ERROR MOVING PHOTO ITEM IMAGE FILE OR FOLDER FROM:\n\(sourceURL.path) TO \(destinationURL.path) \n\(error.localizedDescription)")
  }
 }
/***************************************************************************************************************/
 
//MARK: -
    
/***************************************************************************************************************/
@discardableResult class func movePhotos (from sourcePhotoSnippet: PhotoSnippet,
                                          to destPhotoSnippet: PhotoSnippet) -> [PhotoItem]?
/***************************************************************************************************************/
{
 guard sourcePhotoSnippet !== destPhotoSnippet else {return nil}
 
 if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected && $0.folder == nil}), sourceSelectedPhotos.count > 0
 {
  let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
  let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
  let type = SnippetType(rawValue: sourcePhotoSnippet.type!)!
  

  sourceSelectedPhotos.forEach
  {
    let fileName = $0.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
    let sourcePhotoURL = sourceSnippetURL.appendingPathComponent(fileName)
    let destPhotoURL   =   destSnippetURL.appendingPathComponent(fileName)
   
    movePhotoItemOnDisk(from: sourcePhotoURL, to: destPhotoURL)
  }
  
  MOC.persistAndWait
  {
   sourcePhotoSnippet.removeFromPhotos(NSSet(array: sourceSelectedPhotos))
   destPhotoSnippet.addToPhotos(NSSet(array: sourceSelectedPhotos))
  }
  
  return sourceSelectedPhotos.map{PhotoItem(photo: $0)}
 }
 else
 {
   return nil
 }
}
/***************************************************************************************************************/
    
//MARK: -

/***************************************************************************************************************/
@discardableResult class func unfolderPhotos (from sourcePhotoSnippet: PhotoSnippet,
                                              to destPhotoSnippet: PhotoSnippet) -> [PhotoItem]?
 /***************************************************************************************************************/
{
 if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected && $0.folder != nil && !$0.folder!.isSelected}), sourceSelectedPhotos.count > 0
 {
  
  MOC.persistAndWait
  {
   let type = SnippetType(rawValue: sourcePhotoSnippet.type!)!
   let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
   let destSnippetURL = docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
  
   var nextPhotoFlag = false
   
   for photo in sourceSelectedPhotos
   {
    photo.isSelected = false //!!!!!!!!!
    
    if (nextPhotoFlag) {nextPhotoFlag = false; continue}
    
    guard let photoFolder = photo.folder else
    {
     print("ERROR: Unable to unfolder photo! Photo has no folder in MOC")
     continue
    }
    
    let fileName = photo.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
    let sourceFolderURL = sourceSnippetURL.appendingPathComponent(photoFolder.id!.uuidString)
    let sourcePhotoURL = sourceFolderURL.appendingPathComponent(fileName)
    let destPhotoURL  = destSnippetURL.appendingPathComponent(fileName)
    
    movePhotoItemOnDisk(from: sourcePhotoURL, to: destPhotoURL)
   
    if let content = try? FileManager.default.contentsOfDirectory(atPath: sourceFolderURL.path), content.count == 1
    {
     let singleFileSourceURL = sourceFolderURL.appendingPathComponent(content.first!)
     let singleFileDestinURL = sourceSnippetURL.appendingPathComponent(content.first!)
     
     movePhotoItemOnDisk(from: singleFileSourceURL, to: singleFileDestinURL)
     
     if let singlePhoto = (photo.folder?.photos?.allObjects as? [Photo])?.first(where:
       {$0.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "") == content.first!})
     {
       photo.folder!.removeFromPhotos(singlePhoto)
       deletePhotoItemFromDisk(at: sourceFolderURL)
      
       if (singlePhoto.isSelected) {nextPhotoFlag = true}
      
     }
     else
     {
       print("ERROR: No single photo to remove from folder in MOC")
     }
    }
   
    photo.folder!.removeFromPhotos(photo)
   
   }
  

   if (sourcePhotoSnippet !== destPhotoSnippet)
   {
    sourcePhotoSnippet.removeFromPhotos(NSSet(array: sourceSelectedPhotos))
    destPhotoSnippet.addToPhotos(NSSet(array: sourceSelectedPhotos))
   }
   
   
   (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({($0.photos?.count ?? 0) == 0}).forEach
   {emptyFolder in
    MOC.delete(emptyFolder)
   }
   
  } //MOC.persistAndWait...{}
  
  return sourceSelectedPhotos.map{PhotoItem(photo: $0)}
 }
 else
 {
  return nil
 }
}
/***************************************************************************************************************/

//MARK: -
 
/***************************************************************************************************************/
 @discardableResult class func movePhotos (from sourcePhotoSnippet: PhotoSnippet,
                                           to destPhotoSnippetFolder: PhotoFolder) -> [PhotoItem]?
/***************************************************************************************************************/
 {
   if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected && $0.folder == nil}), sourceSelectedPhotos.count > 0
   {
    MOC.persistAndWait
    {
     
     let destPhotoSnippet = destPhotoSnippetFolder.photoSnippet!
     let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
     let destSnippetURL = docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
     let destFolderURL = destSnippetURL.appendingPathComponent(destPhotoSnippetFolder.id!.uuidString)
     let type = SnippetType(rawValue: sourcePhotoSnippet.type!)!
    
     sourceSelectedPhotos.forEach
     {photo in
      photo.isSelected = false //!!!!!!!!!!!!
      let fileName = photo.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
      let sourcePhotoURL = sourceSnippetURL.appendingPathComponent(fileName)
      let destPhotoURL   =   destFolderURL.appendingPathComponent(fileName)
      movePhotoItemOnDisk(from: sourcePhotoURL, to: destPhotoURL)
     }
   
     if (sourcePhotoSnippet !== destPhotoSnippet)
     {
      sourcePhotoSnippet.removeFromPhotos(NSSet(array: sourceSelectedPhotos))
      destPhotoSnippetFolder.addToPhotos(NSSet(array: sourceSelectedPhotos))
      destPhotoSnippet.addToPhotos(NSSet(array: sourceSelectedPhotos))
     }
     else
     {
      destPhotoSnippetFolder.addToPhotos(NSSet(array: sourceSelectedPhotos))
     }
    }
   
    return sourceSelectedPhotos.map{PhotoItem(photo: $0)}
    
   }
   else
   {
     return nil
   }
 }
 
/***************************************************************************************************************/
 
//MARK: -

/***************************************************************************************************************/
@discardableResult class func moveFolders (from sourcePhotoSnippet: PhotoSnippet,
                                           to destPhotoSnippet: PhotoSnippet) -> [PhotoFolderItem]?
/***************************************************************************************************************/
{
  guard sourcePhotoSnippet !== destPhotoSnippet else {return nil}
 
  if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected}),
         sourceSelectedFolders.count > 0
  {
      let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
      let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
   
      sourceSelectedFolders.forEach
      {
       let sourcePhotoFolderURL = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
       let destPhotoFolderURL   =   destSnippetURL.appendingPathComponent($0.id!.uuidString)
       movePhotoItemOnDisk(from: sourcePhotoFolderURL, to: destPhotoFolderURL)
      }
   
      MOC.persistAndWait
      {
       sourcePhotoSnippet.removeFromFolders(NSSet(array: sourceSelectedFolders))
       sourceSelectedFolders.forEach
       {folder in
        folder.isSelected = false //!!!!!!!!!!!!
        if let folderPhotos = folder.photos?.allObjects as? [Photo]
        {
         sourcePhotoSnippet.removeFromPhotos(NSSet(array: folderPhotos))
         destPhotoSnippet.addToPhotos(NSSet(array: folderPhotos))
         folderPhotos.forEach{$0.isSelected = false} //!!!!!!!!!!!!
        }
       }
       destPhotoSnippet.addToFolders(NSSet(array: sourceSelectedFolders))
      }
   
      return sourceSelectedFolders.map{PhotoFolderItem(folder: $0)}
      
  }
  else
  {
    return nil
  }
}
/***************************************************************************************************************/
                
 //MARK: -
                
/***************************************************************************************************************/
@discardableResult class func moveFolders (from sourcePhotoSnippet: PhotoSnippet,
                                           to destPhotoSnippetFolder: PhotoFolder) -> [PhotoItem]?
/***************************************************************************************************************/
{
 if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected}),
  sourceSelectedFolders.count > 0
 {
  
  let allPhotos = sourceSelectedFolders.reduce([])
  { (result, folder) -> [Photo] in
   if let photos = folder.photos?.allObjects as? [Photo]
   {
    return result + photos
   }
   else
   {
    return result
   }
  }
  let type = SnippetType(rawValue: sourcePhotoSnippet.type!)!
  let destPhotoSnippet = destPhotoSnippetFolder.photoSnippet!
  let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
  let destSnippetURL =  docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
  let destFolderURL = destSnippetURL.appendingPathComponent(destPhotoSnippetFolder.id!.uuidString)
  
  allPhotos.forEach
  {
   let fileName = $0.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
   let sourcePhotoFolderURL = sourceSnippetURL.appendingPathComponent($0.folder!.id!.uuidString)
   let sourcePhotoURL = sourcePhotoFolderURL.appendingPathComponent(fileName)
   let destPhotoURL   =  destFolderURL.appendingPathComponent(fileName)
   movePhotoItemOnDisk(from: sourcePhotoURL, to: destPhotoURL)
   }
  
   sourceSelectedFolders.forEach
   {
    let url = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
    deletePhotoItemFromDisk(at: url)
   }
  
   MOC.persistAndWait
   {
    if (sourcePhotoSnippet !== destPhotoSnippet)
    {
     sourcePhotoSnippet.removeFromPhotos(NSSet(array: allPhotos))
     destPhotoSnippetFolder.addToPhotos(NSSet(array: allPhotos))
     destPhotoSnippet.addToPhotos(NSSet(array: allPhotos))
    }
    else
    {
     destPhotoSnippetFolder.addToPhotos(NSSet(array: allPhotos))
    }
    
    sourceSelectedFolders.forEach
    {folder in
      if let folderPhotos = folder.photos?.allObjects as? [Photo]
      {
       folder.removeFromPhotos(NSSet(array: folderPhotos))
      }
     
      MOC.delete(folder)
    }
 
   }
  
   return allPhotos.map{PhotoItem(photo: $0)}
   
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
  
  if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected})
  {
   sourceSelectedFolders.forEach {$0.isSelected = false}
  }
}



class func getRandomImages3(for photoSnippet: PhotoSnippet, number: Int,
                             requiredImageWidth: CGFloat,
                             loadContext: ImageContextLoadProtocol? = nil,
                             completion: @escaping ([UIImage]?) -> Void)
{
 if loadContext?.isLoadTaskCancelled ?? false
 {
  print ("Aborted getRandomImages3")
  //DispatchQueue.main.async{completion(nil)}
  return
 }
     appDelegate.persistentContainer.performBackgroundTask
     {context in
      
        if loadContext?.isLoadTaskCancelled ?? false
        {
         print ("Aborted getRandomImages3 from BackgroundTask")
         //DispatchQueue.main.async{completion(nil)}
         return
        }
      
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
        let pred = NSPredicate(format: "%K = %@", #keyPath(Photo.photoSnippet), photoSnippet)
        request.predicate = pred
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
      
        do
        {
            let photos = try context.fetch(request)
         
            guard photos.count > 1 else
            {
                //DispatchQueue.main.async{completion(nil)}
                return
            }
         
            var photoItems: [PhotoItem]
            if (number >= photos.count)
            {
                photoItems = photos.map{PhotoItem(photo: $0)}
            }
            else
            {
                var indexSet = Set<Int>()
                let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: photos.count - 1)
                while (indexSet.count < number) {indexSet.insert(arc4rnd.nextInt())}
                photoItems = photos.enumerated().filter{indexSet.contains($0.offset)}.map{PhotoItem(photo: $0.element)}
            }
         
         
            var imageSet = [UIImage]()
         
            //photoItems.forEach
            for photoItem in photoItems
            {/*photoItem in*/
             
              cv.lock()
              let deadline = Date() + 2.5
              while (taskCount >= MaxTask)
              {
               cv.unlock()
               if loadContext?.isLoadTaskCancelled ?? false
               {
                print ("Aborted from  WAIT...")
               // DispatchQueue.main.async{completion(nil)}
                return
               }
               cv.lock()
               
               //print ("TASK timed out Task Count \(taskCount)")
               let flag = cv.wait(until: deadline)
               if !flag {print ("TASK timed out Expired!!!")}
              }
              
              taskCount += 1
             
              cv.unlock()
             
             if loadContext?.isLoadTaskCancelled ?? false
             {
              print ("Aborted after WAIT...")
              //DispatchQueue.main.async{completion(nil)}
              return
             }
            
             dsGroup.enter()
             photoItem.getImage(requiredImageWidth: requiredImageWidth, context: loadContext, queue: uQueue)
             { (image) in
              
                 cv.lock()
                 taskCount -= 1
                 //print ("TASK finished Task Count \(taskCount)")
                 if taskCount < MaxTask {cv.broadcast()}
                 cv.unlock()
              
                 _ = context
                 if let img = image {imageSet.append(img)}
                 dsGroup.leave()
             }
            }
         
            dsGroup.notify(queue: DispatchQueue.main)
            {
                print("PHOTO SNIPPET IMAGE SET LOADED: \"\(photoSnippet.tag ?? "")\",  COUNT - \(imageSet.count)" )
                if imageSet.count < photoItems.count
                {
                 print ("Aborted in NOTIFY GROUP ...")
                 return
                }
             
                completion(imageSet)
             
            }
         
        }
        catch
        {
            let e = error as NSError
            print ("Unresolved error \(e) \(e.userInfo)")
            DispatchQueue.main.async{completion(nil)}
         
        }
      
      
     }
 }
}

//MARK: -
