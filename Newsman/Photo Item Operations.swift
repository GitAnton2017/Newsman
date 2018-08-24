
import Foundation
import UIKit

extension PhotoItem
{
 static let contextQ =
 { () -> OperationQueue in
  let queue = OperationQueue()
  queue.qualityOfService = .userInitiated
  queue.maxConcurrentOperationCount = 1
  return queue
 }()
 
 func getImageOperation(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
 {
  let context_op = ContextDataOperation()
  context_op.photoItem = self
  
  let cache_op = CachedImageOperation(requiredImageSize: requiredImageWidth)
  cache_op.addDependency(context_op)
  
  let save_op = SavedImageOperation()
  save_op.addDependency(context_op)
  save_op.addDependency(cache_op)
  
  let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
  resize_op.addDependency(save_op)
  resize_op.addDependency(cache_op)
  
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
  let operations = [cache_op, save_op, resize_op, thumbnail_op]
  
  PhotoItem.contextQ.addOperation(context_op)
  
  cQ.addOperations(operations, waitUntilFinished: false)
  
 }
 
}

protocol CachedImageDataProvider
{
 var cachedImageID: UUID? {get}
}

protocol SavedImageDataProvider
{
 var savedImageID: UUID? {get}
 var savedImageURL: URL? {get}
 var imageSnippetType: SnippetType? {get}
}

protocol ResizeImageDataProvider
{
 var imageToResize: UIImage? {get}
}

protocol ThumbnailImageDataProvider
{
 var thumbnailImage: UIImage? {get}
}

class ContextDataOperation: Operation, CachedImageDataProvider, SavedImageDataProvider
{
 var savedImageID: UUID? {return photoID}
 var savedImageURL: URL? {return photoURL}
 var imageSnippetType: SnippetType? {return type}
 
 var cachedImageID: UUID? {return photoID}
 
 var photoItem: PhotoItem? //Input PhotoItem
 
 var photoID: UUID?
 var photoURL: URL?
 var type: SnippetType?
 
 override func main()
 {
  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX!")
   return
  }
  guard let photoItem = self.photoItem else {return}
  
  photoID = photoItem.id
  photoURL = photoItem.url
  type = photoItem.type
 
 }
}

class CachedImageOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage? {return outputImage}
 
 lazy var contextDepend = {dependencies.compactMap{$0 as? CachedImageDataProvider}.first}()
 var cachedImageID: UUID? {return contextDepend?.cachedImageID}
 
 var cachedImage: UIImage?
 var outputImage: UIImage?
 
 var width: Int
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
 }
 
 override func main()
 {
  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX 1!")
   return
  }
  
  guard cachedImage == nil, let ID = cachedImageID?.uuidString else {return}
  cachedImage = PhotoItem.imageCacheDict[width]?.object(forKey: ID as NSString)
  
  if isCancelled
  {
   print ("\(self.description) CNXX 2!")
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
 var imageToResize: UIImage? {return savedImage}
 
 lazy var contextDepend = {dependencies.compactMap{$0 as? SavedImageDataProvider}.first}()
 lazy var cachedDepend =  {dependencies.compactMap{$0 as? CachedImageOperation  }.first}()
 
 var savedImageURL: URL?   {return contextDepend?.savedImageURL}
 var cachedImage: UIImage? {return cachedDepend?.cachedImage}
 var type: SnippetType?    {return contextDepend?.imageSnippetType}
 var savedImage: UIImage?
 
 override func main()
 {
  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX!")
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

class RenderVideoPreviewOperation: Operation
{
 override func main()
 {
  if isCancelled {return}
 }
}


class ThumbnailImageOperation: Operation
{
 var thumbnailImage: UIImage?
 
 lazy var thumbnailDepend = {dependencies.compactMap{$0 as? ThumbnailImageDataProvider}.first}()
 lazy var contextDepend =   {dependencies.compactMap{$0 as? CachedImageDataProvider   }.first}()
 lazy var cachedDepend =    {dependencies.compactMap{$0 as? CachedImageOperation      }.first}()
 
 var cachedImageID: UUID?   {return contextDepend?.cachedImageID}
 var cachedImage: UIImage?  {return cachedDepend?.cachedImage}
 
 var width: Int
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
 }
 
 override func main()
 {
  print ("\(self.description) in \(Thread.current)")
  
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
 var imageToResize: UIImage? {return dependencies.compactMap{($0 as? ResizeImageDataProvider)?.imageToResize}.first}
 
 var resizedImage: UIImage?
 
 var width: Int
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
 }
 
 override func main()
 {
  print ("\(self.description) in \(Thread.current)")
  
  if isCancelled
  {
   print ("\(self.description) CNXX!")
   return
  }
  guard let image = imageToResize else {return}
  resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
 }
}
