//
//  Photo MO Deletion.swift
//  Newsman
//
//  Created by Anton2016 on 06.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import class Foundation.NSString
import class Foundation.NotificationCenter

extension Photo: DeletableManagedObjectProtocol
{
 func delete()
 {
   deleteRx()
   //deleteCombine()
   //deleteBase()
 }
 
 func deleteBase() //Photo MO delete processing...
 {
  guard let deletedID = self.ID  else { return }     //fix ID before deleting from context!!
  let deletedFolder = self.folder  //take ref to photo folder if any before deleting from context!!
  
  undoer.removeAllOperations(for: self) as Void
  
  deleteFromContextAndDisk
  {result in
   switch result
   {
    case .success(let url):
     print("PHOTO MO IMAGE DATA FILE HAS BEEN SUCCESSFULLY DELETED AT URL: \(url)")
     PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: deletedID as NSString) }
     
    if ( deletedFolder != nil && deletedFolder!.count == 1 )
    {
     deletedFolder!.processSinglePhoto
     {result in
      switch result
      {
       case .success(let singlePhoto):
        NotificationCenter.default.post(name: .singleItemDidUnfolder, object: singlePhoto)
       
       case .failure(let error): error.log() //otherwise log an error message...
      }
     }
    }
     
    
    case .failure(let deleteError):
     switch deleteError
     {
      case .deleteFailure(at: let url, description: let description):
       print("PHOTO MO IMAGE DATA FILE DELETE FAILURE AT URL: \(url) <<<\(description)>>>" )
      case .noContext(let object):
       print("PHOTO MO: \(object.description) HAS NO ASSOCIATED CONTEXT!")
      default: break  // reported before in save context closure if any
     }//switch deleteError...
    
   }//switch result...
  }//deleteFromContextAndDisk...
 }//func delete()...
}//extension Photo: ...

