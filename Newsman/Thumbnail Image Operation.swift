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
 var finalImage: UIImage? {return thumbnailImage}
 
 var thumbnailImage: UIImage?
 
 private var thumbnailDepend: ThumbnailImageDataProvider?
 {
  return dependencies.compactMap{$0 as? ThumbnailImageDataProvider}.first
 }
 
 private var contextDepend: CachedImageDataProvider?
 {
  return dependencies.compactMap{$0 as? CachedImageDataProvider   }.first
 }
 
 private var cachedDepend: CachedImageOperation?
 {
  return dependencies.compactMap{$0 as? CachedImageOperation      }.first
 }
 
 var cachedImageID: UUID?   {return contextDepend?.cachedImageID  }
 var cachedImage: UIImage?  {return cachedDepend?.cachedImage     }
 
 private var width: Int
 
 private var observers = Set<NSKeyValueObservation>()
 
 init (requiredImageSize: CGFloat)
 {
  width = Int(requiredImageSize)
  
  super.init()
  
  let cnxObserver = observe(\.isCancelled) {op, _ in op.removeAllDependencies()}
  
  observers.insert(cnxObserver)
 }
 
 override func main()
 {

  if isCancelled {return}
  
  guard let image = thumbnailDepend?.thumbnailImage, let ID = cachedImageID?.uuidString else
  {
   thumbnailImage = cachedImage
   return
  }
  
  thumbnailImage = image
  
  if let cache = PhotoItem.imageCacheDict[width]
  {
   cache.setObject(image, forKey: ID as NSString)
   //   print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name) for Item ID \(ID)")
  }
  else
  {
   let newImagesCache = PhotoItem.ImagesCache()
   newImagesCache.name = "(\(width) x \(width))"
   newImagesCache.setObject(image, forKey: ID as NSString)
   PhotoItem.imageCacheDict[width] = newImagesCache
   
   //   print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE for Item ID \(ID)")
  }
 }
}

