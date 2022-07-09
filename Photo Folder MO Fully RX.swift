//
//  Photo Folder MO Fully RX.swift
//  Newsman
//
//  Created by Anton2016 on 01/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

extension PhotoFolderItem
{
 
 //Moves wrapped Photo MO asyncronously to the destination item that conforms to Draggable protocol
 final func move(to snippet: BaseSnippet,
                 to photoItem: Draggable?,
                 to position: PhotoItemPosition?) -> Observable<Draggable>
 {
  print(#function)
  
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
    switch result
    {
     case .success(let notification): NotificationCenter.default.post(notification)
      observer.onNext(self)
      observer.onCompleted()
     
     case .failure(let error):
      observer.onError(DraggableError.moveError(item: self, contextError: error))
    }
   }//let contextResultHandler:...
   
   
   MAIN_SWITCH: switch (photoItem, position)
   {
    case (nil, let position?):
     switch destSnippet.photoGroupType
     {
      case .typeGroups
       where position.sectionName != PhotoItemsTypes.allFolders.rawValue:
        self.folder.unfolder(to: destSnippet, to: position, with: contextResultHandler)
        break MAIN_SWITCH
      
      case .makeGroups: self.folder.isDragMoved = true
      
      default: break
     }
     
     
     self.folder.move(to: destSnippet, to: position, with: contextResultHandler)
    
    case (let folderItem as PhotoFolderItem, let position?):
     self.folder.folder(to: folderItem.folder, to: position, with: contextResultHandler)
    
    case (let photoItem as PhotoItem, nil):
     self.folder.merge(with: photoItem.photo, with: contextResultHandler)
    
    default: break
    
   }//MAIN_SWITCH: switch ...
   
   return disposable
  }//return Completable.create...
 }//final func move(to snippet: BaseSnippet...
}//extension PhotoFolderItem...
