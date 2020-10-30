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
 
 var videoURL: URL?                  { photoURL }
 var savedImageURL: URL?             { photoURL }
 var imageSnippetType: SnippetType?  { type     }
 
 var cachedImageID: UUID?            { photoID  }
 
 var photoItem: PhotoItem? //Input PhotoItem
 
 private var photoID: UUID?
 private var photoURL: URL?
 private var type: SnippetType?
 
 private var observers = Set<NSKeyValueObservation>()
 
 override init()
 {
  super.init()
  let cnxObserver = observe(\.isCancelled)
  {op, _ in
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
  if isCancelled { return }
  guard let photoItem = photoItem else { return }
  guard photoItem.photo.isDeleted == false else { return }
  
  photoItem.photo.managedObjectContext?.performAndWait
  {
   self.photoID = photoItem.id
   self.photoURL = photoItem.url
   self.type = photoItem.type
  }
 } //main()
 
}//class ContextDataOperation: Operation...

