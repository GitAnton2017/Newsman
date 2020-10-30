//
//  Photo Folder MO Deletion (RxSwift).swift
//  Newsman
//
//  Created by Anton2016 on 04.12.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import protocol RxSwift.Disposable


extension PhotoFolder
{
 func deleteRx ()
 {
  guard let folderID = self.ID else { return }         //fix ID before deleting from context!!
  let folderedIDs = folderedPhotos.compactMap{ $0.ID } //fix all foldered photos IDs before deleting from context!!
 
  var deletable: Disposable?
  
  deletable = deleteCompletable.debug("<**** DELETER PHOTO FOLDER (RX) ****>").subscribe(onCompleted: {
    defer {
     folderedIDs.forEach { photoID in
      PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: photoID as NSString) }
     }
     deletable?.dispose()
    }
    print("<<<< PHOTO FOLDER MO HAS BEEN SUCCESSFULLY DELETED! >>>> [\(self)][\(folderID)] ")
   },
   onError: { error in
     print("<<<< ERROR DELETING PHOTO FOLDER MO!>>>> [\(self)][\(folderID)]\(error.localizedDescription)")
   })
 }//func deleteRx ()...
 
}//extension Photo...
