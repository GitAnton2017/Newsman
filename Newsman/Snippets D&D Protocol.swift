//
//  Snippets Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 14/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData


protocol SnippetProtocol: NSItemProviderWriting, NSItemProviderReading, Codable, Draggable
{
 var type: SnippetType              { get     }
 var location: String?              { get     }
 var snippet: BaseSnippet           { get     }
 var date: Date                     { get     }
 var priority: SnippetPriority      { get     }
 var url: URL                       { get     } //conformer url getter to get access to the virtual data files
 
 func deleteAllData()
 
 func cancelProviderOperations() //cancells all provider async processing operations
 func toggleSelection()

}



func == (lhs: SnippetProtocol?, rhs: SnippetProtocol?) -> Bool
{
 return lhs?.hostedManagedObject === rhs?.hostedManagedObject
}

func != (lhs: SnippetProtocol?, rhs: SnippetProtocol?) -> Bool
{
 return lhs?.hostedManagedObject !== rhs?.hostedManagedObject
}

extension SnippetProtocol
{
 
 static var appDelegate: AppDelegate
 {
  if (Thread.current == Thread.main)
  {
   return UIApplication.shared.delegate as! AppDelegate
  }
  
  return DispatchQueue.main.sync
   {
    return UIApplication.shared.delegate as! AppDelegate
  }
 }
 
 static func saveContext()
 {
  appDelegate.saveContext()
 }
 
 static var MOC: NSManagedObjectContext
 {
  return appDelegate.persistentContainer.viewContext
 }
 
 
}
