
import UIKit

extension PhotoItem
{
 static var maxResizeTask = 5
 
// static func clearChainedOperations()
// {
//  prevSavedOperations.removeAll()
//  prevResizeOperations.removeAll()
//  currResizeOperations.removeAll()
//  currSavedOperations.removeAll()
// }
 
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
  
  PhotoItem.chainOperations(saved_op, resize_op)
 
  let thumbnail_op = ThumbnailImageOperation(requiredImageSize: requiredImageWidth)
  thumbnail_op.addDependency(resize_op)
  thumbnail_op.addDependency(context_op)
  thumbnail_op.addDependency(cache_op)
  
  thumbnail_op.completionBlock =
  {
   let finalImage = thumbnail_op.thumbnailImage
   
   if finalImage == nil {print ("<<<<NIL IMAGE>>>> for \(self.id)")}
   OperationQueue.main.addOperation
   {
    completion(finalImage)
   }
  }
  
  let operations = [context_op, cache_op, saved_op, video_op, resize_op, thumbnail_op]
  
  cQ.addOperations(operations, waitUntilFinished: false)
 
 }
}

