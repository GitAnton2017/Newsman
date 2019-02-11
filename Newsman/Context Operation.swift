//
//  Context Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

class ContextDataOperation: Operation, CachedImageDataProvider, SavedImageDataProvider, VideoPreviewDataProvider
{
 var videoURL: URL?                  {return photoURL}
 var savedImageURL: URL?             {return photoURL}
 var imageSnippetType: SnippetType?  {return type    }
 
 var cachedImageID: UUID?            {return photoID }
 
 var photoItem: PhotoItem? //Input PhotoItem
 
 private var photoID: UUID?
 private var photoURL: URL?
 private var type: SnippetType?
 
 private var observers = Set<NSKeyValueObservation>()
 
 override init()
 {
  super.init()
  let cnxObserver = observe(\.isCancelled) {op, _ in op.removeAllDependencies()}
  observers.insert(cnxObserver)
 }
 
 override func main()
 {
  if isCancelled {return}
  
  //PhotoItem.contextQ.sync //This is fucking strong guaranty that MO Context is accessed serially!!!!
  PhotoItem.MOC.performAndWait
  {
    self.photoID = photoItem?.id
    self.photoURL = photoItem?.url
    self.type = photoItem?.type
  }
 } //main()
 
}//class ContextDataOperation: Operation...

