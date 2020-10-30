//
//  Photo MO Deletion (RxSwift).swift
//  Newsman
//
//  Created by Anton2016 on 28.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import protocol RxSwift.Disposable

extension Photo
{
 func deleteRx ()
 {
  guard let deletedID = self.ID else { return }
  
  //fix ID before deleting from context!!
 
  var deletable: Disposable?
  
  deletable = deleteCompletable.debug("<**** DELETER PHOTO (RX) ****>")
   .subscribe(onCompleted: {
     defer {
      PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: deletedID as NSString) }
      deletable?.dispose()
     }
     print("<<<< PHOTO MO HAS BEEN SUCCESSFULLY DELETED! >>>> [\(self)][\(deletedID)] ")
   }, onError: { error in
     print("<<<< ERROR DELETING PHOTO MO!>>>> [\(self)][\(deletedID)]  \(error.localizedDescription)")
   })
 }//func deleteRx ()...
 
}//extension Photo...
