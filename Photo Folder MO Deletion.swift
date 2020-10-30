//
//  Photo Folder MO Deletion.swift
//  Newsman
//
//  Created by Anton2016 on 06.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension PhotoFolder: DeletableManagedObjectProtocol 
{
 
 func delete()
 {
  deleteRx()
  //deleteBase()
 }
 
 func deleteBase() //Photo Folder MO delete processing...
 {
  let deletedIDs = self.folderedPhotos.compactMap{ $0.ID }
  //fix all foldered photos IDs before deleting from context!!
  
  deleteFromContextAndDisk
  {result in
   switch result
   {
    case .success(let url):
     print("PHOTO FOLDER MO IMAGE DATA FILES FOLDER HAS BEEN SUCCESSFULLY DELETED AT URL: \(url)")
     deletedIDs.forEach
     {ID in
      PhotoItem.imageCacheDict.forEach{ $0.value.removeObject(forKey: ID as NSString) }
     }
    
    case .failure(let deleteError):
     switch deleteError
     {
      case .deleteFailure(at: let url, description: let description):
       print("PHOTO FOLDER MO IMAGE DATA FILES FOLDER DELETE FAILURE AT URL: \(url) <<<\(description)>>>" )
      case .noContext(let object):
       print("PHOTO FOLDER MO: \(object.description) HAS NO ASSOCIATED CONTEXT!")
      default: break  // reported before in save context closure if any
     }//switch deleteError...
    
   }//switch result...
  }//deleteFromContextAndDisk...
 }//func delete()...
}//extension PhotoFolder:...



