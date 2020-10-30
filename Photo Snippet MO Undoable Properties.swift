//
//  Photo Snippet MO Undoable Properties.swift
//  Newsman
//
//  Created by Anton2016 on 13/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

//import Foundation

// MARK: Undoable accessors for photos

//extension PhotoSnippet
//{
//
// public func addToPhotos(photo : Photo,  undoably: Bool = true)
// {
//  addToPhotos(photo)
//
//  if undoably
//  {
//   photo.addActions(contextUndoBlock: { [weak self, unowned photo] in self?.removeFromPhotos(photo) },
//                    contextRedoBlock: { [weak self, unowned photo] in self?.addToPhotos(photo)      })
//  }
// }
//
// public func removeFromPhotos(photo: Photo, undoably: Bool = true)
// {
//  removeFromPhotos(photo)
//
//  if undoably
//  {
//   photo.addActions(contextUndoBlock: { [weak self, unowned photo] in self?.addToPhotos(photo)        },
//                    contextRedoBlock: { [weak self, unowned photo] in self?.removeFromPhotos(photo)   })
//  }
// }
//
//// public func addToPhotos(photos: NSSet, undoably: Bool = true)
//// {
////  addToPhotos(photos)
////
////  if undoably
////  {
////   addActions(contextUndoBlock: { self.removeFromPhotos(photos) },
////              contextRedoBlock: { self.addToPhotos(photos)      })
////  }
//// }
////
//// public func removeFromPhotos(photos: NSSet, undoably: Bool = true)
//// {
////  removeFromPhotos(photos)
////
////  if undoably
////  {
////   addActions(contextUndoBlock: { self.addToPhotos(photos)        },
////              contextRedoBlock: { self.removeFromPhotos(photos)   })
////  }
//// }
//
//}
