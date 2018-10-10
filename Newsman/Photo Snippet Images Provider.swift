
import Foundation
import UIKit
import CoreData
import GameKit


class SnippetImagesProvider: SnippetPreviewImagesProvider, Equatable
{
// deinit {
//  print ("Provide for \(photoSnippet.tag) is destroyed!" )
// }
 
 static func == (lhs: SnippetImagesProvider, rhs: SnippetImagesProvider) -> Bool
 {
  return lhs.photoSnippet == rhs.photoSnippet
 }

 fileprivate lazy var iQ = { () -> OperationQueue in
  let queue = OperationQueue()
  queue.qualityOfService = .userInitiated
  queue.maxConcurrentOperationCount = 1
  return queue
 }()
 
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
 
// private static var randomQ = { () -> OperationQueue in
//  let queue = OperationQueue()
//  //queue.maxConcurrentOperationCount = 10
//  queue.qualityOfService = .utility
//  return queue
// }()
 
// static let lock = NSLock()
// static let cv = NSCondition()
// static var taskCount = 0

 
// private static let maxRandomTasks = 3
 
 private static let maxRandomPayload: UInt64 = 1024 * 1024 * 256

// static var currentRandomOperation: GetRandomImagesOperation?
 
 private static var currRandomOperObservers: [NSKeyValueObservation] = []
 private static var currRandomOperations: [GetRandomImagesOperation] = []
 {
  didSet
  {
   if currRandomOperations.isEmpty
   {
    print ("All CURRENT RANDOM OPERATIONS ARE FINISHED!")
    currRandomOperObservers.removeAll()
    currPayload = 0
   }
  }
 }
 
 private static var prevRandomOperObservers: [NSKeyValueObservation] = []
 private static var prevRandomOperations: [GetRandomImagesOperation] = []
 {
  didSet
  {
   if prevRandomOperations.isEmpty
   {
    print ("All PREVIOUS RANDOM OPERATIONS ARE FINISHED!")
    prevRandomOperObservers.removeAll()
    prevPayload = 0
   }
  }
 }

 
 

 private static var prevPayload: UInt64 = 0
 private static var currPayload: UInt64 = 0

 
 private var snippetPhotos: [Photo]?
 {
  var photos: [Photo]?
 
  PhotoItem.MOC.performAndWait
  {
   photos = photoSnippet.photos?.allObjects as? [Photo]
  }
 
  return photos
  
 }
 
 private var latestPhotoItem: PhotoItem?
 {
  let photoItem = snippetPhotos?.max{($0.date! as Date) < ($1.date! as Date)}.map{PhotoItem(photo: $0)}
  return photoItem
 }
 
 fileprivate var photoItems: [PhotoItem]
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
  
 }
 
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
 
// static func cancelGlobal()
// {
////  SnippetImagesProvider.randomQ.cancelAllOperations()
//  //PhotoItem.contextQ.cancelAllOperations()
// }
 
 func cancel()
 {

//  SnippetImagesProvider.randomQ.operations.filter
//  {
//   ($0 as! GetRandomImagesOperation).provider == self
//  }.forEach{$0.cancel()}

  cancelLocal()
  
//
//  var cnxItems = photoItems
//  if let latest = latestPhotoItem {cnxItems.append(latest)}

//  PhotoItem.contextQ.operations.filter
//  {
//   cnxItems.contains(($0 as! ContextDataOperation).photoItem!)
//  }.forEach{$0.cancel()}

 }
 
 func getLatestImage(requiredImageWidth: CGFloat,  completion: @escaping (UIImage?) -> Void)
 {
   if latestPhotoItem == nil
   {
    OperationQueue.main.addOperation{completion(UIImage(named: "photo.main"))}
    return
   }
  
   var operations: [Operation] = []
 
   let context_op = ContextDataOperation()
   context_op.photoItem = latestPhotoItem
   operations.append(context_op)
  
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
  
//   PhotoItem.contextQ.addOperation(context_op)
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

  if (SnippetImagesProvider.prevPayload  >= SnippetImagesProvider.maxRandomPayload)
  {
   if (SnippetImagesProvider.currPayload <= SnippetImagesProvider.maxRandomPayload)
   {
    SnippetImagesProvider.prevRandomOperations.forEach{random_op.addDependency($0)}
    SnippetImagesProvider.currPayload += payload
    
    let random_op_obs = random_op.observe(\.isFinished)
    {random_op, _ in
     if random_op.isFinished
     {
      DispatchQueue.main.async
      {
       guard let index = SnippetImagesProvider.currRandomOperations.index(of: random_op) else {return}
       SnippetImagesProvider.currRandomOperations.remove(at: index)
      }
     }
    }
    
    SnippetImagesProvider.currRandomOperations.append(random_op)
    SnippetImagesProvider.currRandomOperObservers.append(random_op_obs)
   }
   else
   {
    print("----------------------------------------------------")
    print("PREVIOUS BLOCK:")
    print("----------------------------------------------------")
    SnippetImagesProvider.prevRandomOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}
    let prev_pl = Double(SnippetImagesProvider.prevPayload)/(1024.0 * 1024.0)
    print("Total Previous Block Payload (MB): \(prev_pl.rounded())")

    print("----------------------------------------------------")
    print("DEPENDENT BLOCK (CURRENT):")
    print("----------------------------------------------------")
    SnippetImagesProvider.currRandomOperations.enumerated().forEach{print("\($0.0 + 1)) \($0.1.description)")}
    let curr_pl = Double(SnippetImagesProvider.currPayload)/(1024.0 * 1024.0)
    print("Total Current Block Payload (MB): \(curr_pl.rounded())")
    
    SnippetImagesProvider.prevRandomOperations.removeAll()
    SnippetImagesProvider.prevRandomOperations = SnippetImagesProvider.currRandomOperations
    SnippetImagesProvider.prevPayload = SnippetImagesProvider.currPayload
    SnippetImagesProvider.prevRandomOperObservers = SnippetImagesProvider.prevRandomOperations.map
    {random_op in
     return random_op.observe(\.isFinished)
     {random_op, _ in
      if random_op.isFinished
      {
       DispatchQueue.main.async
       {
         guard let index = SnippetImagesProvider.prevRandomOperations.index(of: random_op) else {return}
         SnippetImagesProvider.prevRandomOperations.remove(at: index)
       }
      }
     }
    }
    
    SnippetImagesProvider.currRandomOperations.removeAll()
 
   }
   
  }
  else
  {
//   print ("Appending prevRandomOperations: \(random_op.description)")
   SnippetImagesProvider.prevPayload += payload
   
   let random_op_obs = random_op.observe(\.isFinished)
   {random_op, _ in
    if random_op.isFinished
    {
     DispatchQueue.main.async
     {
       guard let index = SnippetImagesProvider.prevRandomOperations.index(of: random_op) else {return}
       SnippetImagesProvider.prevRandomOperations.remove(at: index)
     }
    }
   }
   
   SnippetImagesProvider.prevRandomOperations.append(random_op)
   SnippetImagesProvider.prevRandomOperObservers.append(random_op_obs)
   
   
  }
  
  
//  SnippetImagesProvider.randomQ.addOperation(random_op)
    uQ.addOperation(random_op)
  
  
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
  private let maxResizeTask = 3
 
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
     var prevResizeOperations: [ResizeImageOperation] = []
     var currResizeOperations: [ResizeImageOperation] = []
   
     var prevSavedOperations: [SavedImageOperation] = []
     var currSavedOperations: [SavedImageOperation] = []
   
     var operations:         [Operation] = []
//     var contextOperations : [Operation] = []
   
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
//      contextOperations.append(context_op)
      operations.append(context_op)
      
      let cache_op = CachedImageOperation(requiredImageSize: requiredImageWidth)
      cache_op.addDependency(context_op)
      operations.append(cache_op)
      
      let saved_op = SavedImageOperation()
      saved_op.addDependency(context_op)
      saved_op.addDependency(cache_op)
      operations.append(saved_op)
 
      let video_op = RenderVideoPreviewOperation()
      video_op.addDependency(context_op)
      video_op.addDependency(cache_op)
      operations.append(video_op)
      
      let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
      resize_op.addDependency(saved_op)
      resize_op.addDependency(video_op)
      resize_op.addDependency(cache_op)
      operations.append(resize_op)
      
     
      if (prevSavedOperations.count == maxResizeTask)
      {
       if (currSavedOperations.count < maxResizeTask)
       {
        prevResizeOperations.forEach{saved_op.addDependency($0)}
        currSavedOperations.append(saved_op)
        currResizeOperations.append(resize_op)
       }

       if (currSavedOperations.count == maxResizeTask)
       {
        prevResizeOperations = currResizeOperations
        prevSavedOperations = currSavedOperations
        
        currResizeOperations.removeAll()
        currSavedOperations.removeAll()
       }
      }
      else
      {
       prevSavedOperations.append(saved_op)
       prevResizeOperations.append(resize_op)
 
      }
     
      
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
      
      
  
      
       OperationQueue.main.addOperation
       {
        self.completion(image_set_op.imageSet)
        
        self.state = .Finished //!!!!!!!!!! Must be set in Main.thread!
        
        
       }
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
//     PhotoItem.contextQ.addOperations(contextOperations, waitUntilFinished: false)
     provider.uQ.addOperations(operations, waitUntilFinished: false)
     
   }
   
  }


 








