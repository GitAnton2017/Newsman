
import Foundation
import UIKit
import CoreData
import CoreLocation
import RxSwift


extension SnippetsViewController
{
 func snippetCreator<S>(with _ : S.Type, _ T: BaseSnippet.Type, snippetType: SnippetType) -> Single<BaseSnippet>
  where S: SnippetsRepresentable
 {
  $currentLocation.flatMap {snippetLocation -> Single<BaseSnippet> in
    Single<BaseSnippet>.create
    {promise in
     var newSnippet: BaseSnippet!
     self.moc.persist({
      newSnippet = T.init(context: self.moc)
      let newSnippetID = UUID()
      newSnippet.id = newSnippetID
      newSnippet.snippetType = snippetType
      newSnippet.snippetStatus = .new
     
      newSnippet.currentFRC = self.snippetsDataSource.currentFRC
     
      newSnippet.snippetDate = Date()
      newSnippet.snippetName = ""
      newSnippet.snippetPriority = .normal
      newSnippet.snippetCoordinates = self.currentLocation
      newSnippet.snippetLocation = snippetLocation
     
      newSnippet.initStorage()
     })
     {
       switch $0
       {
        case  .success():          promise (.success(newSnippet))
        case  .failure(let error): promise (.error(error))
       }
     }
     
     return Disposables.create()
    }.do(onSuccess: { self.editSnippet(with: S.self, snippetToEdit: $0) })
  }
  
  
 }
}



extension SnippetsViewController
{
 func createSnippet<S> (with _ : S.Type, _ T: BaseSnippet.Type, snippetType: SnippetType)
 where S: SnippetsRepresentable
 {
  var newSnippet: BaseSnippet!
  var disposable: Disposable?
  
  moc.performChanges(block:
  {
   newSnippet = T.init(context: self.moc)
   let newSnippetID = UUID()
   newSnippet.id = newSnippetID
   newSnippet.recordName = newSnippetID.uuidString
   newSnippet.snippetType = snippetType
   newSnippet.snippetStatus = .new
  
   newSnippet.currentFRC = self.snippetsDataSource.currentFRC
  
   newSnippet.snippetDate = Date()
   newSnippet.snippetName = ""
   newSnippet.snippetPriority = .normal
   newSnippet.snippetCoordinates = self.snippetLocation
   newSnippet.snippetLocation = ""
  
   newSnippet.initStorage()
   
//    getLocationString
//    {location in
//      print ("GEOCODER LOCATION STRING \"\(location ?? "Unknown")\" READY FOR \(snippetType)")
//      self.moc.persist{newSnippet.snippetLocation = location} as Void
//    }
   
   disposable = self.$currentLocation.subscribe(onSuccess:
   {location in
    defer { disposable?.dispose() }
    print ("GEOCODER LOCATION STRING \"\(location ?? "Unknown")\" READY FOR \(snippetType)")
    self.moc.perform { newSnippet.snippetLocation = location }
   },
   onError:{_ in disposable?.dispose()})
    
   
  })
  {result in
   guard case .success() = result  else { return }
   self.editSnippet(with: S.self, snippetToEdit: newSnippet)
  }
  
  
 }
 
 func createNewTextSnippet()
 {
  moc.persistAndWait
  {
    let newTextSnippet = TextSnippet(context: moc)
    newTextSnippet.snippetDate = Date()
    newTextSnippet.text = "Enter Text Snippet Text here..."
    newTextSnippet.id = UUID()
    newTextSnippet.snippetPriority = .normal //new snipper priority is .normal by default
    newTextSnippet.snippetType = .text
    newTextSnippet.snippetStatus = .new
    newTextSnippet.snippetCoordinates = snippetLocation
    
    getLocationString
    {location in
      print ("GEOCODER LOCATION STRING \"\(location ?? "Unknown")\" READY FOR NEW TEXT SNIPPET")
      self.moc.persist{newTextSnippet.snippetLocation = location} as Void
    }
    
    editSnippet(with: TextSnippetViewController.self, snippetToEdit: newTextSnippet)
  }
  
 }
 
 func createNewPhotoSnippet()
 {
   moc.persistAndWait
   {
    let newPhotoSnippet = PhotoSnippet(context: moc)
    newPhotoSnippet.snippetDate = Date()
    let newPhotoSnippetID = UUID()
    newPhotoSnippet.id = newPhotoSnippetID
    newPhotoSnippet.snippetPriority = .normal
    newPhotoSnippet.snippetType = .photo
    newPhotoSnippet.snippetStatus = .new
    newPhotoSnippet.snippetCoordinates = snippetLocation
    
    let fileManager = FileManager.default
    let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let newPhotoSnippetURL = docFolder.appendingPathComponent(newPhotoSnippetID.uuidString)
    do
    {
     try fileManager.createDirectory(at: newPhotoSnippetURL, withIntermediateDirectories: false, attributes: nil)
     print ("PHOTO SNIPPET PHOTOS DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newPhotoSnippetURL.path)")
    }
    catch
    {
     print ("ERROR OCCURED WHEN CREATING PHOTO SNIPPET PHOTOS DIRECTORY: \(error.localizedDescription)")
    }
   
    getLocationString
    {location in
      print ("GEOCODER LOCATION STRING \"\(location ?? "Unknown")\" READY FOR PHOTO SNIPPET")
      self.moc.persist{newPhotoSnippet.snippetLocation = location} as Void
    }
    
    editSnippet(with: PhotoSnippetViewController.self, snippetToEdit: newPhotoSnippet)
  }
  
 }
 
 func createNewVideoSnippet()
 {
   moc.persistAndWait
   {
    
    let newVideoSnippet = PhotoSnippet(context: moc)
    newVideoSnippet.snippetDate = Date()
    let newVideoSnippetID = UUID()
    newVideoSnippet.id = newVideoSnippetID
    newVideoSnippet.snippetPriority = .normal
    newVideoSnippet.snippetType = .video
    newVideoSnippet.snippetStatus = .new
    newVideoSnippet.snippetCoordinates = snippetLocation
    
    
    let fileManager = FileManager.default
    let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let newVideoSnippetURL = docFolder.appendingPathComponent(newVideoSnippetID.uuidString)
    
    do
    {
     try fileManager.createDirectory(at: newVideoSnippetURL, withIntermediateDirectories: false, attributes: nil)
     print ("VIDEO SNIPPET VIDEO FILES DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newVideoSnippetURL.path)")
    }
    catch
    {
     print ("ERROR OCCURED WHEN CREATING VIDEO SNIPPET VIDEO FILES DIRECTORY: \(error.localizedDescription)")
    }
    
    getLocationString
     {location in
      print ("GEOCODER LOCATION STRING \"\(location ?? "Unknown")\" READY FOR VIDEO SNIPPET")
      self.moc.persist{ newVideoSnippet.snippetLocation = location } as Void
    }
    
    editSnippet(with: PhotoSnippetViewController.self, snippetToEdit: newVideoSnippet)
  }
 }
 
 
 
 
 func createNewAudioSnippet()
 {
  
 }
 
 func createNewSketchSnippet()
 {
  
 }
 
 func createNewReport()
 {
  
 }
 
 
}
