//
//  MO Operations Errors.swift
//  Newsman
//
//  Created by Anton2016 on 23/07/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData

protocol LoggableError: Error, CustomDebugStringConvertible, CustomStringConvertible
{
 var errorLogHeader: String  { get }
 var errorLogMessage: String { get }
}

extension LoggableError
{
 func log() { print(debugDescription) }
}


enum ContextError
{
 
 case performCnangesError(context: NSManagedObjectContext,
                          object: NSManagedObject,
                          entity: ContextEntityTypes,
                          operation: ContextOperationTypes,
                          blockError: Error)
 
 case contextSaveError (context: NSManagedObjectContext,
                        object: NSManagedObject,
                        entity: ContextEntityTypes,
                        operation: ContextOperationTypes)
 
 case noContext(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case noURL(object: NSManagedObject,
            entity: ContextEntityTypes,
            operation: ContextOperationTypes)
 
 case noID(object: NSManagedObject,
            entity: ContextEntityTypes,
            operation: ContextOperationTypes)
 
 case isDeleted(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case noContexts(objects: [NSManagedObject],
                 entity: ContextEntityTypes,
                 operation: ContextOperationTypes)
 
 case noSnippet(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case noFolder (object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case inFolder (object: NSManagedObject,
                folder: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case dataFileMoveFailure (to: URL,
                           object: NSManagedObject,
                           entity: ContextEntityTypes,
                           operation: ContextOperationTypes,
                           description: String)
 
 case dataDeleteFailure (at: URL,
                         object: NSManagedObject,
                         entity: ContextEntityTypes,
                         operation: ContextOperationTypes,
                         description: String)
 
 
 case emptyFolder (object: NSManagedObject,
                   entity: ContextEntityTypes,
                   operation: ContextOperationTypes)
 
 case dataFolderCreateFailure (at: URL,
                               object: NSManagedObject,
                               entity: ContextEntityTypes,
                               operation: ContextOperationTypes,
                               description: String)
}

extension ContextError: LoggableError
{
 var errorLogHeader: String { return "ERROR OCCURED WHEN" }
 
 var errorLogMessage: String
 {
  switch self
  {
   case let .contextSaveError(context: context, object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> SAVE CONTEXT FAILED FOR: <\(context)>."
   
   case let .noContext(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) HAS NO ASSOCIATED CONTEXT!"
   
   case let .noURL(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) HAS NO DATA URL!"
   
   case let .isDeleted(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) IS MARKED DELETED FROM CONTEXT!"
   
   case let .noID(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) HAS NO ID!"
   
   case let .noContexts(objects: objects, entity: entity, operation: operation):
    return "\(operation + entity): <\(objects)> \(entity.rawValue) HAVE NO ASSOCIATED CONTEXT!"
    
   case let .noSnippet(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) HAS NO ASSOCIATED SNIPPET!"
   
   case let .noFolder(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) IS NOT FOLDERED YET!"
   
   case let .inFolder(object: object, folder: folder, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> \(entity.rawValue) IS ALREADY FOLDERED INTO THIS FOLDER <\(folder)>!"
   
   case let .dataFileMoveFailure(to: url, object: obj, entity: ent, operation: op, description: ds):
    return "\(op + ent): <\(obj)> MOVING \(ent.rawValue) DATA TO NEW <\(url)> FAILED WITH MESSAGE <<\(ds)>>."
   
   case let .dataDeleteFailure(at: url, object: obj, entity: ent, operation: op, description: ds):
    return "\(op + ent): <\(obj)> DELETING \(ent.rawValue) DATA AT <\(url)> FAILED WITH MESSAGE <<\(ds)>>."
  
   case let .emptyFolder(object: object, entity: entity, operation: operation):
    return "\(operation + entity): <\(object)> UNEXPECTED EMPTY FOLDER ENCOUNTERED!"
   
   case let .dataFolderCreateFailure(at: url, object: obj, entity: ent, operation: op, description: ds):
    return "\(op + ent): <\(obj)> CREATING DATA FOLDER AT <\(url)> FAILED WITH MESSAGE <<\(ds)>>."
   
   case let .performCnangesError(context: moc, object: obj, entity: ent, operation: op, blockError: error):
    return "\(op + ent): <\(obj)> PERFORM BLOCK CHANGES FAILED FOR: <\(moc)> WITH BLOCK ERROR <\(error.localizedDescription)>."
  }
 }
 
 var debugDescription: String { return errorLogHeader + " " + errorLogMessage }
 var description:      String { return errorLogHeader + " " + errorLogMessage }
 
 
}
