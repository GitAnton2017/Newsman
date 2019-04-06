//
//  Snippets Item Provider.swift
//  Newsman
//
//  Created by Anton2016 on 14/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData

extension SnippetDragItem
{
 private static let snippetsUTI = "Newsman.snippets.uti"
 
 enum SnippetDragError: Error
 {
  case loadError
  case readError
  case fetchError
 }
 
 
 enum SnippetKeys: CodingKey
 {
  case snippetID
 }
 
 
 func encode(to encoder: Encoder) throws
 {
  var container = encoder.container(keyedBy: SnippetKeys.self)
  try container.encode(self.id, forKey: .snippetID)

 }
 
 
 convenience init(from decoder: Decoder) throws
 {
  let container = try decoder.container(keyedBy: SnippetKeys.self)
  let snippetID = try container.decode(UUID.self, forKey: .snippetID)
  
  if let snippet = SnippetDragItem.MOC.registeredObjects.compactMap({$0 as? BaseSnippet})
                                                        .first(where: {$0.id == snippetID})
  {
   self.init(snippet: snippet)
  }
  else
  {
   let frq: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
   let IDPred = NSPredicate(format: "SELF.id == %@", snippetID as CVarArg)
   frq.predicate = IDPred
   
   if let snippet = try SnippetDragItem.MOC.fetch(frq).first
   {
    self.init(snippet: snippet)
   }
   else
   {
    throw SnippetDragError.fetchError
   }
  }
  
 
 }

 
 static var writableTypeIdentifiersForItemProvider: [String]
 {
  return [snippetsUTI]
 }
 
 func loadData(withTypeIdentifier typeIdentifier: String,
               forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
 {
  
  switch typeIdentifier
  {
   case SnippetDragItem.snippetsUTI:
    do
    {
     completionHandler (try PropertyListEncoder().encode(self), nil)
    }
    catch
    {
     completionHandler (nil, error)
    }
   
   default: completionHandler (nil, SnippetDragError.loadError)
  }
  return nil
 }
 
 static var readableTypeIdentifiersForItemProvider: [String]
 {
  return [snippetsUTI]
 }
 
 static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
 {
  switch typeIdentifier
  {
   case SnippetDragItem.snippetsUTI:
    return try PropertyListDecoder().decode(self, from: data)
   
   default:
    throw SnippetDragError.readError
  }
 }
 
}
