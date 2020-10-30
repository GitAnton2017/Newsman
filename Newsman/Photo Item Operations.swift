
import UIKit
import Combine
import RxSwift

extension PhotoItem
{
 static var maxResizeTask = 5
 
 static let resizeQueue: OperationQueue = {
  let queue = OperationQueue()
  queue.maxConcurrentOperationCount = maxResizeTask
  queue.qualityOfService = .userInitiated
  return queue
 }()
 
 static func clearChainedOperations()
 {
  prevSavedOperations.removeAll()
  prevResizeOperations.removeAll()
  currResizeOperations.removeAll()
  currSavedOperations.removeAll()
 }
 
 static var prevResizeOperations: [ResizeImageOperation] = []
 static var currResizeOperations: [ResizeImageOperation] = []
 
 static var prevSavedOperations:  [SavedImageOperation ] = []
 static var currSavedOperations:  [SavedImageOperation ] = []

 private static func chainOperations (_ saved_op: SavedImageOperation, _ resize_op: ResizeImageOperation)
 {
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
    currResizeOperations.removeAll()
    
    prevSavedOperations = currSavedOperations
    currSavedOperations.removeAll()
   }
  }
  else
  {
   prevSavedOperations.append(saved_op)
   prevResizeOperations.append(resize_op)
  }
 }
 
 func getImagePublisher(requiredImageWidth: CGFloat) -> AnyPublisher<UIImage?, Never>
 {
  Future{ [ weak self ] promise in
   guard requiredImageWidth > 0 else { promise(.success(nil)); return }
   DispatchQueue.global(qos: .userInitiated).async
   {
    self?.getImageOperation(requiredImageWidth: requiredImageWidth) { promise(.success($0)) }
   }
  }.eraseToAnyPublisher()
 }
 
 func getPosImagePublisher(requiredImageWidth: CGFloat) -> AnyPublisher<(Int, UIImage)?, Never>
 {
  Future{ [ weak self ] promise in
   guard requiredImageWidth > 0 else { promise(.success(nil)); return }
   guard let self = self else { promise(.success(nil)); return }
   let pos = self.rowPosition
   DispatchQueue.global(qos: .userInitiated).async
   {[ weak self ] in
     guard let self = self else { promise(.success(nil)); return }
    
     self.getImageOperation(requiredImageWidth: requiredImageWidth)
     {image in
      guard let image = image else { promise(.success(nil)); return }
      promise(.success((pos, image)))
      
     }
   }
  }.eraseToAnyPublisher()
 }
 
 func getImageSingle(requiredImageWidth: CGFloat) -> Single<UIImage?>
 {
  Single.create { [ weak self ]  promise in
   let disposable = Disposables.create()
   guard requiredImageWidth > 0 else { promise(.success(nil)); return disposable }
   self?.getImageOperation(requiredImageWidth: requiredImageWidth) { promise(.success($0)) }
   return disposable
  }
 }
 
 func getImageOperation(requiredImageWidth: CGFloat,  completion: @escaping (UIImage?) -> Void)
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
 
  
  //PhotoItem.chainOperations(saved_op, resize_op)
 
  let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
  thumbnail_op.addDependency(resize_op)
  thumbnail_op.addDependency(context_op)
  thumbnail_op.addDependency(cache_op)
  
  thumbnail_op.completionBlock =
  {[unowned thumbnail_op] in
   let finalImage = thumbnail_op.thumbnailImage
  
   completion(finalImage)
//   OperationQueue.main.addOperation
//   {
//
//    //PhotoItem.clearChainedOperations()
//   }
  }
  
  let operations = [context_op, cache_op, saved_op, video_op, thumbnail_op]
  
  PhotoItem.resizeQueue.addOperation(resize_op)
  
  let queue = OperationQueue()
  queue.qualityOfService = .userInitiated
  
  queue.addOperations(operations, waitUntilFinished: false)
  
  self.cQ = queue
 
 }
}


extension PhotoFolderItem
{
 
 private final func renderGridImages(_ images: [UIImage],
                                     _ gridSize: CGFloat,
                                     _ imagesInRow: Int,
                                     _ imageCornerRadius: CGFloat) -> AnyPublisher<UIImage, Never>
 {
  Future { promise in
   DispatchQueue.global(qos: .userInitiated).async
   {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: gridSize, height: gridSize))
    let gridImage = renderer.image { irc in
     let icr = imageCornerRadius * CGFloat(imagesInRow)
     let rect = irc.format.bounds
     let clip_path = CGPath(roundedRect: rect.insetBy(dx: 5, dy: 5),
                            cornerWidth: icr, cornerHeight: icr,
                            transform: nil)
     let ctx = irc.cgContext
     ctx.scaleBy(x: 1 / CGFloat(imagesInRow), y: 1 / CGFloat(imagesInRow))
     for (i, image) in images.enumerated()
     {
      ctx.saveGState()
      ctx.translateBy(x: CGFloat(i % imagesInRow) * rect.width,
                      y: CGFloat(i / imagesInRow) * rect.height)
      
      ctx.addPath(clip_path)
      ctx.clip()
      image.draw(in: rect)
      ctx.restoreGState()
     }
    }
    promise(.success(gridImage))
   }//DispatchQueue.global().async..
  }.eraseToAnyPublisher()
 }
 
 final func getFolderGridPreviewPublisher(folderSize: CGFloat,
                                          imagesInRow: Int,
                                          imageCornerRadius: CGFloat) -> AnyPublisher<UIImage, Never>
 {
  guard folderSize > 0 && imagesInRow > 0 else
  {
   return Empty().eraseToAnyPublisher()
  }
  

  
  let requiredImageWidth = folderSize / CGFloat(imagesInRow)
  return singlePhotoItems.sorted{ $0.rowPosition < $1.rowPosition }
   .publisher
   .flatMap{ $0.getPosImagePublisher(requiredImageWidth: requiredImageWidth) }
   .compactMap{ $0 }
   .collect()
   .flatMap { [ weak self ] (tuples) -> AnyPublisher<UIImage, Never> in
     guard let self = self else { return Empty().eraseToAnyPublisher() }
     let images = tuples.sorted{$0.0 < $1.0}.map{$0.1}
     return self.renderGridImages(images, folderSize, imagesInRow, imageCornerRadius)  }
   .eraseToAnyPublisher()
  
 }
 
 
}


