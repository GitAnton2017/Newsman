//
//  Photo Item Wrapper Moves.swift
//  Newsman
//
//  Created by Anton2016 on 19/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData


extension PhotoItem
{
 
 private func moveDraggedPhoto()
 {
  print(#function)
  if let index = AppDelegate.globalDragItems.index(where: {$0.hostedManagedObject === photo})
  {
   AppDelegate.globalDragItems.remove(at: index)
   AppDelegate.globalDropItems.append(self)
  }
 }
 
 final var folder: PhotoFolder? {return self.photo.folder} //the PhotoFolder MO where this Photo MO lives af any...
 
 final func move(to snippet: PhotoSnippet, to photoItem: PhotoItemProtocol?)
  //Moves wrapped Photo MO syncronously to the destination PhotoSnippet MO and to photo item as specified.
 {
  print(#function)
  //moveDraggedPhoto()
  switch (snippet === self.photoSnippet, self.folder, photoItem)
   //(<Source PhotoSnippet is the same as Destination PhotoSnippet?>, <Source PhotoFolder>, <Destination Item>)
  {
   case let (true, _?,  destFolder as PhotoFolderItem): photo.refolder(to: destFolder.folder)
    // the same PhotoSnippet, not NIL any source folder, not NIL destination folder, REFOLDER Photo MO...
   
   case     (true, _?,  nil        ): photo.unfolder()
    // the same PhotoSnippet, not NIL any source folder, no destination folder, UNFOLDER this Photo MO here...
   
   case let (true, nil, destFolder as PhotoFolderItem): photo.folder(to: destFolder.folder)
    // the same PhotoSnippet, no source folder, not NIL destination folder, FOLDER this Photo MO into destination folder...
   
   case let (false, _,  destFolder as PhotoFolderItem?): photo.move(to: snippet, to: destFolder?.folder)
    // different destination PhotoSnippet, any source, any destination, MOVE to the specified arbitrary destinations...
   
   case let (_ ,  _ , destPhoto as PhotoItem): photo.merge(in: snippet, with: destPhoto.photo)
    // Any PhotoSnippet, any source, not NIL destination PhotoItem, perform MERGE into new folder...
   
   default: break
  }
 }
 
 
 
 final func move(to snippet: PhotoSnippet, to photoItem: PhotoItemProtocol?, completion: @escaping (Bool) -> ())
  //Moves wrapped Photo MO asyncronously to the destination PhotoSnippet MO and to photo item as specified.
 {
  switch (snippet === photoSnippet, self.folder, photoItem)
  {
   case let (true, _?,  destFolder as PhotoFolderItem):
    photo.refolder(to: destFolder.folder, completion: completion)
   
   case     (true, _?,  nil        ): photo.unfolder(completion: completion)
   
   case let (true, nil, destFolder as PhotoFolderItem):
    photo.folder(to: destFolder.folder, completion: completion)
   
   case let (false, _,  destFolder as PhotoFolderItem?):
    photo.move(to: snippet, to: destFolder?.folder,  completion: completion)
   
   case let (_ ,  _ , destPhoto as PhotoItem): photo.merge(in: snippet, with: destPhoto.photo)
   
   default: break
  }
 }
 
}




extension Photo
{

 final func folder(to destination: PhotoFolder)
  //Puts <Syncronously> unfoldered photo managed object into the destionation folder of the same PhotoSnippet.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url
  context.persistAndWait(block:   //make changes in context sync
  {
    destination.addToPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    return
   }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   // if MOC has no save errors move underlying data file on disk.
  }
  
  self.photoSnippet?.currentFRC?.activateDelegate()
 }
 
 
 
 final func folder(to destination: PhotoFolder, completion: @escaping (Bool) -> ())
 //Puts <Asyncronously> unfoldered photo managed object into the destionation folder of the same PhotoSnippet.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url
  context.persist(block:   //make changes in context async
  {
   destination.addToPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    DispatchQueue.main.async{completion(false)}
    return
   }
   
   // if MOC has no save errors move underlying data file on disk async with completion.
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {success in
    DispatchQueue.main.async
    {
     self.photoSnippet?.currentFRC?.activateDelegate()
     completion(success)
    }
   }
  }
 }
 
 
 
 
 final func refolder(to destination: PhotoFolder)
  //Puts <Syncronously> foldered photo managed object into the destionation new folder of the same PhotoSnippet.
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
  
  guard sourceFolder !== destination else {return}  //Photo must be foldered into different source folder!!!
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url //Make copy of Photo URL before moving...
  
  context.persistAndWait(block:   //make changes in context sync
  {
    destination.addToPhotos(self)
    sourceFolder.removeFromPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    return
   }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   // if MOC has no save errors move underlying data file on disk.
   
   self.updateSourceFolder(sourceFolder: sourceFolder)
   // Update source folder to unfolder single Photo and delete this folder if emptified.
  }
  
  self.photoSnippet?.currentFRC?.activateDelegate()
 }
 
 
 
 
 final func refolder(to destination: PhotoFolder, completion: @escaping (Bool) -> ())
  //Puts <Asyncronously> foldered photo managed object into the destionation new folder of the same PhotoSnippet.
  //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  guard let sourceFolder = self.folder else //Photo must be foldered at this stage!
  {
   print(#function, terminator: ">>> ")
   print ("<<<PHOTO PRECONDITION FAILURE>>>. PHOTO REFOLDER ERROR. THIS PHOTO IS NOT FOLDERED YET!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  guard sourceFolder !== destination else {return} //Photo must be foldered into different source folder!!!
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url //Make copy of Photo URL before moving...
  
  context.persist(block: //make changes in context async
  {
    destination.addToPhotos(self)
    sourceFolder.removeFromPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
    DispatchQueue.main.async{completion(false)}
    return
   }
   
   // first off, if MOC has no save errors move underlying data file on disk async with completion...
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {success in
    guard success else
    {
     DispatchQueue.main.async{completion(false)}
     return
    }
     // Update source folder async with completion. Unfolder single Photo and delete this folder if emptified.
    self.updateSourceFolder(sourceFolder: sourceFolder)
    {success in
     DispatchQueue.main.async
     {
      self.photoSnippet?.currentFRC?.activateDelegate()
      completion(success)
     }
    }
   }
  }
 }
 
 
 
 private func updateSourceFolder(sourceFolder: PhotoFolder)
  //Updates source folder <Syncronously> so that the single Photo is unfoldred into this PhotoSnippet.
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
   case 0: //Error empty folder! Unexpected empty folder here!
    print(#function, terminator: ">>> ")
    print ("<<<ERROR! EMPTY FOLDER UNEXPECTED HERE: \"\(sourceFolderID)\">>>")
   
   case 1: //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
    let singlePhoto = sourceFolder.folderedPhotos.first!
    let singlePhotoFromURL = singlePhoto.url
    
    context.persistAndWait(block: //make changes in context sync
    {
      sourceFolder.removeFromPhotos(singlePhoto)
      self.managedObjectContext?.delete(sourceFolder)
    })
    {flag in
     guard flag else
     {
      print(#function, terminator: ">>> ")
      print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
      return
     }
     
     PhotoItem.movePhotoItemOnDisk(from: singlePhotoFromURL, to: singlePhoto.url)
     PhotoItem.deletePhotoItemFromDisk(at: sourceFolderURL)
     print ("<<<EMPTIFIED FOLDER: \"\(sourceFolderID)\" HAS BEEN DELETED FROM CURRENT MOC SUCCESSFULLY!>>>")
    }
   
   default: break
  }
 }
 
 
 
 
 
 private func updateSourceFolder(sourceFolder: PhotoFolder, completion: @escaping (Bool) -> ())
  //Updates <Asyncronously> source folder so that the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   DispatchQueue.main.async{completion(false)}
   return
  }
 
  let sourceFolderURL = sourceFolder.url //Make copy of PhotoFolder URL to be updated...
  let sourceFolderID = sourceFolder.id?.uuidString ?? "<NO ID>"
  
  switch sourceFolder.count
  {
   case 0:
    print(#function, terminator: ">>> ")
    print ("<<<ERROR! EMPTY FOLDER UNEXPECTED HERE: \"\(sourceFolderID)\">>>")
    DispatchQueue.main.async{completion(false)} //Error empty folder! Unexpected empty folder here!
   case 1:
    //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
    let singlePhoto = sourceFolder.folderedPhotos.first!
    let singlePhotoFromURL = singlePhoto.url
    
    context.persist(block: //make changes in context async
    {
      sourceFolder.removeFromPhotos(singlePhoto)
      self.managedObjectContext?.delete(sourceFolder)
    })
    {flag in
     guard flag else
     {
      print(#function, terminator: ">>> ")
      print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "<Undefined>") MO: \(self.description)")
      DispatchQueue.main.async{completion(false)}
      return
     }
     
     PhotoItem.movePhotoItemOnDisk(from: singlePhotoFromURL, to: singlePhoto.url)
     {success in
      guard success else
      {
       DispatchQueue.main.async{completion(false)}
       return
      }
      PhotoItem.deletePhotoItemFromDisk(at: sourceFolderURL)
      {success in
       if success {print("<<<EMPTIFIED FOLDER: \"\(sourceFolderID)\" DELETED FROM CURRENT MOC SUCCESSFULLY!>>>")}
       DispatchQueue.main.async{completion(success)}
      }
     }
    }
   
   default: DispatchQueue.main.async{completion(true)}// Successful completion here by default!
  }
 }
 
 
 
 
 final func unfolder()
  //Moves <SYNCRONOUSLY> Photo MO into current PhotoSnippet from current folder.
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
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url //Make copy of Photo MO URL before moving...
  
  context.persistAndWait(block: //make changes in context sync
  {
   sourceFolder.removeFromPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    return
   }
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   self.updateSourceFolder(sourceFolder: sourceFolder)
  }
  
  self.photoSnippet?.currentFRC?.activateDelegate()
  
 }
 
 
 

 
 final func unfolder(completion: @escaping (Bool) -> ())
  //Moves <Asyncronously> Photo MO into current PhotoSnippet from current folder.
  //if source folder has 1 Photo after this MOC operation the single Photo is unfoldred into this PhotoSnippet.
  //Empty source folder is to be deleted from current MOC!
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  guard let sourceFolder = self.folder else
  {
   print(#function, terminator: ">>> ")
   print ("<<<PRECONDITION FAILURE>>> PHOTO UNFOLDER ERROR. THIS PHOTO IS NOT FOLDERED YET!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  self.photoSnippet?.currentFRC?.deactivateDelegate()
  
  let fromURL = self.url //Make copy of Photo MO URL before moving...
  
  context.persist(block: //make changes in context async
  {
   sourceFolder.removeFromPhotos(self)
  })
  {flag in
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    DispatchQueue.main.async{completion(false)}
    return
   }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {success in
    guard success else
    {
     DispatchQueue.main.async{completion(false)}
     return
    }
    self.updateSourceFolder(sourceFolder: sourceFolder)
    {success in
     DispatchQueue.main.async
     {
      self.photoSnippet?.currentFRC?.activateDelegate()
      completion(success)
     }
    }
   }
  }
 }
 
 
 
 final func move(to snippet: PhotoSnippet, to folder: PhotoFolder?)
  //Moves <Syncronously> Photo MO from arbitrary PhotoSnippet and folder into snippet and folder.
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   return
  }
 
  let fromURL = self.url //Make copy of Photo MO URL before moving...
  let sourceFolder = self.folder //take reference to source folder before moving...
  
  context.persistAndWait(block: //make changes in context sync
  {
    sourceFolder?.removeFromPhotos(self)
    self.photoSnippet?.removeFromPhotos(self)
    snippet.addToPhotos(self)
    folder?.addToPhotos(self)
  })
  {flag in
   
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    return
   }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   
   if (sourceFolder != nil) //if Photo MO was foldered before moving update source PhotoFolder MO!
   {
    self.updateSourceFolder(sourceFolder: sourceFolder!)
   }
   
  }
 }
 
 
 
 
 
 final func move(to snippet: PhotoSnippet, to folder: PhotoFolder?, completion: @escaping (Bool) -> ())
 //Moves ASYNC Photo MO from arbitrary PhotoSnippet and folder into snippet and folder.
 {
  
  guard let context = self.managedObjectContext else
  {
   print ("<<<MO Processing Critical Error!>>> MO \(self.description) has no associated context!")
   DispatchQueue.main.async{completion(false)}
   return
  }
  
  let fromURL = self.url //Make copy of Photo MO URL before moving...
  let sourceFolder = self.folder //take reference to source folder before moving...
  
  context.persist(block:                  //make changes in context async
  {
    sourceFolder?.removeFromPhotos(self)
    self.photoSnippet?.removeFromPhotos(self)
    snippet.addToPhotos(self)
    folder?.addToPhotos(self)
  })
  {flag in
   
   guard flag else
   {
    print(#function, terminator: ">>> ")
    print("MOC SAVE ERROR OCCURED IN \(self.managedObjectContext?.description ?? "Undefined") MO: \(self.description)")
    DispatchQueue.main.async{completion(false)}
    return
   }
   
   PhotoItem.movePhotoItemOnDisk(from: fromURL, to: self.url)
   {success in
    guard success else
    {
     DispatchQueue.main.async{completion(false)}
     return
    }
    
    if (sourceFolder != nil) //if Photo MO was foldered before moving update source PhotoFolder MO!
    {
     self.updateSourceFolder(sourceFolder: sourceFolder!)
     {success in
      DispatchQueue.main.async{completion(success)}
     }
    }
    else
    {
     DispatchQueue.main.async{completion(success)}
    }
    
   }
  }
 }
 
 
 
 final func merge (in snippet: PhotoSnippet, with photo: Photo)
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
   case let (false, _ ,  destinationFolder?): move     (to: snippet, to: destinationFolder); return
   case let (true,  _?,  destinationFolder?): refolder (to: destinationFolder)             ; return
   case let (true,  nil, destinationFolder?): folder   (to: destinationFolder)             ; return
   default: break //continue merging into new folder....
  }
  
  //otherwise we create new empty folder and move self and destination into it
  let newFolderID = UUID()
  var newFolder: PhotoFolder?
  
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
   
   PhotoFolderItem.createNewPhotoFolderOnDisk(at: newFolder!.url)
   
   switch (snippet === self.photoSnippet, self.folder)
   {
    case (true,  _?)  :  self.refolder (to: newFolder!)
    case (true, nil)  :  self.folder   (to: newFolder!)
    case (false,  _)  :  self.move     (to: snippet, to: newFolder)
   }
   
   
   photo.folder(to: newFolder!)
   
  }
 } //final func merge (sync)
 
} //Photo Managed Object extension...
