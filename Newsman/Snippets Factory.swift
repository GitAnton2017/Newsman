
import Foundation
import UIKit
import CoreData
import CoreLocation

extension SnippetsViewController
{
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
      self.moc.persist{newTextSnippet.snippetLocation = location}
    }
    
    editTextSnippet(snippetToEdit: newTextSnippet)
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
      self.moc.persist{newPhotoSnippet.snippetLocation = location}
    }
    
    editVisualSnippet(snippetToEdit: newPhotoSnippet)
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
      self.moc.persist{newVideoSnippet.snippetLocation = location}
    }
    
    editVisualSnippet(snippetToEdit: newVideoSnippet)
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
