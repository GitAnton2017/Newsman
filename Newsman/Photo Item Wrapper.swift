


import Foundation
import UIKit
import CoreData
import GameplayKit
import AVKit
import protocol RxSwift.Disposable
import Combine


//MARK: ----------------- Single Photo Managed Object Wrapper Class ----------------

final class PhotoItem: NSObject, PhotoItemProtocol
{

 deinit
 {
 //  print ("PhotoItem \(String(describing: id)) destroyed ", #function)
  cancellAllStateSubscriptions()
 }
 
 @Published final var hostingCollectionViewCell: PhotoSnippetCellProtocol?
 
 final var hostingCollectionViewCellPublisher: AnyPublisher<PhotoSnippetCellProtocol?, Never>
 {
  $hostingCollectionViewCell.eraseToAnyPublisher()
 }
 
 //the CV cell that is currently displaying this PhotoItem visual content
 
 @Published final var hostingZoomedCollectionViewCell: ZoomViewCollectionViewCell?
 //the cell of ZoomView CV that is currently displaying this PhotoItem visual content of zoomed PhotoFolder
 
 final var cellImageUpdateSubscription                   : AnyCancellable? 

 final var cellRowPositionChangeSubscription             : AnyCancellable?
 final var cellPriorityFlagChangeSubscription            : AnyCancellable?
 
 final var cellDragProceedSubscription                   : AnyCancellable?
 final var cellDragLocationSubscription                  : AnyCancellable?
 final var cellDropProceedSubscription                   : AnyCancellable?
 
 final var cellNewItemStateSubscription                  : AnyCancellable?
 
 final var zoomedCellRowPositionChangeSubscription       : AnyCancellable?
 final var zoomedCellPriorityFlagChangeSubscription      : AnyCancellable?
 
 final var zoomedCellDragProceedSubscription             : AnyCancellable?
 final var zoomedCellDropProceedSubscription             : AnyCancellable?
 final var zoomedCellDragLocationSubscription            : AnyCancellable?
 
 
 var isArrowMenuShowing: Bool
 {
  get { photo.isArrowMenuShowing }
  set { photo.managedObjectContext?.perform { self.photo.isArrowMenuShowing = newValue } }
 }
 
 var arrowMenuTouchPoint: CGPoint
 {
  get { (photo.arrowMenuTouchPoint as? CGPoint) ?? .zero }
  set
  {
   photo.managedObjectContext?.perform //NO SAVE CONTEXT
   {
    if CGRect(x: 0, y: 0, width: 1, height: 1).insetBy(dx: 0.1, dy: 0.1).contains(newValue)
    {
     self.photo.arrowMenuTouchPoint = newValue as NSValue
     self.photo.isArrowMenuShowing = true
    }
   }
  }
 } //var arrowMenuTouchPoint: CGPoint...
 
 final var arrowMenuPosition: CGPoint
 {
  get { (photo.arrowMenuPosition as? CGPoint) ?? CGPoint(x: 0.75, y: 0.75) }
  set { photo.managedObjectContext?.perform{ self.photo.arrowMenuPosition = newValue as NSValue} }
 }
 
 final weak var zoomView: ZoomView?

 override func isEqual(_ object: Any?) -> Bool
 {
  photo.objectID == (object as? PhotoItem)?.photo.objectID
 }

 override var hash: Int
 {
  var hasher = Hasher()
  hasher.combine(photo)
  return hasher.finalize()
 }


 func cancelImageOperations() { cQ?.cancelAllOperations() }

 var dragAnimationCancelWorkItem: DispatchWorkItem?
 // the strong ref to work item responsible for cancellation of self draggable visual state.

 static let videoFormatFile = ".mov"

 typealias ImagesCache = NSCache<NSString, UIImage>

 static var imageCacheDict = SafeMap<Int, ImagesCache>()

 static let queue =
 { () -> OperationQueue in
   let queue = OperationQueue()
   queue.qualityOfService = .userInitiated
   return queue
 }()

// lazy var cQ =
// { () -> OperationQueue in
//  let queue = OperationQueue()
//  queue.qualityOfService = .userInitiated
//  return queue
// }()

 weak var cQ: OperationQueue?
 {
  didSet { oldValue?.cancelAllOperations() }
 }

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


 class var docFolder: URL
 {
  return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 }

 weak var dragSession: UIDragSession?

 static let photoItemUTI = "photoitem.newsman"

 var photo: Photo //wrapped managed object of photo

 var hostedManagedObject: NSManagedObject { return photo }
 //getter for using in Draggable protocol to get wrapped MO

 var photoManagedObject: PhotoItemManagedObjectProtocol { photo }

 var date: Date { photo.date! as Date}

 var photoSnippet: PhotoSnippet? { photo.photoSnippet }
 //PhotoSnippet managed object which owns this photo.
 //Photo maneged object must have a PhotoSnippet not to be NIL otherwise photo is assumed to be deleted from MOC!

 var id:   UUID?        {  photo.id   }  //UUID of this photo which must be not NIL!
 var type: SnippetType? {  photo.type }  //Snippet type of managed object which owns this photo.
 var url:  URL?         {  photo.url  }  //Image of video data file url on disk...

 var sectionIndex: Int     { photo.sectionIndex }
 var rowPosition:  Int     { photo.rowPosition }
 var sectionTitle: String? { photo.sectionTitle }

 
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
  configueAllStateSubscriptions()
  
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
  
   PhotoItem.cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))
  
   PhotoItem.MOC.persistAndWait
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
  

   if (newVideoID == nil && SnippetType(rawValue: photoSnippet.type!)! == .photo)
   {
     do
     {
      if let data = image.pngData(), let photoURL = self.url
      {
       try data.write(to: photoURL, options: [.atomic])
       print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY AT PATH:\n\(photoURL.path)")
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
   let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
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
   
   guard let photoID = self.id else { return }
   guard let photoURL = self.url else { return }
   guard let type = self.type else { return }
    
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
 @discardableResult class func deletePhotoItemFromDisk (at url: URL) -> Bool
/***************************************************************************************************************/
 {
  do
  {
   try FileManager.default.removeItem(at: url)
   print("PHOTO ITEM IMAGE FILE OR FOLDER DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
   return true
  }
  catch
  {
   print("ERROR DELETING PHOTO ITEM OR IMAGE FILE AT PATH:\n\(url.path)\n\(error.localizedDescription)")
   return false
  }
 }
/***************************************************************************************************************/
 
 //MARK: -
 
 /***************************************************************************************************************/
 class func deletePhotoItemFromDisk (at url: URL, completion: @escaping (Bool) ->())
 /***************************************************************************************************************/
 {
  DispatchQueue.global(qos: .userInitiated).async
  {
   do
   {
    try FileManager.default.removeItem(at: url)
    print("PHOTO ITEM IMAGE FILE OR FOLDER DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
    completion(true)
   }
   catch
   {
    print("ERROR DELETING PHOTO ITEM OR IMAGE FILE AT PATH:\n\(url.path)\n\(error.localizedDescription)")
    completion(false)
   }
  }
 }
 /***************************************************************************************************************/
 
 //MARK: -
/***************************************************************************************************************/
 @discardableResult class func movePhotoItemOnDisk (from sourceURL: URL, to destinationURL: URL) -> Bool
/***************************************************************************************************************/
 {
  do
  {
   try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
   print("PHOTO ITEM IMAGE FILE OR FOLDER MOVED SUCCESSFULLY TO DESTINATION PATH:\n\(destinationURL.path)")
   return true
  }
  catch
  {
   print("ERROR MOVING PHOTO ITEM IMAGE FILE OR FOLDER FROM:\n\(sourceURL.path) TO \(destinationURL.path) \n\(error.localizedDescription)")
   return false
  }
 }
/***************************************************************************************************************/
 
//MARK: -
 
 /***************************************************************************************************************/
 class func movePhotoItemOnDisk (from sourceURL: URL, to destinationURL: URL, completion: @escaping (Bool) ->())
 /***************************************************************************************************************/
 {
  DispatchQueue.global(qos: .userInitiated).async
  {
   do
   {
    try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
    print("PHOTO ITEM IMAGE FILE OR FOLDER MOVED SUCCESSFULLY TO DESTINATION PATH:\n\(destinationURL.path)")
    completion(true)
   }
   catch
   {
    print("ERROR MOVING PHOTO ITEM IMAGE FILE OR FOLDER FROM:\n\(sourceURL.path) TO \(destinationURL.path) \n\(error.localizedDescription)")
    completion(false)
   }
  }
 }
 /***************************************************************************************************************/
}

//MARK: -
