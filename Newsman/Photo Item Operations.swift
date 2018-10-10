
import Foundation
import UIKit
import AVKit



extension PhotoItem
{

 
 static var maxResizeTask = 5
 
 static func clearChainedOperations()
 {
  prevSavedOperations.removeAll()
  prevResizeOperations.removeAll()
  currResizeOperations.removeAll()
  currSavedOperations.removeAll()
 }
 
 fileprivate static var prevResizeOperations: [ResizeImageOperation] = []
 fileprivate static var currResizeOperations: [ResizeImageOperation] = []
 fileprivate static var prevSavedOperations:  [SavedImageOperation ] = []
 fileprivate static var currSavedOperations:  [SavedImageOperation ] = []

 private static func chainOperations (_ saved_op: SavedImageOperation, _ resize_op: ResizeImageOperation)
 {
  if (prevSavedOperations.count == maxResizeTask)
  {
   if (currSavedOperations.count < maxResizeTask)
   {
    prevResizeOperations.forEach{saved_op.addDependency($0)}
    currSavedOperations.append(saved_op)
    currResizeOperations.append(resize_op)
    
//    print ("FORM CURRENT BLOCK")
//    print ("-----------------------------------------------------------")
//    print ("SAVED:");  currSavedOperations.forEach{print("\($0.debugDescription) Dependencies: \($0.dependencies.count)")}
//    print ("RESIZE:"); currResizeOperations.forEach{print("\($0.debugDescription) Dependencies: \($0.dependencies.count)")}
//    print ("-----------------------------------------------------------")
//
   }
   
   if (currSavedOperations.count == maxResizeTask)
   {
   
    prevResizeOperations = currResizeOperations
    currResizeOperations.removeAll()
    
    prevSavedOperations = currSavedOperations
    currSavedOperations.removeAll()
   }
  }
  else
  {
   prevSavedOperations.append(saved_op)
   prevResizeOperations.append(resize_op)
   
//   print ("FORM PREV BLOCK")
//   print ("-----------------------------------------------------------")
//   print ("SAVED:");  prevSavedOperations.forEach{print("\($0.debugDescription) Dependencies: \($0.dependencies.count)")}
//   print ("RESIZE:"); prevResizeOperations.forEach{print("\($0.debugDescription) Dependencies: \($0.dependencies.count)")}
//   print ("-----------------------------------------------------------")
  }
 }
 
 static let contextQ = DispatchQueue(label: "Context.isolation.access", qos: .userInitiated)
 
// static let contextQ =
// { () -> OperationQueue in
//  let queue = OperationQueue()
//  queue.qualityOfService = .userInitiated
//  queue.maxConcurrentOperationCount = 1
//  return queue
// }()
 
 func cancelImageOperation()
 {
  cQ.cancelAllOperations()
//  PhotoItem.contextQ.operations.filter{($0 as? ContextDataOperation)?.photoItem === self}.forEach{$0.cancel()}
 }
 
 func getImageOperation(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
 {
  let context_op = ContextDataOperation()
  context_op.photoItem = self
  
  let cache_op = CachedImageOperation(requiredImageSize: requiredImageWidth)
  cache_op.addDependency(context_op)
  
  let saved_op = SavedImageOperation()
  saved_op.addDependency(context_op)
  saved_op.addDependency(cache_op)
  
  let video_op = RenderVideoPreviewOperation()
  video_op.addDependency(context_op)
  video_op.addDependency(cache_op)
  
  let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
  resize_op.addDependency(saved_op)
  resize_op.addDependency(video_op)
  resize_op.addDependency(cache_op)
  
  PhotoItem.chainOperations(saved_op, resize_op)
 
  let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
  thumbnail_op.addDependency(resize_op)
  thumbnail_op.addDependency(context_op)
  thumbnail_op.addDependency(cache_op)
  
  thumbnail_op.completionBlock =
  {
   guard let finalImage = thumbnail_op.thumbnailImage else {return}
   OperationQueue.main.addOperation
   {
    completion(finalImage)
   }
  }
  
  let operations = [context_op, cache_op, saved_op, video_op, resize_op, thumbnail_op]
  
//  PhotoItem.contextQ.addOperation(context_op)
  
  cQ.addOperations(operations, waitUntilFinished: false)
  //print (cQ.operationCount)
  
 }
 
}

fileprivate protocol CachedImageDataProvider
{
 var cachedImageID: UUID? {get}
}

fileprivate protocol SavedImageDataProvider
{
 var savedImageURL: URL? {get}
 var imageSnippetType: SnippetType? {get}
}

fileprivate protocol VideoPreviewDataProvider
{
 var videoURL: URL? {get}
 var imageSnippetType: SnippetType? {get}
}

fileprivate protocol ResizeImageDataProvider
{
 var imageToResize: UIImage? {get}
}

fileprivate protocol ThumbnailImageDataProvider
{
 var thumbnailImage: UIImage? {get}
}

fileprivate protocol ImageSetDataProvider
{
 var finalImage: UIImage? {get}
}

class ContextDataOperation: Operation, CachedImageDataProvider, SavedImageDataProvider, VideoPreviewDataProvider
{

 var videoURL: URL?      {return photoURL}
 var savedImageURL: URL? {return photoURL}
 var imageSnippetType: SnippetType? {return type}
 
 var cachedImageID: UUID? {return photoID}
 
 var photoItem: PhotoItem? //Input PhotoItem
 
 private var photoID: UUID?
 private var photoURL: URL?
 private var type: SnippetType?
 
 private var cnxObserver: NSKeyValueObservation?
 
 override init()
 {
  super.init()
  cnxObserver = observe(\.isCancelled)
  {op, val in
    if op.isCancelled
    {
     op.dependencies.forEach{op.removeDependency($0)}
     print ("\(op.description) is cancelled!")
    }
  }
 }
 
 override func main()
 {
//  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) IS CANCELLED HERE!!")
   return
  }
  guard let photoItem = self.photoItem else {return}
  
  //PhotoItem.contextQ.sync //This is fucking strong guaranty that MO Context is accessed serially!!!!
  PhotoItem.MOC.performAndWait
  {
   photoID = photoItem.id
   photoURL = photoItem.url
   type = photoItem.type
  }
  
 }
}


class CachedImageOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage? {return outputImage}
 
 private lazy var contextDepend = {dependencies.compactMap{$0 as? CachedImageDataProvider}.first}()
 private var cachedImageID: UUID? {return contextDepend?.cachedImageID}
 
 fileprivate var cachedImage: UIImage?
 private var outputImage: UIImage?
 
 private var width: Int
 
 private var cnxObserver: NSKeyValueObservation?
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  
  super.init()
  
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    op.dependencies.forEach{op.removeDependency($0)}
    print ("\(op.description) is cancelled!")
   }
  }
  
 }
 
 override func main()
 {
//  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) IS CANCELLED HERE!")
   return
  }
  
  guard cachedImage == nil, let ID = cachedImageID?.uuidString else {return}
  cachedImage = PhotoItem.imageCacheDict[width]?.object(forKey: ID as NSString)
  
  if isCancelled
  {
   print ("\(self.description) IS CANCELLED HERE!")
   return
  }
  
  guard cachedImage == nil else {return}
  let caches = PhotoItem.imageCacheDict.filter{$0.key > width && $0.value.object(forKey: ID as NSString) != nil}
  let cache = caches.min(by: {$0.key < $1.key})?.value
  cachedImage = cache?.object(forKey: ID as NSString)
  outputImage = cachedImage
 }
}

class SavedImageOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage?
 {
  get {return savedImage}
  set {savedImage = newValue}
 }
 
 private lazy var contextDepend = {dependencies.compactMap{$0 as? SavedImageDataProvider}.first}()
 private lazy var cachedDepend =  {dependencies.compactMap{$0 as? CachedImageOperation  }.first}()
 
 private var savedImageURL: URL?   {return contextDepend?.savedImageURL}
 private var cachedImage: UIImage? {return cachedDepend?.cachedImage}
 private var type: SnippetType?    {return contextDepend?.imageSnippetType}
 
 private var savedImage: UIImage?
 
 private var cnxObserver: NSKeyValueObservation?
 private var finishObserver: NSKeyValueObservation?
 
 override init()
 {
  super.init()
  
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    print ("\(op.description) is cancelled!")
    op.dependencies.forEach{op.removeDependency($0)}

   }
  }
  
  finishObserver = observe(\.isFinished)
  {op, _ in
   guard op.isFinished else {return}
   
   op.dependencies.forEach{op.removeDependency($0)}
   
   DispatchQueue.main.async
   {
 
    guard let curr_ind = PhotoItem.currSavedOperations.index(of: op) else {return}
    PhotoItem.currSavedOperations.remove(at: curr_ind)
    
    guard let prev_ind = PhotoItem.prevSavedOperations.index(of: op) else {return}
    PhotoItem.prevSavedOperations.remove(at: prev_ind)
   }
  }
  
 }

 override func main()
 {
//  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) IS CANCELLED HERE!")
   return
  }
  
  guard let url = savedImageURL, type == .photo, cachedImage == nil, savedImage == nil else {return}
  
  do
  {
   let data = try Data(contentsOf: url)
   savedImage = UIImage(data: data)
  }
  catch
  {
   print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
  } //do-try-catch...
 }
}

class RenderVideoPreviewOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage? {return previewImage}
 
 private lazy var contextDepend = {dependencies.compactMap{$0 as? VideoPreviewDataProvider}.first}()
 private lazy var cachedDepend =  {dependencies.compactMap{$0 as? CachedImageOperation  }.first}()
 
 private var videoURL: URL?        {return contextDepend?.videoURL}
 private var cachedImage: UIImage? {return cachedDepend?.cachedImage}
 private var type: SnippetType?    {return contextDepend?.imageSnippetType}
 
 private var previewImage: UIImage?
 
 private var cnxObserver: NSKeyValueObservation?
 
 override init()
 {
  super.init()
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    op.dependencies.forEach{op.removeDependency($0)}
    
    print ("\(op.description) is cancelled!")
   }
  }
 }
 
 override func main()
 {
  //  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) IS CANCELLED HERE!")
   return
  }
  
  guard let url = videoURL, type == .video, cachedImage == nil, previewImage == nil else {return}
  
  do
  {
   let asset = AVURLAsset(url: url, options: nil)
   let imgGenerator = AVAssetImageGenerator(asset: asset)
   imgGenerator.appliesPreferredTrackTransform = true
   let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
   previewImage = UIImage(cgImage: cgImage)
   
  }
  catch let error
  {
   print("ERROR, generating thumbnail from video at URL:\n \"\(url.path)\"\n\(error.localizedDescription)")
  }
  
 }
}


class ThumbnailImageOperation: Operation, ImageSetDataProvider
{
 var finalImage: UIImage? {return thumbnailImage}
 
 fileprivate var thumbnailImage: UIImage?
 
 private lazy var thumbnailDepend = {dependencies.compactMap{$0 as? ThumbnailImageDataProvider}.first}()
 private lazy var contextDepend =   {dependencies.compactMap{$0 as? CachedImageDataProvider   }.first}()
 private lazy var cachedDepend =    {dependencies.compactMap{$0 as? CachedImageOperation      }.first}()
 
 var cachedImageID: UUID?   {return contextDepend?.cachedImageID}
 var cachedImage: UIImage?  {return cachedDepend?.cachedImage}
 
 private var width: Int
 
 private var cnxObserver: NSKeyValueObservation?
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
  
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    op.dependencies.forEach{op.removeDependency($0)}
    print ("\(op.description) is cancelled!")
   }
  }
 }
 
 override func main()
 {
//  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX!")
   return
  }
  
  guard let image = thumbnailDepend?.thumbnailImage, let ID = cachedImageID?.uuidString else
  {
   thumbnailImage = cachedImage
   return
  }
  
  thumbnailImage = image
  if let cache = PhotoItem.imageCacheDict[width]
  {
   cache.setObject(image, forKey: ID as NSString)
   //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)"
  }
  else
  {
   let newImagesCache = PhotoItem.ImagesCache()
   newImagesCache.name = "(\(width) x \(width))"
   newImagesCache.setObject(image, forKey: ID as NSString)
   PhotoItem.imageCacheDict[width] = newImagesCache
   
   //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
  }
 }
}

class ResizeImageOperation: Operation, ThumbnailImageDataProvider
{
 var thumbnailImage: UIImage? {return resizedImage}
 
 private var imageToResize: UIImage?
 {
   return dependencies.compactMap{($0 as? ResizeImageDataProvider)?.imageToResize}.first
 }
 
 private var resizedImage: UIImage?
 private var width: Int
 private var cnxObserver: NSKeyValueObservation?
 fileprivate var finishObserver: NSKeyValueObservation?
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
  
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    op.dependencies.forEach{op.removeDependency($0)}
    print ("\(op.description) is cancelled!")
   }
  }
  
  finishObserver = observe(\.isFinished)
  {op, _ in
   guard op.isFinished else {return}
   op.dependencies.forEach{op.removeDependency($0)}
   
   DispatchQueue.main.async
   {
   
     guard let curr_ind = PhotoItem.currResizeOperations.index(of: op) else {return}
     PhotoItem.currResizeOperations.remove(at: curr_ind)
//     print ("\(op) is removed from currResizeOperations as FINISHED")
    
     guard let prev_ind = PhotoItem.prevResizeOperations.index(of: op) else {return}
     PhotoItem.prevResizeOperations.remove(at: prev_ind)
//     print ("\(op) is removed from prevResizeOperations as FINISHED")
    
   }
  }
  
 }
 
 override func main()
 {
//  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX!")
   return
  }
  guard let image = imageToResize else {return}
  resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
  
  dependencies.compactMap({$0 as? SavedImageOperation}).first?.imageToResize = nil
 }
}

class ImageSetOperation: Operation
{
 var imageSet: [UIImage]?
 
 private var cnxObserver: NSKeyValueObservation?
 
 override init()
 {
  super.init()
  cnxObserver = observe(\.isCancelled)
  {op, val in
   if op.isCancelled
   {
    op.dependencies.forEach{op.removeDependency($0)}
    print ("\(op.description) is cancelled!")
   }
  }
 }
 
 override func main()
 {
  imageSet = dependencies.compactMap{($0 as? ImageSetDataProvider)?.finalImage}
 }
 
 
}


