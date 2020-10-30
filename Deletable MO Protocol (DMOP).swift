//
//  Deletable MO Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 06.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import Combine
import RxSwift

protocol DeletableManagedObjectProtocol: NSManagedObject,
                                         ManagedObjectContextObservable,
                                         OptionallyIdentifiable,InternalDataManageable
{
 func delete()
}

enum MODeleteError: Error
{
 case deleteFailure(at: URL, description: String)
 case noContext(for: NSManagedObject)
 case noURL(for: NSManagedObject)
 case noID(for: NSManagedObject)
 case contextSaveFailure
 case contextChangeFailure
 case unknown
}

extension DeletableManagedObjectProtocol
{
 func deleteFromContextAndDisk(with handler: @escaping (Result<URL, MODeleteError>) -> ())
 {
  guard let context = self.managedObjectContext else
  {
   handler(.failure(.noContext(for: self)))
   return
  }
  
  guard let deletedObjectURL = self.url else //fix deletable Self URL before deleting from MOC!
  {
   handler(.failure(.noURL(for: self)))
   return
  }
  
  context.performChanges( block:
  {
   (self as? PhotoItemManagedObjectProtocol)?.shiftRowPositionsBeforeDelete()
   switch self
   {
    case let photo as Photo:
     photo.folder?.removeFromPhotos(photo)
     photo.photoSnippet?.removeFromPhotos(photo)
    
    case let folder as PhotoFolder:
     folder.photoSnippet?.removeFromPhotos(folder.photos ?? [])
     folder.photoSnippet?.removeFromFolders(folder)

    default : break
   }
   
   context.delete(self)
  })
  {result  in
   guard case .success() = result else
   {
    handler(.failure(.contextChangeFailure))
    return
   }
   
   FileManager.removeItemFromDisk(at: deletedObjectURL)
   {result in
    switch result
    {
     case .success:
      handler(.success(deletedObjectURL))
     case .failure(let error):
      handler(.failure(.deleteFailure(at: deletedObjectURL, description: error.localizedDescription)))
    }
   }//FileManager.removeItemFromDisk...
  }//context.persist...
 }//func deleteFromContextAndDisk(with handler...
}//extension DeletableManagedObjectProtocol...

