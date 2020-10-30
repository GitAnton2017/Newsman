//
//  Photo Folder MO Manipulations.swift
//  Newsman
//
//  Created by Anton2016 on 21/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData

extension PhotoFolderItem
{
 
 private func moveSinglePhotoDraggedItems()
 {
  print(#function)
  if let index = (AppDelegate.globalDragItems.firstIndex{$0.hostedManagedObject.objectID == folder.objectID})
  {
   AppDelegate.globalDragItems.remove(at: index)
   AppDelegate.globalDropItems.append(contentsOf: singlePhotoItems)
  }
 }
 
 private func moveDraggedFolder()
 {
  print(#function)
  if let index = (AppDelegate.globalDragItems.firstIndex{$0.hostedManagedObject.objectID == folder.objectID})
  {
   AppDelegate.globalDragItems.remove(at: index)
   AppDelegate.globalDropItems.append(self)
  }
 }
 
 final func move(to snippet: BaseSnippet, to draggableItem: Draggable?)
 {
  print(#function)
  
  guard let snippet = snippet as? PhotoSnippet else { return }
  switch draggableItem
  {
   case nil:                                folder.move(to: snippet)               //moveDraggedFolder()
   case let folderItem as PhotoFolderItem:  folder.refolder(to: folderItem.folder) //moveSinglePhotoDraggedItems()
   case let photoItem as PhotoItem:         folder.merge(with: photoItem.photo)    //moveSinglePhotoDraggedItems()
   default: break
   
  }
 }
}//extension PhotoFolderItem...




extension PhotoFolder //managed object extension
{
 final func refolder(to destination: PhotoFolder)
 {
  guard let context = self.managedObjectContext else
  {
   print(#function, terminator: ">>> ")
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  guard self !== destination else
  {
   print(#function, terminator: ">>> ")
   print ("THE FOLDER IS NOT ALLOWED TO BE REFOLDERED INTO SELF!")
   return
  }
  
  let foldered = NSSet(array: folderedPhotos)
  guard foldered.count > 0 else
  {
   print(#function, terminator: ">>> ")
   print("<<<MODEL ERROR>>>: Unexpected Folder \(self.description) With: \(foldered.count) photos encountered!")
   return
  }
  
  guard let destFolderURL = destination.url else { return }
  guard let sourceFolderURL = self.url else { return }
  let photoURLs = self.folderedPhotos
   .filter{$0.ID != nil && $0.url != nil }
   .map{(from: $0.url!, to: destFolderURL.appendingPathComponent($0.ID!))}
  
  context.persistAndWait(block:
  {
   self.removeFromPhotos(foldered)
   destination.addToPhotos(foldered)
   
   if (destination.photoSnippet !== self.photoSnippet)
   {
    self.photoSnippet?.removeFromPhotos(foldered)
    destination.photoSnippet?.addToPhotos(foldered)
   }
   else
   {
    self.photoSnippet?.currentFRC?.deactivateDelegate()
   }
  
   context.delete(self)
    
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    return
   }
   
   photoURLs.forEach{PhotoItem.movePhotoItemOnDisk(from: $0.from, to: $0.to)}
   
   print ("<<<<< REMOVING EMPTIFIED FOLDER FROM DISK... >>>>>")
   PhotoItem.deletePhotoItemFromDisk(at: sourceFolderURL)
   
  }
  
  self.photoSnippet?.currentFRC?.activateDelegate()
  
 }
 
 
 final func move(to snippet: PhotoSnippet)
 {
  guard self.photoSnippet !== snippet else
  {
   print (#function, "<<<Folders inside Snippet are not moved in MOC!>>>")
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   print(#function, terminator: ">>> ")
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  let foldered = NSSet(array: folderedPhotos)
  guard foldered.count > 0 else
  {
   print(#function, terminator: ">>> ")
   print("<<<MODEL ERROR>>>: Unexpected Folder \(self.description) With: \(foldered.count) photos encountered!")
   return
  }
  
  guard let sourceFolderURL = self.url else { return }
  
  context.persistAndWait(block:
  {
   self.photoSnippet?.removeFromPhotos(foldered)
   snippet.addToPhotos(foldered)
   
   self.photoSnippet?.removeFromFolders(self)
   snippet.addToFolders(self)
   
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    return
   }
   
   guard let toFolderURL = self.url else { return }
   PhotoItem.movePhotoItemOnDisk(from: sourceFolderURL, to: toFolderURL)  //move entire folder on disk
  }
 }
 
 
 
 
 final func merge(with photo: Photo)
  //Merges <Syncronously> this PhotoFolder MO with other Photo MO in one PhotoFolder MO creating one in the current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<Folder MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  guard let snippet = photo.photoSnippet else
  {
   print ("<<<Folder MO Processing Critical Error!>>> MO \(self.description) has no associated snippet!")
   return
  }
  
  
  // if destination photo is already contained in some folder we move self into this folder and return...
  switch photo.folder
  {
   case let destinationFolder?:
    refolder(to: destinationFolder)
    return
   default: break //continue merging into new folder....
  }
  
  //otherwise we create new empty folder and move self and destination into it
  let newFolderID = UUID()
  var newFolder: PhotoFolder?
  
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  context.persistAndWait(block:       //make changes in context sync
  {
    newFolder = PhotoFolder(context: context)
    newFolder?.id = newFolderID
    newFolder?.photoSnippet = snippet
    newFolder?.date = Date() as NSDate
    newFolder?.isSelected = false
    newFolder?.position = photo.position          //fix new Folder Position at Photo position
    newFolder?.priorityFlag  = photo.priorityFlag //fix new Folder section flag at Photo section
    newFolder?.photos = NSSet()
    
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("ERROR CREATING FOLDER IN MOC: \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    return
   }
   
   guard let newFolderURL = newFolder!.url else { return }
   PhotoFolderItem.createNewPhotoFolderOnDisk(at: newFolderURL)
   
   self.refolder(to: newFolder!)
   photo.folder(to: newFolder!)
   
   self.photoSnippet?.currentFRC?.activateDelegate()
   
  }
 } //final func merge (sync)

}//extension PhotoFolder...
