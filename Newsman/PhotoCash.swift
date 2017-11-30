
import Foundation
import UIKit
import CoreData

class PhotoPair: NSObject
{
  var photo: Photo
  var image: UIImage
  init(photo: Photo, image: UIImage)
  {
    self.photo = photo
    self.image = image
    super.init()
  }
}
class PhotoCash
{
  let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

  lazy var moc: NSManagedObjectContext =
  {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  }()
   
  var snippetsVC: SnippetsViewController!
    
  let cache = NSCache<PhotoSnippet, NSMutableArray>()

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
        
      if let photosArray = cache.object(forKey: photoSnippet)
      {
        let newPhotoPair = PhotoPair(photo: newPhoto, image: image)
        photosArray.add(newPhotoPair)
      }
      else
      {
       let photosArray = NSMutableArray()
       let newPhotoPair = PhotoPair(photo: newPhoto, image: image)
       photosArray.add(newPhotoPair)
       cache.setObject(photosArray, forKey: photoSnippet)
      }
        
      (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func getPhotos(photoSnippet: PhotoSnippet) -> [PhotoPair]
    {
      var oldPhotos = [PhotoPair]()
      if let photos = photoSnippet.photos
      {
       if let photosArray = cache.object(forKey: photoSnippet)
       {
        return photosArray as! [PhotoPair]
       }
       else
       {
         let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
         let photosArray = NSMutableArray()
         let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
         for photo in photos.sortedArray(using: [sort])
         {
          let photoID = (photo as! Photo).id!
          let photoURL = snippetURL.appendingPathComponent(photoID.uuidString)
          if let image = UIImage(contentsOfFile: photoURL.path)
          {
           let newPhotoPair = PhotoPair(photo: photo as! Photo, image: image)
           oldPhotos.append(newPhotoPair)
           photosArray.add (newPhotoPair)
          }
         }
         cache.setObject(photosArray, forKey: photoSnippet)
       }
      }
      return oldPhotos
    }
    
    func deletePhoto (photoSnippet: PhotoSnippet, photo: PhotoPair)
    {
     
     if let photosArray = cache.object(forKey: photoSnippet)
     {
       photosArray.remove(photo)
     }
        
     moc.delete(photo.photo)
     let photoID = photo.photo.id!
     let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
     let photoURL = snippetURL.appendingPathComponent(photoID.uuidString)
     try? FileManager.default.removeItem(at: photoURL)
     (UIApplication.shared.delegate as! AppDelegate).saveContext()

    }
}
