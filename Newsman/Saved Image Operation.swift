//
//  Saved Image Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class SavedImageOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage?
 {
  get {return savedImage}
  set {savedImage = newValue}
 }
 
 private var contextDepend: SavedImageDataProvider?
 {
  return dependencies.compactMap{$0 as? SavedImageDataProvider}.first
 }
 
 private var cachedDepend: CachedImageOperation?
 {
  return dependencies.compactMap{$0 as? CachedImageOperation  }.first
 }
 
 private var savedImageURL: URL?   {return contextDepend?.savedImageURL   }
 private var cachedImage: UIImage? {return cachedDepend?.cachedImage      }
 private var type: SnippetType?    {return contextDepend?.imageSnippetType}
 
 private var savedImage: UIImage?
 
 private var observers = Set<NSKeyValueObservation>()
 
 override init()
 {
  super.init()
  
  let cnxObserver = observe(\.isCancelled) {op, _ in op.removeAllDependencies()}
  
  observers.insert(cnxObserver)
  
  let finishObserver = observe(\.isFinished)
  {op, _ in
   
   op.removeAllDependencies()
   
   DispatchQueue.main.async
   {
     guard let curr_ind = PhotoItem.currSavedOperations.index(of: op) else {return}
     PhotoItem.currSavedOperations.remove(at: curr_ind)
     
     guard let prev_ind = PhotoItem.prevSavedOperations.index(of: op) else {return}
     PhotoItem.prevSavedOperations.remove(at: prev_ind)
   }
   
  }
  
  observers.insert(finishObserver)
  
 }
 
 override func main()
 {
  if isCancelled {return} //if isCancelled is set to true no sence to continue!
  
  guard let url = savedImageURL, type == .photo, cachedImage == nil, savedImage == nil else {return}
  
  do
  {
   let data = try Data(contentsOf: url)
   
   if isCancelled {return} //if isCancelled is set to true no sence to retain big image loaded from disk!
   
   savedImage = UIImage(data: data)
  }
  catch
  {
   print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
  } //do-try-catch...
 }
}
