
import Foundation
import UIKit
import CoreData
import GameKit

class SnippetImagesProvider
{
 
 lazy var cQ = { () -> OperationQueue in
   let queue = OperationQueue()
   queue.qualityOfService = .userInitiated
   return queue
 }()
 
 lazy var uQ = { () -> OperationQueue in
  let queue = OperationQueue()
  queue.qualityOfService = .utility
  return queue
 }()
 
 static var rQ = { () -> OperationQueue in
  let queue = OperationQueue()
  //queue.maxConcurrentOperationCount = 10
  queue.qualityOfService = .utility
  return queue
 }()
 
// static let lock = NSLock()
// static let cv = NSCondition()
 
// static var taskCount = 0
 
 static let maxTask = 5

 static var currentRandomOperation: GetRandomImagesOperation?
 
 static var currentRandomOperations: [GetRandomImagesOperation] = []
 
 static var prevRandomOperations: [GetRandomImagesOperation] = []
 
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
 
 func cancel()
 {
 
  SnippetImagesProvider.rQ.operations.filter
  {
   ($0 as! GetRandomImagesOperation).provider === self
  }.forEach{$0.cancel()}
  
  uQ.cancelAllOperations()
  cQ.cancelAllOperations()
  
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
    OperationQueue.main.addOperation{completion(nil)}
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
   
   let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
   resize_op.addDependency(save_op)
   resize_op.addDependency(cache_op)
   operations.append(resize_op)
   
   let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
   thumbnail_op.addDependency(resize_op)
   thumbnail_op.addDependency(context_op)
   thumbnail_op.addDependency(cache_op)
   operations.append(thumbnail_op)
  
   thumbnail_op.completionBlock =
   {
    OperationQueue.main.addOperation{completion(thumbnail_op.thumbnailImage)}
   }
  
   PhotoItem.contextQ.addOperation(context_op)
   self.cQ.addOperations(operations, waitUntilFinished: false)
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
  
  if (SnippetImagesProvider.prevRandomOperations.count == SnippetImagesProvider.maxTask)
  {
   print ("Adding dependancies from prevRandomOperations to: \(random_op.description)")
   SnippetImagesProvider.prevRandomOperations.forEach{random_op.addDependency($0)}
   
   if (SnippetImagesProvider.currentRandomOperations.count < SnippetImagesProvider.maxTask)
   {
    print ("Appending currentRandomOperations: \(random_op.description)")
    SnippetImagesProvider.currentRandomOperations.append(random_op)
   }
   
   if (SnippetImagesProvider.currentRandomOperations.count == SnippetImagesProvider.maxTask)
   {
    print ("Exchange...")
    SnippetImagesProvider.prevRandomOperations = SnippetImagesProvider.currentRandomOperations
    SnippetImagesProvider.currentRandomOperations.removeAll()
   }
   
  }
  else
  {
   print ("Appending prevRandomOperations: \(random_op.description)")
   SnippetImagesProvider.prevRandomOperations.append(random_op)
  }
  
  SnippetImagesProvider.rQ.addOperation(random_op)
  
 }
 
}

 extension GetRandomImagesOperation
 {
  enum State: String
  {
   case Ready, Executing, Finished
   fileprivate var keyPath: String {return "is" + rawValue}
  }
  
  override var isReady:        Bool {return super.isReady && state == .Ready }
  override var isExecuting:    Bool {return state == .Executing              }
  override var isFinished:     Bool {return state == .Finished               }
  override var isAsynchronous: Bool {return true                             }
  
  override func start()
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

 class GetRandomImagesOperation: Operation
 {
  
  var state = State.Ready
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
  
  var cnxObserver: NSKeyValueObservation?
  var requiredImageWidth: CGFloat
  var completion: ([UIImage]?) -> Void
  var provider: SnippetImagesProvider
  
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
     print ("\(self.description) is canclled!")
    }
   }
  }
  
  
  override func main()
  {
   
   
     var operations: [Operation] = []
     var contextOperations : [Operation] = []
     
     let image_set_op = ImageSetOperation()
     
     for photoItem in provider.photoItems
     {
      if isCancelled
      {
       print(#function, "cancel from FOR...")
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
      
      let resize_op = ResizeImageOperation(requiredImageSize: requiredImageWidth)
      resize_op.addDependency(save_op)
      resize_op.addDependency(cache_op)
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
   
     operations.append(image_set_op)
     PhotoItem.contextQ.addOperations(contextOperations, waitUntilFinished: false)
     provider.uQ.addOperations(operations, waitUntilFinished: false)
     
   }
   
  }


 








