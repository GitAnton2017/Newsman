
import Foundation
import UIKit
import CoreData
import GameKit


class SnippetImagesProvider: SnippetPreviewImagesProvider, Equatable
{
 static func == (lhs: SnippetImagesProvider, rhs: SnippetImagesProvider) -> Bool
 {
  return lhs.photoSnippet == rhs.photoSnippet
 }

 private lazy var cQ = { () -> OperationQueue in
   let queue = OperationQueue()
   queue.qualityOfService = .userInitiated
   return queue
 }()
 
 fileprivate lazy var uQ = { () -> OperationQueue in
  let queue = OperationQueue()
  queue.qualityOfService = .utility
  return queue
 }()
 
 private static var randomQ = { () -> OperationQueue in
  let queue = OperationQueue()
  //queue.maxConcurrentOperationCount = 10
  queue.qualityOfService = .utility
  return queue
 }()
 
// static let lock = NSLock()
// static let cv = NSCondition()
// static var taskCount = 0
 
 fileprivate var prevResizeOperations: [ResizeImageOperation] = []
 fileprivate var currResizeOperations: [ResizeImageOperation] = []
 
 private static let maxRandomTasks = 3
 
 private static let maxRandomPayload: UInt64 = 1024 * 1024 * 512

// static var currentRandomOperation: GetRandomImagesOperation?
 
 private static var currRandomOperations: [GetRandomImagesOperation] = []
 private static var prevRandomOperations: [GetRandomImagesOperation] = []

 
 private static var prevPayload: UInt64 = 0
 private static var currPayload: UInt64 = 0

 
 private lazy var snippetPhotos: [Photo]? = {return photoSnippet.photos?.allObjects as? [Photo]}()
 
 private lazy var latestPhotoItem: PhotoItem? =
 {
  return snippetPhotos?.max{($0.date! as Date) < ($1.date! as Date)}.map{PhotoItem(photo: $0)}
 }()
 
 fileprivate lazy var photoItems: [PhotoItem] =
 {
  guard let photos = snippetPhotos, photos.count > 1 else {return []}
  
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
  return photoItems
  
 }()
 
 private var photoSnippet: PhotoSnippet
 private var number: Int
 
 init (photoSnippet: PhotoSnippet, number: Int)
 {
  self.photoSnippet = photoSnippet
  self.number = number
 }
 
 func cancelLocal()
 {
  uQ.cancelAllOperations()
  cQ.cancelAllOperations()
 }
 
 static func cancelGlobal()
 {
  SnippetImagesProvider.randomQ.cancelAllOperations()
  PhotoItem.contextQ.cancelAllOperations()
 }
 
 func cancel()
 {
 
  SnippetImagesProvider.randomQ.operations.filter
  {
   ($0 as! GetRandomImagesOperation).provider == self
  }.forEach{$0.cancel()}
  
  cancelLocal()
  
  var cnxItems = photoItems
  if let latest = latestPhotoItem {cnxItems.append(latest)}

  PhotoItem.contextQ.operations.filter
  {
   cnxItems.contains(($0 as! ContextDataOperation).photoItem!)
  }.forEach{$0.cancel()}
  
 }
 
 func getLatestImage(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
 {
   if latestPhotoItem == nil
   {
    OperationQueue.main.addOperation{completion(UIImage(named: "photo.main"))}
    return
   }
  
   var operations: [Operation] = []
 
   let context_op = ContextDataOperation()
   context_op.photoItem = latestPhotoItem
   
   let cache_op = CachedImageOperation(requiredImageSize: requiredImageWidth)
   cache_op.addDependency(context_op)
   operations.append(cache_op)
   
   let save_op = SavedImageOperation()
   save_op.addDependency(context_op)
   save_op.addDependency(cache_op)
   operations.append(save_op)
  
   let video_op = RenderVideoPreviewOperation()
   video_op.addDependency(context_op)
   video_op.addDependency(cache_op)
   operations.append(video_op)
   
   let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
   resize_op.addDependency(save_op)
   resize_op.addDependency(video_op)
   resize_op.addDependency(cache_op)
   operations.append(resize_op)
   
   let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
   thumbnail_op.addDependency(resize_op)
   thumbnail_op.addDependency(context_op)
   thumbnail_op.addDependency(cache_op)
   operations.append(thumbnail_op)
  
   thumbnail_op.completionBlock =
   {
    OperationQueue.main.addOperation{completion(thumbnail_op.finalImage)}
   }
  
   PhotoItem.contextQ.addOperation(context_op)
   cQ.addOperations(operations, waitUntilFinished: false)
 }
 
 func getRandomImages (requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
 {
  if photoItems.isEmpty {return}
  
  let random_op = GetRandomImagesOperation(from: self,
                                           requiredImageWidth: requiredImageWidth,
                                           completion: completion)
  
//  if let prevOper = SnippetImagesProvider.currentRandomOperation
//  {
//   random_op.addDependency(prevOper)
//  }
  
//  SnippetImagesProvider.currentRandomOperation = random_op
  
  let payload = random_op.payload
  
  SnippetImagesProvider.prevPayload += payload
  
  if (SnippetImagesProvider.prevPayload  >= SnippetImagesProvider.maxRandomPayload)
  {

   SnippetImagesProvider.currPayload += payload
   
   if (SnippetImagesProvider.currPayload <= SnippetImagesProvider.maxRandomPayload)
   {
    SnippetImagesProvider.prevRandomOperations.forEach{random_op.addDependency($0)}
    SnippetImagesProvider.currRandomOperations.append(random_op)
   }
   else
   {
    print("----------------------------------------------------")
    print("PREVIOUS BLOCK:")
    print("----------------------------------------------------")
    SnippetImagesProvider.prevRandomOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}

    print("----------------------------------------------------")
    print("DEPENDENT BLOCK (CURRENT):")
    print("----------------------------------------------------")
    SnippetImagesProvider.currRandomOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}
    
    SnippetImagesProvider.prevRandomOperations = SnippetImagesProvider.currRandomOperations
    SnippetImagesProvider.prevPayload = SnippetImagesProvider.currPayload
    
    SnippetImagesProvider.currRandomOperations.removeAll()
    SnippetImagesProvider.currPayload = 0
   }
   
  }
  else
  {
//   print ("Appending prevRandomOperations: \(random_op.description)")
  
   SnippetImagesProvider.prevRandomOperations.append(random_op)
   
  }
  
  
  SnippetImagesProvider.randomQ.addOperation(random_op)
  
 }
 
}

 fileprivate extension GetRandomImagesOperation
 {
  private enum State: String
  {
   case Ready, Executing, Finished
   fileprivate var keyPath: String {return "is" + rawValue}
  }
  
  fileprivate override var isReady:        Bool {return super.isReady && state == .Ready }
  fileprivate override var isExecuting:    Bool {return state == .Executing              }
  fileprivate override var isFinished:     Bool {return state == .Finished               }
  fileprivate override var isAsynchronous: Bool {return true                             }
  
  fileprivate override func start()
  {
   if isCancelled
   {
    state = .Finished
    return
   }
   main()
   state = .Executing
  }
  
  override func cancel()
  {
   super.cancel()
   state = .Finished
  }
 }

 fileprivate class GetRandomImagesOperation: Operation
 {
  private let maxResizeTask = 15
 
  fileprivate var payload: UInt64
  {
   return provider.photoItems.filter
   {item in
    let ID = item.id.uuidString
    let cashedImage = PhotoItem.imageCacheDict[Int(requiredImageWidth)]?.object(forKey: ID as NSString)
    return cashedImage == nil
   }.compactMap
   {item in
     let attr = try? FileManager.default.attributesOfItem(atPath: item.url.path) as NSDictionary
     return attr?.fileSize()
   }.reduce(0, {$0 + $1})
   
  }
  
  private var state = State.Ready
  {
   willSet
   {
    willChangeValue(forKey: newValue.keyPath)
    willChangeValue(forKey: state.keyPath)
   }
   
   didSet
   {
    didChangeValue(forKey: oldValue.keyPath)
    didChangeValue(forKey: state.keyPath)
   }
  }
  
  private var cnxObserver: NSKeyValueObservation?
  private var requiredImageWidth: CGFloat
  private var completion: ([UIImage]?) -> Void
  fileprivate var provider: SnippetImagesProvider
  
  init (from provider: SnippetImagesProvider, requiredImageWidth: CGFloat, completion: @escaping ([UIImage]?) -> Void)
  {
   
   self.provider = provider
   self.requiredImageWidth = requiredImageWidth
   self.completion = completion
   
   super.init()
   
   cnxObserver = observe(\.isCancelled)
   {[unowned self] obs, val in
    if obs.isCancelled
    {
     print ("\(self.description) is cancelled before started!")
    }
   }
  }
  
  
  override func main()
  {
  
     var operations:         [Operation] = []
     var contextOperations : [Operation] = []
     
     let image_set_op = ImageSetOperation()
     
     for photoItem in provider.photoItems
     {
      if isCancelled
      {
       print(#function, "cancelled from FOR...")
       return
       
      }
      
      let context_op = ContextDataOperation()
      context_op.photoItem = photoItem
      contextOperations.append(context_op)
      
      let cache_op = CachedImageOperation(requiredImageSize: requiredImageWidth)
      cache_op.addDependency(context_op)
      operations.append(cache_op)
      
      let save_op = SavedImageOperation()
      save_op.addDependency(context_op)
      save_op.addDependency(cache_op)
      operations.append(save_op)
      
      let video_op = RenderVideoPreviewOperation()
      video_op.addDependency(context_op)
      video_op.addDependency(cache_op)
      operations.append(video_op)
      
      let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
      resize_op.addDependency(save_op)
      resize_op.addDependency(video_op)
      resize_op.addDependency(cache_op)
      
      if (provider.prevResizeOperations.count == maxResizeTask)
      {
        provider.prevResizeOperations.forEach{resize_op.addDependency($0)}

       if (provider.currResizeOperations.count < maxResizeTask)
       {
        provider.currResizeOperations.append(resize_op)
       }

       if (provider.currResizeOperations.count == maxResizeTask)
       {
//        print("----------------------------------------------------")
//        print("PREVIOUS RESIZE BLOCK:")
//        print("----------------------------------------------------")
//        provider.prevResizeOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}
//
//        print("----------------------------------------------------")
//        print("DEPENDENT RESIZE BLOCK (CURRENT):")
//        print("----------------------------------------------------")
//        provider.currResizeOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}
//
        provider.prevResizeOperations = provider.currResizeOperations
        provider.currResizeOperations.removeAll()
       }
      }
      else
      {
//       print ("Filling the array of previous Resize Operations: \(resize_op.description)")
       provider.prevResizeOperations.append(resize_op)
      }
      
      
      operations.append(resize_op)
      
      let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
      thumbnail_op.addDependency(resize_op)
      thumbnail_op.addDependency(context_op)
      thumbnail_op.addDependency(cache_op)
      operations.append(thumbnail_op)
      
      image_set_op.addDependency(thumbnail_op)
      
     }
     
     image_set_op.completionBlock =
     {
//       SnippetImagesProvider.cv.lock()
//       SnippetImagesProvider.taskCount -= 1
//       print("Resize task counter: \(SnippetImagesProvider.taskCount)")
//       if SnippetImagesProvider.taskCount < SnippetImagesProvider.maxTask
//       {
//        SnippetImagesProvider.cv.broadcast()
//       }
//
//       SnippetImagesProvider.cv.unlock()
      
      
       self.state = .Finished //!!!!!!!!!!
       self.provider.prevResizeOperations.removeAll()
       self.provider.currResizeOperations.removeAll()
      
       OperationQueue.main.addOperation{self.completion(image_set_op.imageSet)}
     }
     
//     SnippetImagesProvider.cv.lock()
//
//     while (SnippetImagesProvider.taskCount >= SnippetImagesProvider.maxTask)
//     {
//      SnippetImagesProvider.cv.wait()
//     }
//
//     SnippetImagesProvider.taskCount += 1
//     print("Resize task counter: \(SnippetImagesProvider.taskCount)")
//     SnippetImagesProvider.cv.unlock()
   
//     if isCancelled
//     {
//      print(#function, "cancel after CV wait")
//      return
//     }
   
     if isCancelled
     {
        print(#function, "Cancelled from before sending operations to queues...")
        return
    
     }
   
     operations.append(image_set_op)
     PhotoItem.contextQ.addOperations(contextOperations, waitUntilFinished: false)
     provider.uQ.addOperations(operations, waitUntilFinished: false)
     
   }
   
  }


 








