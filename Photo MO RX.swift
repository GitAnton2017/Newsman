//
//  Photo Item Wrapper Moves.swift
//  Newsman
//
//  Created by Anton2016 on 19/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData


enum PhotoItemMovedKey: String, Hashable
{
 case destPhoto
 case destFolder
 case destSnippet
 case position
}

extension Notification.Name
{
 static let photoItemDidRefolder = Notification.Name(rawValue: "photoItemDidRefolder")
 static let photoItemDidUnfolder = Notification.Name(rawValue: "photoItemDidUnfolder")
 static let photoItemDidFolder =   Notification.Name(rawValue: "photoItemDidFolder"  )
 static let photoItemDidMove =     Notification.Name(rawValue: "photoItemDidMove")
 static let photoItemDidMerge =    Notification.Name(rawValue: "photoItemDidMerge")
}

struct PhotoItemPosition
{
 let sectionName: String?
 let row: Int16
 let sectionKeyPath: String?
 
 init(sectionName: String, row: Int16, for sectionKeyPath: String)
 {
  self.sectionName = sectionName
  self.sectionKeyPath = sectionKeyPath
  self.row = row
 }
 
 
 init(_ row: Int16)
 {
  self.sectionName = nil
  self.sectionKeyPath = nil
  self.row = row
 }
}

extension PhotoItem
{

//Moves wrapped Photo MO asyncronously to the destination PhotoSnippet MO and to photo item as specified.
 
 final func move(to snippet: PhotoSnippet, to photoItem: PhotoItemProtocol?,
                 to position: PhotoItemPosition,  completion: ( () -> () )? = nil)
 {
  switch (snippet === photoSnippet, self.folder, photoItem)
  {
   case let (true, _?,  destFolder as PhotoFolderItem):
    photo.refolder(to: destFolder.folder, to: position.row)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [.destFolder : destFolder, .position : position]
     NotificationCenter.default.post(name: .photoItemDidRefolder, object: self, userInfo: userInfo)
     completion?()
    }
   
   case     (true, _?,  nil        ):
    photo.unfolder(to: position)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [ .position : position]
     NotificationCenter.default.post(name: .photoItemDidUnfolder, object: self, userInfo: userInfo)
     completion?()
    }
   
   case let (true, nil, destFolder as PhotoFolderItem):
    photo.folder(to: destFolder.folder, to: position.row)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [.destFolder : destFolder, .position : position]
     NotificationCenter.default.post(name: .photoItemDidFolder, object: self, userInfo: userInfo)
     completion?()
    }
   
   case  (true, nil, nil):
    photo.move(to: position)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [.position : position]
     NotificationCenter.default.post(name: .photoItemDidMove, object: self, userInfo: userInfo)
     completion?()
    }

   case let (false, _,  destFolder as PhotoFolderItem?):
    photo.move(to: snippet, to: destFolder?.folder,  to: position)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [.destSnippet : snippet, .destFolder : destFolder as Any,
                                               .position : position]
  
     NotificationCenter.default.post(name: .photoItemDidMove, object: self, userInfo: userInfo)
     completion?()
    }
   
   case let (_ ,  _ , destPhoto as PhotoItem):
    photo.merge(in: snippet, with: destPhoto.photo, into: position)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [.destSnippet : snippet, .destPhoto : destPhoto,.position : position]
     NotificationCenter.default.post(name: .photoItemDidMerge, object: self, userInfo: userInfo)
     completion?()
    }
   
   
   default: break
  }
 }
 
}



extension Photo
{
 final func folder(to destination: PhotoFolder, to position: Int16, with completion: ( () -> () )? = nil)
 //Puts <Asyncronously> unfoldered photo managed object into the destionation folder of the same PhotoSnippet.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  let fromURL = self.url
  context.persist(block:   //make changes in context async
  {
   destination.addToPhotos(self)
   self.position = position
  })
  {persisted in
   guard persisted else { return }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {moved in
    guard moved else { return }
    completion?()
   }

  }
 }
 
 

 
 final func refolder(to destination: PhotoFolder, to position: Int16, with completion: ( () -> () )? = nil)
  //Puts <Asyncronously> foldered photo managed object into the destionation new folder of the same PhotoSnippet.
  //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  guard let sourceFolder = self.folder else //Photo must be foldered at this stage!
  {
   print(#function, terminator: ">>> ")
   print ("<<<PHOTO PRECONDITION FAILURE>>>. PHOTO REFOLDER ERROR. THIS PHOTO IS NOT FOLDERED YET!")
   return
  }
  
  guard sourceFolder !== destination else { return } //Photo must be foldered into different source folder!!!
  
  let fromURL = self.url
  context.persist(block: //make changes in context async
  {
    destination.addToPhotos(self)
    self.position = position
    sourceFolder.removeFromPhotos(self)
  })
  {persisted in
   guard persisted else { return }
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {moved in
    guard moved else { return }
    self.updateSourceFolder(sourceFolder: sourceFolder)
    {updated in
     guard updated else { return }
     completion?()
    }
   
   }
   
  }
 }
 
 

 
 private func updateSourceFolder(sourceFolder: PhotoFolder, with handler: @escaping (Bool) -> () )
  //Updates <Asyncronously> source folder so that the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
 
  let sourceFolderURL = sourceFolder.url //Make copy of PhotoFolder URL to be updated...
  let sourceFolderID = sourceFolder.id?.uuidString ?? "<NO ID>"
  
  switch sourceFolder.count
  {
   case 0:
    print(#function, terminator: ">>> ")
    print ("<<<ERROR! EMPTY FOLDER UNEXPECTED HERE: \"\(sourceFolderID)\">>>")
   
   case 1:
    //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
    let singlePhoto = sourceFolder.folderedPhotos.first!
    let singlePhotoFromURL = singlePhoto.url
    context.persist(block: //make changes in context async
    {
     sourceFolder.removeFromPhotos(singlePhoto)
     singlePhoto.position = sourceFolder.position
     self.managedObjectContext?.delete(sourceFolder)
    })
    {persisted in
     guard persisted else { handler(false); return }
     
     PhotoItem.movePhotoItemOnDisk(from: singlePhotoFromURL, to: singlePhoto.url)
     {moved in
      guard moved else { handler(false); return }
      PhotoItem.deletePhotoItemFromDisk(at: sourceFolderURL, completion: handler)
     }
    }
   
   default: break // Successful completion here by default!
  }
 }
 
 
 
 
 
 final func unfolder(to itemPosition: PhotoItemPosition, with completion: ( () -> () )? = nil)
  //Moves <Asyncronously> Photo MO into current PhotoSnippet from current folder.
  //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  guard let sourceFolder = self.folder else
  {
   print(#function, terminator: ">>> ")
   print ("<<<PRECONDITION FAILURE>>> PHOTO UNFOLDER ERROR. THIS PHOTO IS NOT FOLDERED YET!")
   return
  }
  

  let fromURL = self.url //Make copy of Photo MO URL before moving...
  
  context.persist(block: //make changes in context async
  {
   sourceFolder.removeFromPhotos(self)
   if let key = itemPosition.sectionKeyPath { self.setValue(itemPosition.sectionName, forKey: key) }
   self.position = itemPosition.row
  })
  {persisted in
   guard persisted else { return }
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {moved in
    guard moved else { return }
    self.updateSourceFolder(sourceFolder: sourceFolder)
    {updated in
     guard updated else { return }
     completion?()
    }
    
   }
 
  }
 }
 

 
 final func move(to snippet: PhotoSnippet, to folder: PhotoFolder?,
                 to itemPosition: PhotoItemPosition, with completion: ( () -> () )? = nil)
 //Moves ASYNC Photo MO from arbitrary PhotoSnippet and folder into snippet and folder.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  let sourceFolder = self.folder //take reference to source folder before moving...
  
  let fromURL = self.url //Make copy of Photo MO URL before moving...
  
  context.persist(block: //make changes in context async
  {
   sourceFolder?.removeFromPhotos(self)
   self.photoSnippet?.removeFromPhotos(self)
   snippet.addToPhotos(self)
   folder?.addToPhotos(self)
   if let key = itemPosition.sectionKeyPath { self.setValue(itemPosition.sectionName, forKey: key) }
   self.position = itemPosition.row
  })
  {persisted in
   guard persisted else { return }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {moved in
    guard moved else { return }
    guard sourceFolder != nil else { completion?(); return }
    self.updateSourceFolder(sourceFolder: sourceFolder!)
    {updated in
     guard updated else { return }
     completion?()
    }
    
   }

  }
 }
 
 final func move(to itemPosition: PhotoItemPosition, with completion: ( () -> () )? = nil)
  //Moves ASYNC unfoldered Photo MO whithin its own Photo snippet.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  context.persist(block: //make changes in context async
  {
   if let key = itemPosition.sectionKeyPath { self.setValue(itemPosition.sectionName, forKey: key) }
   self.position = itemPosition.row
  })
  {persisted in
   guard persisted else { return }
   completion?()
  }
 }
 
 final func merge (in snippet: PhotoSnippet, with photo: Photo,
                   into position: PhotoItemPosition, with completion: (() -> ())? = nil)
  //Merges <Syncronously> this Photo MO with other Photo MO in one PhotoFolder MO creating one in the current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  guard self !== photo else {return} //prevent merging with itself!!!
  
  // if destination photo is already contained in some folder we move self into this folder and return in each case...
  
  switch (snippet === self.photoSnippet, self.folder, photo.folder)
  {
   case let (false, _ ,  destinationFolder?):
    move(to: snippet, to: destinationFolder,
         to: PhotoItemPosition(Int16(destinationFolder.count)), with: completion)
    return
   case let (true,  _?,  destinationFolder?):
    refolder (to: destinationFolder, to: Int16(destinationFolder.count), with: completion)
    return
   case let (true,  nil, destinationFolder?):
    folder   (to: destinationFolder, to: Int16(destinationFolder.count), with: completion)
    return
   default: break //continue merging into new folder....
  }
  
  //otherwise we create new empty folder and move self and destination into it
  let newFolderID = UUID()
  var newFolder: PhotoFolder?
  
  context.persist(block:       //make changes in context async
  {
    newFolder = PhotoFolder(context: context)
    newFolder?.id = newFolderID
    newFolder?.photoSnippet = snippet
    newFolder?.date = Date() as NSDate
    newFolder?.isSelected = false
    newFolder?.position = photo.position          //fix new Folder Position at Photo position
    if let key = position.sectionKeyPath
    {
     let value = photo.value(forKey: key)
     newFolder?.setValue(value, forKey: key)
     //fix new Folder section flag at Photo section
    }
    newFolder?.photos = NSSet()
    
  })
  {persisted in
   guard persisted else
   {
    print(#function, terminator: ">>> ")
    print("ERROR CREATING FOLDER IN MOC: \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    return
   }
   
   PhotoFolderItem.createNewPhotoFolderOnDisk(at: newFolder!.url)
   {created in
    guard created else { return }
    
    photo.folder(to: newFolder!, to: 0)
    {
     switch (snippet === self.photoSnippet, self.folder)
     {
      case (true,  _?)  :  self.refolder (to: newFolder!, to: 0, with: completion)
      case (true, nil)  :  self.folder   (to: newFolder!, to: 0, with: completion)
      case (false,  _)  :  self.move(to: snippet, to: newFolder,
                                     to: PhotoItemPosition(0), with: completion)
     }
    }
   }
  }
  
 } //final func merge (async)
 
 
} //Photo Managed Object extension...
