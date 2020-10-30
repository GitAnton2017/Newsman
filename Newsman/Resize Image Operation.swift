//
//  Resize Image Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class ResizeImageOperation: Operation, ThumbnailImageDataProvider
{
 var thumbnailImage: UIImage? {return resizedImage}
 
 private var imageToResize: UIImage?
 {
  dependencies.compactMap{($0 as? ResizeImageDataProvider)?.imageToResize}.first
 }
 
 private var resizedImage: UIImage?
 private var width: Int
 
 private var observers = Set<NSKeyValueObservation>()
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  super.init()
  
  let cnxObserver = observe(\.isCancelled)
  {op, _ in
   op.dependencies.compactMap({$0 as? SavedImageOperation}).first?.imageToResize = nil
   op.removeAllDependencies()
   op.observers.removeAll()
  }
  
  observers.insert(cnxObserver)
  
  let finishObserver = observe(\.isFinished)
  {op, _ in
  
   DispatchQueue.main.async
   {
    op.removeAllDependencies()
    op.observers.removeAll()
   
    guard let curr_ind = PhotoItem.currResizeOperations.firstIndex(of: op) else { return }
    PhotoItem.currResizeOperations.remove(at: curr_ind)
  
    guard let prev_ind = PhotoItem.prevResizeOperations.firstIndex(of: op) else { return }
    PhotoItem.prevResizeOperations.remove(at: prev_ind)
     
   }
   
   
  }
  
  observers.insert(finishObserver)
  
 }
 
 override func main()
 {
  if isCancelled { return }
  
  guard let image = imageToResize else { return }
  
  let resized = image.resized(withPercentage: CGFloat(width) / image.size.width)
  
  if isCancelled { return }
  
  resizedImage = resized
  
  dependencies.compactMap({$0 as? SavedImageOperation}).first?.imageToResize = nil
  
 }//override func main()

}


