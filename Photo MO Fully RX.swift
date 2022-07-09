//
//  Photo MO Fully RX.swift
//  Newsman
//
//  Created by Anton2016 on 01/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

enum DraggableError: Error
{
 case moveError(item: Draggable, contextError: ContextError)
}

extension PhotoItem //fully reactive approach...
{
 final func move(to snippet: BaseSnippet,
                 to photoItem: Draggable?,
                 to position: PhotoItemPosition?) -> Observable<Draggable>
 {
  print (#function)
  
  return Observable<Draggable>.create
  {observer in
   
   let disposable = Disposables.create()
   
   guard let destSnippet = snippet as? PhotoSnippet else
   {
    observer.onCompleted()
    return disposable
   }
   
   let contextResultHandler: (Result<Notification, ContextError>) -> () =
   {result in
    switch result.mapError({DraggableError.moveError(item: self, contextError: $0)})
    {
     case .success(let notification): NotificationCenter.default.post(notification)
      observer.onNext(self) 
      observer.onCompleted()
     
     case .failure(let error): observer.onError(error)
    }
   }
   
   MAIN_SWITCH: switch (self.folder, photoItem, position)
   {
    // <<<<< ------ REFOLDER (.photoItemDidRefolder) -------- >>>>>
    case let ( sourceFolder?,  destFolder as PhotoFolderItem, position? )
     where sourceFolder !== destFolder.folder:
     self.photo.refolder(to: destFolder.folder, to: position, with: contextResultHandler)
    
    // <<<<< ------ UNFOLDER (.photoItemDidUnfolder) -------- >>>>>
    case let ( _?,  nil, position? ):
     self.photo.isDragMoved = true
     self.photo.unfolder(to: destSnippet, to: position, with: contextResultHandler)
    
    // <<<<< ------ FOLDER (.photoItemDidFolder) -------  >>>>>
    case let ( nil, destFolder as PhotoFolderItem, position? ):
     self.photo.folder(to: destFolder.folder, to: position, with: contextResultHandler)
    
    // <<<<< ------ MOVE BETWEEN SNIPPETS (.photoItemDidMove) -------  >>>>>
    case let ( nil, nil, position? ):
     switch destSnippet.photoGroupType
     {
      case .typeGroups
       where position.sectionName != PhotoItemsTypes.allPhotos.rawValue:  observer.onCompleted()
        break MAIN_SWITCH
      
      case .makeGroups: self.photo.isDragMoved = true
      
      default: break
     }
     
     self.photo.move(to: destSnippet, to: position, with: contextResultHandler)
    
    // <<<<< ------ MOVE INSIDE FOLDER (.foldredPhotoDidMove) -------  >>>>>
    case let ( sourceFolder?, destFolder as PhotoFolderItem, position? )
     where sourceFolder.objectID == destFolder.folder.objectID:
     self.photo.moveInsideFolder(to: position, with: contextResultHandler)
    
    
    // <<<<< ------ MERGE WITH PHOTO (.photoItemDidMerge) -------  >>>>>
    case let (_ , destPhoto as PhotoItem, nil):
     self.photo.merge(with: destPhoto.photo, with: contextResultHandler)
    
    default: break
   }//switch ...
   
   return disposable
    
  }//final func move....
 }//return Completable.create...
}//extension PhotoItem ...fully reactive approach...
