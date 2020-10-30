

import Foundation
import protocol RxSwift.Disposable

extension PhotoSnippet: DeletableManagedObjectProtocol
{
 func delete()
 {
  guard let snippetID = self.id?.uuidString else { return }         //fix ID before deleting from context!!
  let allPhotosIDs = allPhotos.compactMap{ $0.ID }
 
  var deletable: Disposable?
  
  deletable = deleteCompletable.debug("<**** DELETER PHOTO SNIPPET (RX) ****>").subscribe(onCompleted:
  {
    defer
    {
     allPhotosIDs.forEach { photoID in
      PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: photoID as NSString) }
     }
     deletable?.dispose()
    }
    print("<<<< PHOTO SNIPPET HAS BEEN SUCCESSFULLY DELETED! >>>> [\(self)][\(snippetID)] ")
   },
   onError: { error in
     print("<<<< ERROR DELETING PHOTO SNIPPET!>>>> [\(self)][\(snippetID)]\(error.localizedDescription)")
   })

 }
}

