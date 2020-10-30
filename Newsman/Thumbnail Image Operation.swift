//
//  File.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class ThumbnailImageOperation: Operation, ImageSetDataProvider
{
 var finalImage: UIImage? { thumbnailImage }
 
 var thumbnailImage: UIImage?
 
 private var thumbnailDepend: ThumbnailImageDataProvider?
 {
  dependencies.compactMap{$0 as? ThumbnailImageDataProvider}.first
 }
 
 private var contextDepend: CachedImageDataProvider?
 {
  dependencies.compactMap{$0 as? CachedImageDataProvider   }.first
 }
 
 private var cachedDepend: CachedImageOperation?
 {
  dependencies.compactMap{$0 as? CachedImageOperation      }.first
 }
 
 var cachedImageID: UUID?   { contextDepend?.cachedImageID  }
 var cachedImage: UIImage?  { cachedDepend?.cachedImage     }
 
 private var width: Int
 
 private var observers = Set<NSKeyValueObservation>()
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  
  super.init()
  
  let cnxObserver = observe(\.isCancelled)
  {op, _ in
   op.removeAllDependencies()
   DispatchQueue.main.async { op.observers.removeAll() }
  }
  
  let finObserver = observe(\.isFinished)
  {op,_ in
   op.removeAllDependencies()
   DispatchQueue.main.async { op.observers.removeAll() }
  }
  
  observers.insert(finObserver)
  observers.insert(cnxObserver)
 }
 
 override func main()
 {

  if isCancelled { return }
  
  guard let image = thumbnailDepend?.thumbnailImage, let ID = cachedImageID?.uuidString else
  {
   thumbnailImage = cachedImage
   return
  }
  
  thumbnailImage = image
  
  if let cache = PhotoItem.imageCacheDict[width] { cache.setObject(image, forKey: ID as NSString) }
  else
  {
   let newImagesCache = PhotoItem.ImagesCache()
   newImagesCache.name = "(\(width) x \(width))"
   newImagesCache.setObject(image, forKey: ID as NSString)
   PhotoItem.imageCacheDict[width] = newImagesCache
  }
 }
}

