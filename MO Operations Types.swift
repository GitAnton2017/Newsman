//
//  MO Operations Types.swift
//  Newsman
//
//  Created by Anton2016 on 23/07/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

enum ContextOperationTypes: String
{
 case move = "MOVING"
 case undoMove = "UNDOING MOVING"
 
 case moveOnDisk = "MOVING DATA FILE ON DISK"
 case undoMoveOnDisk = "UNDOING MOVING DATA FILE ON DISK"
 
 case moveInside = "MOVING INSIDE FOLDER"
 case undoMoveInside = "UNDOING MOVING INSIDE FOLDER"
 
 case folder = "FOLDERING"
 case undoFolder = "UNDOING FOLDERING"
 
 case unfolder = "UNFOLDERING"
 case undoUnfolder = "UNDOING UNFOLDERING"
 
 case refolder = "REFOLDERING"
 case undoRefolder = "UNDOING REFOLDERING"
  
 case mergeWith = "MERGING WITH"
 case undoMergeWith = "UNDOING MERGING WITH"
 
 case delete = "DELETING"
 case undoDelete = "UNDOING DELETING"
 
 case cloudMetadataUpdate = "UPDATING CLOUD RECORD METADATA"
 
}

enum ContextEntityTypes: String
{
 case photo = "PHOTO"
 case destPhoto = "DESTINATION PHOTO"
 case sourcePhoto = "SOURCE PHOTO"
 
 case singlePhoto = "SINGLE PHOTO"
 case singlePhotoFolder = "SINGLE PHOTO FOLDER"
 
 case photoFolder = "PHOTO FOLDER"
 case destPhotoFolder = "DESTINATION PHOTO FOLDER"
 case sourcePhotoFolder = "SOURCE PHOTO FOLDER"
 
 case photoSnippet = "PHOTO SNIPPET"
 case destPhotoSnippet = "DESTINATION PHOTO SNIPPET"
 case sourcePhotoSnippet = "SOURCE PHOTO SNIPPET"
 
 case textSnippet = "TEXT SNIPPET"
 case multiple  = "MULTIPLE OBJECTS"
}

func + (operation: ContextOperationTypes, entity: ContextEntityTypes) -> String
{
 var infixClause: String
 {
  switch (operation, entity)
  {
   case (.move,         .destPhotoSnippet):    fallthrough
   case (.undoMove,     .destPhotoSnippet):    fallthrough
   
   case (.folder,       .destPhotoFolder):     fallthrough
   case (.undoFolder,   .destPhotoFolder):     fallthrough
   
   case (.refolder,     .destPhotoFolder):     fallthrough
   case (.undoRefolder, .destPhotoFolder):     fallthrough
   
   case (.undoMove,     .destPhotoFolder):     fallthrough
   case (.move,         .destPhotoFolder):     return " INTO "
   
   case (.refolder,     .sourcePhotoFolder):   fallthrough
   case (.undoRefolder, .sourcePhotoFolder):   fallthrough
   
   case (.move,         .sourcePhotoSnippet):  fallthrough
   case (.undoMove,     .sourcePhotoSnippet):  fallthrough
   
   case (.delete,       .sourcePhotoSnippet):  fallthrough
   case (.undoDelete,   .sourcePhotoSnippet):  fallthrough
   
   case (.delete,       .sourcePhotoFolder):   fallthrough
   case (.undoDelete,   .sourcePhotoFolder):   fallthrough
   
   case (.undoMove,     .sourcePhotoFolder):   fallthrough
   case (.move,         .sourcePhotoFolder):   return " FROM "
   
   default: break
  }
  return " "
 }
 
 return operation.rawValue + infixClause + entity.rawValue
}


