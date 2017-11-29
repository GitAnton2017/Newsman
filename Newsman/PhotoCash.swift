
import Foundation
import UIKit
import CoreData
 
class PhotoCash
{
  let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

  lazy var moc: NSManagedObjectContext =
  {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  }()
   
  var snippetsVC: SnippetsViewController!
    
  let cache = NSCache<PhotoSnippet, NSMutableDictionary>()

    func addPhoto (photoSnippet: PhotoSnippet, image: UIImage)
    {
      let newPhoto = Photo(context: moc)
      let newPhotoID = UUID()
      newPhoto.date = Date() as NSDate
      newPhoto.photoSnippet = photoSnippet
      newPhoto.id = newPhotoID
        
      if let location = snippetsVC.snippetLocation
      {
        newPhoto.longitude = location.coordinate.longitude
        newPhoto.latitude  = location.coordinate.latitude
      }
        
      snippetsVC.getLocationString {location in newPhoto.location = location}
        
      photoSnippet.addToPhotos(newPhoto)
    
      let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
      let photoURL = snippetURL.appendingPathComponent(newPhotoID.uuidString)
        
      if let photoData = UIImageJPEGRepresentation(image, 1)
      {
        try? photoData.write(to: photoURL as URL, options: [.atomic])
      }
        
      if let photosMap = cache.object(forKey: photoSnippet)
      {
        photosMap.setObject(image, forKey: newPhotoID as NSUUID)
      }
      else
      {
       let photosMap = NSMutableDictionary()
       photosMap.setObject(image, forKey: newPhotoID as NSUUID)
       cache.setObject(photosMap, forKey: photoSnippet)
      }
    }
    
    func getPhotos(photoSnippet: PhotoSnippet) -> [UIImage]
    {
      var oldPhotos = [UIImage]()
      if let photos = photoSnippet.photos
      {
       if let photosMap = cache.object(forKey: photoSnippet)
       {
        return photosMap.allValues as! [UIImage]
       }
       else
       {
         let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
         let photosMap = NSMutableDictionary()
         let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
         for photo in photos.sortedArray(using: [sort])
         {
          let photoID = (photo as! Photo).id!
          let photoURL = snippetURL.appendingPathComponent(photoID.uuidString)
          if let image = UIImage(contentsOfFile: photoURL.path)
          {
           oldPhotos.append(image)
           photosMap.setObject(image, forKey: photoID as NSUUID)
          }
         }
         cache.setObject(photosMap, forKey: photoSnippet)
       }
      }
      return oldPhotos
    }
    
    func deletePhoto (photoSnippet: PhotoSnippet, photo: Photo)
    {
        
    }
}
