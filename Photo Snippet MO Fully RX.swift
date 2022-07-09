//
//  Photo Snippet MO Fully RX.swift
//  Newsman
//
//  Created by Anton2016 on 01/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

extension SnippetDragItem
{
 func move(to snippet: BaseSnippet, to photoItem: Draggable?,
           to position: PhotoItemPosition?) -> Observable<Draggable>
 {
  return Observable<Draggable>.create
  {observer in
   let disposable = Disposables.create()
   let contextResultHandler: (Result<Notification, ContextError>) -> () =
   {result in
    switch result
    {
     case .success(let notification):
      NotificationCenter.default.post(notification)
      observer.onNext(self)
      observer.onCompleted()
     
     case .failure(let error):
       observer.onError(DraggableError.moveError(item: self, contextError: error))
    }
    
   }
   
   switch (self.snippet, snippet, photoItem, position)
   {
    
    case let (source as PhotoSnippet, dest as PhotoSnippet, nil, position?):
     //to do
     break
    
    
    
    // <<<<< FOLDER PHOTO SNIPPET INTO SNIPPET PHOTO FOLDER (.snippetItemDidFolder) >>>>>
    case let (source as PhotoSnippet, _ as PhotoSnippet, folderItem as PhotoFolderItem, position?):
     source.folder(to: folderItem.folder, to: position, with: contextResultHandler)
    
    
    
    case let (source as PhotoSnippet, _ as PhotoSnippet, photoItem as PhotoItem, nil):
     //to do...
     break
    
    default: break
    
   }// switch (self.snippet, snippet, photoItem, position)...
   
   return disposable
  }//return Observable<Notification>.create...
 }//func move(to snippet: BaseSnippet, to photoItem: Draggable?...
}//extension SnippetDragItem...
