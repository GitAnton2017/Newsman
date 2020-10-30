//
//  Cached Image Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class CachedImageOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage? { outputImage }
 
 private var contextDepend: CachedImageDataProvider?
 {
  dependencies.compactMap{$0 as? CachedImageDataProvider}.first
 }
 
 private var cachedImageID: UUID? { contextDepend?.cachedImageID }
 
 var cachedImage: UIImage?
 
 private var outputImage: UIImage?
 
 private var width: Int
 
 fileprivate var cnxObserver: NSKeyValueObservation?
 
 private var observers = Set<NSKeyValueObservation>()
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  
  super.init()
  
  let cnxObserver = observe(\.isCancelled)
  {op,_ in
   op.removeAllDependencies()
   op.observers.removeAll()
  }
  
  let finObserver = observe(\.isFinished)
  {op,_ in
   op.removeAllDependencies()
   op.observers.removeAll()
  }
  
  observers.insert(finObserver)
  observers.insert(cnxObserver)
  
 }
 
 override func main()
 {
  if isCancelled { return } //if isCancelled is set to true no sence to continue!
  guard cachedImage == nil, let ID = cachedImageID?.uuidString else { return }
  
  cachedImage = PhotoItem.imageCacheDict[width]?.object(forKey: ID as NSString)
  
  if isCancelled { return } //if isCancelled is set to true no sence to continue
  
  guard cachedImage == nil else { return }
  let caches = PhotoItem.imageCacheDict.filter { $0.key > width && $0.value.object(forKey: ID as NSString) != nil }
  let cache = caches.min(by: { $0.key < $1.key })?.value
  
  if isCancelled { return }
  
  cachedImage = cache?.object(forKey: ID as NSString)
  outputImage = cachedImage
  
 }
 
}
