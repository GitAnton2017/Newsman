//
//  Photo MO Deletetion (Combine).swift
//  Newsman
//
//  Created by Anton2016 on 28.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import class Combine.AnyCancellable
import class Foundation.NSString

extension Photo
{
 func deleteCombine()
 {
  undoer.removeAllOperations(for: self) as Void
  
  guard let snippet = self.photoSnippet else { return }
  guard let deletedID = self.ID else { return }
  //fix ID before deleting from context!!
 
  //var deletable: AnyCancellable?
  
  
  deletePublisher.print("<**** DELETER COMBINE ****>").sink(
   receiveCompletion:
   {completion in
    
    switch completion
    {
     case .finished:
      defer
      {
       PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: deletedID as NSString) }
       snippet.deletedPhotoItems.removeAll()
      }
      print("<<<< PHOTO MO HAS BEEN SUCCESSFULLY DELETED! >>>> [][\(deletedID)] ")
     
     case .failure(let error):
      print("<<<< ERROR DELETING PHOTO MO!>>>> [][\(deletedID)]  \(error.localizedDescription)")
    }
   }, receiveValue: { _ in }).store(in: &snippet.deletedPhotoItems)
  
  
 }//func deleteCombine ()...
}
