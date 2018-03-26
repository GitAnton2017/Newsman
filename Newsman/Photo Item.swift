import Foundation
import UIKit
import CoreData
import GameplayKit




//MARK: ----------------- Single Photo Item Class ----------------
class PhotoItem: NSObject, PhotoItemProtocol
{
  static let photoItemUTI = "photoitem.newsman"
//------------------------------------------
    var photo: Photo
//------------------------------------------
    
    var url: URL
    {
      let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
        
      if let photoFolderID = photo.folder?.id?.uuidString
      {
        return snippetURL.appendingPathComponent(photoFolderID).appendingPathComponent(id.uuidString)
      }
      else
      {
        return snippetURL.appendingPathComponent(id.uuidString)
      }
        
    }
    
    var id: UUID {return photo.id!}
    
    var isSelected: Bool
    {
      get {return photo.isSelected}
      set {photo.isSelected = newValue}
    }
    
    var priorityFlag: String?
    {
      get {return photo.priorityFlag}
      set {photo.priorityFlag = newValue}
    }
    
    var priority: Int {return PhotoPriorityFlags(rawValue: photo.priorityFlag ?? "")?.rateIndex ?? -1}
    
    var date: Date {return photo.date! as Date}
    
    var position: Int16
    {
        get {return photo.position}
        set {photo.position = newValue}
    }
    
    static let queue =
    { () -> OperationQueue in
     let queue = OperationQueue()
     //queue.maxConcurrentOperationCount = 1
     return queue
    }()
    
    enum PhotoMOKeys: CodingKey
    {
        case photoURL
    }
    
    func encode(to encoder: Encoder) throws
    {
        var cont = encoder.container(keyedBy: PhotoMOKeys.self)
        try cont.encode(url, forKey: .photoURL)
        
    }
    
    
    
    static let dsQueue = DispatchQueue(label: "Images")
    
    static let fsQueue = DispatchQueue(label: "File I/O")
    
    static let dsGroup = DispatchGroup()
    
    typealias ImagesCache = NSCache<NSString, UIImage>
    
    static var imageCacheDict = [Int: ImagesCache]()
    
    var photoSnippet: PhotoSnippet {return photo.photoSnippet!}
    
    init(photo : Photo)
    {
        
        self.photo = photo
        super.init()
    }
    
    @discardableResult class func cacheThumbnailImage(imageID: String, image: UIImage, width: Int) -> UIImage?
    {
        if let resizedImage = image.resized(withPercentage: CGFloat(width)/image.size.width)
        {
            if let cache = PhotoItem.imageCacheDict[width]
            {
             cache.setObject(resizedImage, forKey: imageID as NSString)
             //print ("NEW THUMBNAIL CACHED WITH EXISTING CACHE: \(cache.name). SIZE\(res_img.size)"
            }
            else
            {
             let newImageWidthCache = ImagesCache()
             newImageWidthCache.name = "(\(width) x \(width))"
             /*OperationQueue.main.addOperation
             {
              newImageWidthCache.delegate = PhotoItem.appDelegate
             }*/
        
             newImageWidthCache.setObject(resizedImage, forKey: imageID as NSString)
             PhotoItem.imageCacheDict[width] = newImageWidthCache
             //print ("NEW THUMBNAIL CACHED WITH NEW CREATED CACHE. SIZE\(res_img.size)")
            }
            
            return resizedImage
        }
        else
        {
            print("*****************************")
            print("IMAGE PROCESSING ERROR!!!!!!!")
            print("*****************************")
            return nil
        }
    }
    
    convenience required init(from decoder: Decoder) throws
    {
        let cont = try decoder.container(keyedBy: PhotoMOKeys.self)
        let newPhotoURL = try cont.decode(UUID.self, forKey: .photoURL)
        print (newPhotoURL)
        
        var newPhoto: Photo!
        
        PhotoItem.MOC.performAndWait
        {
            newPhoto = Photo(context: PhotoItem.MOC)
            newPhoto.date = Date() as NSDate
            newPhoto.isSelected = false
            newPhoto.id = UUID()
        }
        
        self.init(photo: newPhoto)
        
        PhotoItem.saveContext()
    }
    
    convenience init(photoSnippet: PhotoSnippet, image: UIImage, cachedImageWidth: CGFloat)
    {
      
      var newPhoto: Photo!
      let newPhotoID = UUID()
        
      PhotoItem.MOC.performAndWait
      {
       newPhoto = Photo(context: PhotoItem.MOC)
       newPhoto.date = Date() as NSDate
       newPhoto.photoSnippet = photoSnippet
       newPhoto.isSelected = false
       newPhoto.id = newPhotoID
       let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
       newPhoto.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
       photoSnippet.addToPhotos(newPhoto)
      }
        
      self.init(photo: newPhoto)
        
        
      PhotoItem.cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))

      //PhotoItem.fsQueue.sync
     // {
         do
         {
          if let data = UIImagePNGRepresentation(image)
          {
           try data.write(to: self.url, options: [.atomic])
           print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY IN SERIAL QUEUE AT PATH:\n\(self.url.path)")
          }
         }
         catch
         {
          print("***************************************************")
          print ("JPEG WRITE ERROR: \(error.localizedDescription)")
          print("**************************************************")
         }
    //  }

      PhotoItem.saveContext()
        
    }
    
    
//----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM SYNCRONOUSLY --------------------------------
//-----------------------------------------------------------------------------------------------------------------
    func getImage(requiredImageWidth: CGFloat) -> UIImage?
//-----------------------------------------------------------------------------------------------------------------
    {
     if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
        let cachedImage = imageCache.object(forKey: id.uuidString as NSString)
     {
        return cachedImage // if there is an of image of required size in exisisting size cache return it...
     }
     else //otherwise we try to make in from exisiting bigger one in corresponding size cache...
     {
      //filtering caches holding the images with sizes bigger than required...
      let caches = PhotoItem.imageCacheDict.filter
      {pair in
       if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: self.id.uuidString as NSString)
       {return true} else {return false}
      }
        
      if let cache = caches.min(by: {$0.key < $1.key})?.value,//getting the minimum size cache bigger than required image size...
         let biggerImage = cache.object(forKey: id.uuidString as NSString),//has this cache hold required image???
        let newCachedImage = PhotoItem.cacheThumbnailImage(imageID: id.uuidString, image: biggerImage, width: Int(requiredImageWidth))
         //if yes try to resize it to required one and if ok with resize we return it...
      {
       return newCachedImage
      }
        
      //otherwise try to load it from disk URL and cache it...
      do
      {
        let data = try Data(contentsOf: url)
        if let savedImage = UIImage(data: data, scale: 1),
            let newCachedImage = PhotoItem.cacheThumbnailImage(imageID: id.uuidString, image: savedImage, width: Int(requiredImageWidth))
        {
         return newCachedImage
        }
        else
        {
         print("**************************************************************************")
         print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL: \n\(url.path)!")
         print("**************************************************************************")
            
         return nil
        }
       }
       catch
       {
         print("******************************************************************************")
         print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
         print("******************************************************************************")
        
         return nil
       } //do-try-catch...
     } //if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)]...
    } //func getImage(...)
//-----------------------------------------------------------------------------------------------------------------
    
    
    class func getCachedImage(with imageID: UUID, requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
    {
        PhotoItem.queue.addOperation
        {
           if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
              let cachedImage = imageCache.object(forKey: imageID.uuidString as NSString)
           {
               //OperationQueue.main.addOperation {completion(cachedImage)}
               completion(cachedImage)
               return
           }
           else
           {
               let caches = PhotoItem.imageCacheDict.filter
               {pair in
                   if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: imageID.uuidString as NSString)
                   {return true} else {return false}
               }
            
               if let cache = caches.min(by: {$0.key < $1.key})?.value,
                   let biggerImage = cache.object(forKey: imageID.uuidString as NSString),
                   let cachedImage = self.cacheThumbnailImage(imageID: imageID.uuidString, image: biggerImage, width: Int(requiredImageWidth))
                
               {
                   //OperationQueue.main.addOperation {completion(cachedImage)}
                   completion(cachedImage)
                   //print("IMAGE RESIZED FROM CACHED IMAGE IN EXISTING CACHE: \(cache.name), SIZE: \(biggerImage.size)")
                   return
               }
           }
            
        // OperationQueue.main.addOperation{completion(nil)}
          completion(nil)
        }
        
    }
    
    class func getSavedImage(with imageID: UUID, from url: URL,
                             requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
    {
      PhotoItem.queue.addOperation //PhotoItem.fsQueue.async
      {
         do
          {
              print("******************************************************************************")
              print ("ATTEMPT OF READING IMAGE FROM URL IN SERIAL QUEUE: \n \(url.path)...")
              print("******************************************************************************")
            
              let data = try Data(contentsOf: url)
            
              //PhotoItem.queue.addOperation
              //{
               if let savedImage = UIImage(data: data),
                  let cachedImage = PhotoItem.cacheThumbnailImage(imageID: imageID.uuidString, image: savedImage, width: Int(requiredImageWidth))
                
               {
                  print("IMAGE DATA SIZE:\(data.count) bytes LOADED FROM DISK! SIZE: \(savedImage.size)")
                  //OperationQueue.main.addOperation {completion(cachedImage)}
                  completion(cachedImage)
               }
               else
               {
                  print("******************************************************************************")
                  print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL!")
                  print("******************************************************************************")
                
                  //OperationQueue.main.addOperation{completion(nil)}
                  completion(nil)
               }
             // }
          }
          catch
          {
              print("******************************************************************************")
              print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
              print("******************************************************************************")
            
              //OperationQueue.main.addOperation{completion(nil)}
               completion(nil)
          } //do-try-catch...
        
      } //PhotoItem.queue.addOperation...
    } //func getImage(...)
    
   
 //----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM ASYNCRONOUSLY -------------------------------
 //-----------------------------------------------------------------------------------------------------------------
 func getImage(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
 //-----------------------------------------------------------------------------------------------------------------
 {
  PhotoItem.dsQueue.async
  {
   let photoID = self.id
   let photoURL = self.url
    
   PhotoItem.getCachedImage(with: photoID , requiredImageWidth: requiredImageWidth)
   {image in
    if let image = image
    {
     OperationQueue.main.addOperation {completion(image)}
    }
    else
    {
     PhotoItem.getSavedImage(with: photoID , from: photoURL, requiredImageWidth: requiredImageWidth)
     {image in
      OperationQueue.main.addOperation {completion(image)}
     }
    }
   }
  }
 }
    
//----------------------------- GETTING REQUIRED IMAGE FOR PHOTO ITEM ASYNCRONOUSLY -------------------------------
//-----------------------------------------------------------------------------------------------------------------
    func getImage1(requiredImageWidth: CGFloat, completion: @escaping (UIImage?) -> Void)
//-----------------------------------------------------------------------------------------------------------------
    {
     PhotoItem.dsQueue.async
     {
        let photoID = self.id.uuidString
        let photoURL = self.url
        
     PhotoItem.queue.addOperation
     {
       if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)],
          let cachedImage = imageCache.object(forKey: photoID as NSString)
       {
        OperationQueue.main.addOperation {completion(cachedImage)}
        //print("IMAGE LOADED FROM EXISTING CACHE: \(imageCache.name), SIZE: \(cachedImage.size)")
        return
       }
       else
       {
        let caches = PhotoItem.imageCacheDict.filter
        {pair in
          if pair.key > Int(requiredImageWidth), let _ = pair.value.object(forKey: photoID as NSString)
          {return true} else {return false}
        }
        
        if let cache = caches.min(by: {$0.key < $1.key})?.value,
           let biggerImage = cache.object(forKey: photoID as NSString),
           let cachedImage = PhotoItem.cacheThumbnailImage(imageID: photoID, image: biggerImage, width: Int(requiredImageWidth))
           
        {
          OperationQueue.main.addOperation
          {
            completion(cachedImage)
          }
          //print("IMAGE RESIZED FROM CACHED IMAGE IN EXISTING CACHE: \(cache.name), SIZE: \(biggerImage.size)")
          return
        }
        //otherwise try to load it from disk URL and cache it...
        
        do
        {
         print("******************************************************************************")
         print ("ATTEMPT OF READING IMAGE FROM URL: \n \(photoURL.path)...")
         print("******************************************************************************")
            
         let data = try Data(contentsOf: photoURL)
         if let savedImage = UIImage(data: data, scale: 1),
            let cachedImage = PhotoItem.cacheThumbnailImage(imageID: photoID, image: savedImage, width: Int(requiredImageWidth))
            
         {
          //print("IMAGE DATA SIZE:\(data.count) bytes LOADED FROM DISK! SIZE: \(savedImage.size)")
          OperationQueue.main.addOperation
          {
            
            completion(cachedImage)
            
          }
         }
         else
         {
          print("******************************************************************************")
          print("ERROR OCCURED WHEN PROCESSING ORIGINAL IMAGE FROM DATA URL!")
          print("******************************************************************************")
            
          OperationQueue.main.addOperation{completion(nil)}
         }
        }
        catch
        {
          print("******************************************************************************")
          print("ERROR OCCURED WHEN READING IMAGE DATA FROM URL!\n\(error.localizedDescription)")
          print("******************************************************************************")
            
          OperationQueue.main.addOperation{completion(nil)}
        } //do-try-catch...
        
       } //main if-else...if let imageCache = PhotoItem.imageCacheDict[Int(requiredImageWidth)]...
      } //PhotoItem.queue.addOperation...
     }
     } //func getImage(...)
//-----------------------------------------------------------------------------------------------------------------
    
    func deleteImages()
    {
        PhotoItem.MOC.performAndWait
        {
             PhotoItem.MOC.delete(photo)
        }
       
        for item in PhotoItem.imageCacheDict
        {
          item.value.removeObject(forKey: id.uuidString as NSString)
        }
    
        do
        {
          try FileManager.default.removeItem(at: url)
            
          print("******************************************************************************")
          print("IMAGE FILE DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
          print("******************************************************************************")
        }
        catch
        {
          print("******************************************************************************")
          print("ERROR DELETING IMAGE FILE AT PATH:\n\(url.path)\n\(error.localizedDescription)")
          print("******************************************************************************")
        }
        
        PhotoItem.saveContext()
    }
    
    @discardableResult
    class func movePhotos (from sourcePhotoSnippet: PhotoSnippet, to destPhotoSnippet: PhotoSnippet) -> [PhotoItem]?
    {
     if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected && $0.folder == nil}), sourceSelectedPhotos.count > 0
     {
    

      let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
      let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
    
      sourceSelectedPhotos.forEach
      {

        let sourcePhotoURL = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
        let destPhotoURL   =   destSnippetURL.appendingPathComponent($0.id!.uuidString)
        
        do
        {
          try FileManager.default.moveItem(at: sourcePhotoURL, to: destPhotoURL)
            
          print("******************************************************************************")
          print("IMAGE FILE MOVED SUCCESSFULLY TO PATH:\n\(destSnippetURL.path)")
          print("******************************************************************************")
        }
        catch
        {
          print("******************************************************************************")
          print("ERROR MOVING IMAGE FILE FROM:\n\(sourcePhotoURL.path) TO \(destSnippetURL.path) \n\(error.localizedDescription)")
          print("******************************************************************************")
        }
      }
      
      sourcePhotoSnippet.removeFromPhotos(NSSet(array: sourceSelectedPhotos))
      destPhotoSnippet.addToPhotos(NSSet(array: sourceSelectedPhotos))
        
      PhotoItem.saveContext()
        
      return sourceSelectedPhotos.map{PhotoItem(photo: $0)}
        
     }
     else
     {
       return nil
     }
    }
    
    @discardableResult
    class func moveFolders (from sourcePhotoSnippet: PhotoSnippet, to destPhotoSnippet: PhotoSnippet) -> [PhotoFolderItem]?
    {
        if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected}),
               sourceSelectedFolders.count > 0
        {
            let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let sourceSnippetURL = docFolder.appendingPathComponent(sourcePhotoSnippet.id!.uuidString)
            let destSnippetURL =   docFolder.appendingPathComponent(destPhotoSnippet.id!.uuidString)
            
            sourceSelectedFolders.forEach
            {
             
             let sourcePhotoFolderURL = sourceSnippetURL.appendingPathComponent($0.id!.uuidString)
             let destPhotoFolderURL   =   destSnippetURL.appendingPathComponent($0.id!.uuidString)
                    
             do
             {
                try FileManager.default.moveItem(at: sourcePhotoFolderURL, to: destPhotoFolderURL)
                
                print("**********************************************************************************")
                print("IMAGE FOLDER MOVED SUCCESSFULLY TO NEW PHOTO SNIPPET PATH:\n\(destSnippetURL.path)")
                print("**********************************************************************************")
                let content = try FileManager.default.contentsOfDirectory(atPath: destPhotoFolderURL.path)
                print ("IMAGE FOLDER FILE COUNT - \(content.count)")
                print ("THE CONTENT OF NEW FOLDER :")
                print("**********************************************************************************")
                print ("\(destPhotoFolderURL.path)")
                content.enumerated().forEach {print ("\($0.offset)) \($0.element)")}
                print("**********************************************************************************")
             }
             catch
             {
                print("**********************************************************************************")
                print("""
                      ERROR MOVING IMAGE FOLDER FROM:\n\(sourcePhotoFolderURL.path) TO \(destSnippetURL.path)
                       \n\(error.localizedDescription)
                      """)
                print("**********************************************************************************")
             }
            }
            
            sourcePhotoSnippet.removeFromFolders(NSSet(array: sourceSelectedFolders))
            sourceSelectedFolders.forEach
            {
             if let folderPhotos = $0.photos?.allObjects as? [Photo]
             {
              sourcePhotoSnippet.removeFromPhotos(NSSet(array: folderPhotos))
              destPhotoSnippet.addToPhotos(NSSet(array: folderPhotos))
             }
            }
            
            destPhotoSnippet.addToFolders(NSSet(array: sourceSelectedFolders))
            
            PhotoItem.saveContext()
            
            return sourceSelectedFolders.map{PhotoFolderItem(folder: $0)}
            
        }
        else
        {
            return nil
        }
    }
    
    class func deselectSelectedItems (at sourcePhotoSnippet: PhotoSnippet)
    {
     if let sourceSelectedPhotos = (sourcePhotoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected})
     {
      sourceSelectedPhotos.forEach {$0.isSelected = false}
     }
        
     if let sourceSelectedFolders = (sourcePhotoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({$0.isSelected})
     {
      sourceSelectedFolders.forEach {$0.isSelected = false}
     }
    }
    
    class func getAllImages(for photoSnippet: PhotoSnippet, requiredImageWidth: CGFloat,
                            completion: @escaping ([UIImage]?) -> Void)
    {
      let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
      if let photoItems = (photoSnippet.photos?.sortedArray(using: [sort]) as? [Photo])?.map({PhotoItem(photo: $0)}),
           photoItems.count > 1
            
      {
        
         var imageSet = [UIImage]()
        
         photoItems.forEach
         {photoItem in
          PhotoItem.dsQueue.async(group: PhotoItem.dsGroup)
          {
           PhotoItem.dsGroup.enter()
           photoItem.getImage(requiredImageWidth: requiredImageWidth)
           {(image) in
             if let img = image {imageSet.append(img)}
             PhotoItem.dsGroup.leave()
           }
          }
         }
        
         PhotoItem.dsGroup.notify(queue: DispatchQueue.main)
         {
          print("PHOTO SNIPPET IMAGE SET LOADED: \"\(photoSnippet.tag ?? "no name")\",  COUNT - \(imageSet.count)")
          DispatchQueue.main.async{completion(imageSet)}
            
         }
      }
      else
      {
        DispatchQueue.main.async{completion(nil)}
      }
    }
    
    class func getRandomImages(for photoSnippet: PhotoSnippet, number: Int, requiredImageWidth: CGFloat,
                               completion: @escaping ([UIImage]?) -> Void)
    {
        let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
        guard let photos = photoSnippet.photos?.sortedArray(using: [sort]) as? [Photo], photos.count > 1 else
        {
         DispatchQueue.main.async{completion(nil)}
         return
        }
        
        var photoItems: [PhotoItem]
        if (number >= photos.count)
        {
         photoItems = photos.map({PhotoItem(photo: $0)})
        }
        else
        {
         var indexSet = Set<Int>()
         let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: photos.count - 1)
        
         while (indexSet.count < number)
         {
            indexSet.insert(arc4rnd.nextInt())
         }
         
         photoItems = photos.enumerated().filter{indexSet.contains($0.offset)}.map{PhotoItem(photo: $0.element)}
        }
        
        
        var imageSet = [UIImage]()
            
            photoItems.forEach
                {photoItem in
                   // PhotoItem.dsQueue.async(group: PhotoItem.dsGroup)
                  // PhotoItem.MOC.performAndWait
                  // {
                        PhotoItem.dsGroup.enter()
                        photoItem.getImage(requiredImageWidth: requiredImageWidth)
                        {(image) in
                            if let img = image {imageSet.append(img)}
                            PhotoItem.dsGroup.leave()
                        }
                   //}
            }
            
            PhotoItem.dsGroup.notify(queue: DispatchQueue.main)
            {
                print("PHOTO SNIPPET IMAGE SET LOADED: \"\(photoSnippet.tag ?? "no name")\",  COUNT - \(imageSet.count)")
                DispatchQueue.main.async{completion(imageSet)}
                
            }
        
        
    }
    
    
    static let MOC2 =
    { () -> NSManagedObjectContext in
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = PhotoItem.MOC
        //privateMOC.persistentStoreCoordinator = PhotoItem.MOC.persistentStoreCoordinator
        return privateMOC
    }()
    
    class func getRandomImages2(for photoSnippet: PhotoSnippet, number: Int, requiredImageWidth: CGFloat,
                               completion: @escaping ([UIImage]?) -> Void)
    {
      appDelegate.persistentContainer.performBackgroundTask
      {context in
        
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
        let pred = NSPredicate(format: "%K = %@", #keyPath(Photo.photoSnippet), photoSnippet)
        request.predicate = pred
        request.sortDescriptors = [sort]
        
        do
        {
          let photos = try context.fetch(request)
        
          guard photos.count > 1 else
          {
            DispatchQueue.main.async{completion(nil)}
            return
          }
            
          var photoItems: [(photoID: UUID, photoURL: URL)]
          if (number >= photos.count)
          {
            photoItems = photos.map{($0.id!, PhotoItem(photo: $0).url)}
          }
          else
          {
             var indexSet = Set<Int>()
             let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: photos.count - 1)
             while (indexSet.count < number) {indexSet.insert(arc4rnd.nextInt())}
             photoItems = photos.enumerated().filter{indexSet.contains($0.offset)}.map{($0.element.id!, PhotoItem(photo: $0.element).url)}
          }
         
         
          var imageSet = [UIImage]()
    
          photoItems.forEach
          {photoItem in
            PhotoItem.dsGroup.enter()
            PhotoItem.getCachedImage(with: photoItem.photoID, requiredImageWidth: requiredImageWidth)
            {(image) in
              if let img = image
              {
                imageSet.append(img)
                PhotoItem.dsGroup.leave()
              }
              else
              {
               PhotoItem.getSavedImage(with: photoItem.photoID, from: photoItem.photoURL, requiredImageWidth: requiredImageWidth)
               {(image) in
                if let img = image {imageSet.append(img)}
                PhotoItem.dsGroup.leave()
               }
              }
            }
          }
         
          PhotoItem.dsGroup.notify(queue: DispatchQueue.main)
          {
             print("PHOTO SNIPPET IMAGE SET LOADED: \"\(photoSnippet.tag ?? "")\",  COUNT - \(imageSet.count)" )
             DispatchQueue.main.async{completion(imageSet)}
            
          }
          
        }
        catch
        {
            let e = error as NSError
            print ("Unresolved error \(e) \(e.userInfo)")
            DispatchQueue.main.async{completion(nil)}
         
        }
        
        
    }
   }
    
    class func getRandomImages3(for photoSnippet: PhotoSnippet, number: Int, requiredImageWidth: CGFloat,
                                completion: @escaping ([UIImage]?) -> Void)
    {
        appDelegate.persistentContainer.performBackgroundTask
            {context in
                
                let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
                let pred = NSPredicate(format: "%K = %@", #keyPath(Photo.photoSnippet), photoSnippet)
                request.predicate = pred
                request.sortDescriptors = [sort]
                request.returnsObjectsAsFaults = false
                
                do
                {
                    let photos = try context.fetch(request)
                    //let _ = try context.fetch(request1)
                    //let _ = try context.fetch(request2)
                    
                    guard photos.count > 1 else
                    {
                        DispatchQueue.main.async{completion(nil)}
                        return
                    }
                    
                    var photoItems: [PhotoItem]
                    if (number >= photos.count)
                    {
                        photoItems = photos.map{PhotoItem(photo: $0)}
                    }
                    else
                    {
                        var indexSet = Set<Int>()
                        let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: photos.count - 1)
                        while (indexSet.count < number) {indexSet.insert(arc4rnd.nextInt())}
                        photoItems = photos.enumerated().filter{indexSet.contains($0.offset)}.map{PhotoItem(photo: $0.element)}
                    }
                    
                    
                    var imageSet = [UIImage]()
                    
                    
                    photoItems.forEach
                        {photoItem in
                            PhotoItem.dsGroup.enter()
                            photoItem.getImage(requiredImageWidth: requiredImageWidth)
                            {(image) in
                                _ = context
                                if let img = image
                                {
                                    imageSet.append(img)
                                    
                                }
                               PhotoItem.dsGroup.leave()
                            }
                    }
                    
                    PhotoItem.dsGroup.notify(queue: DispatchQueue.main)
                    {
                        print("PHOTO SNIPPET IMAGE SET LOADED: \"\(photoSnippet.tag ?? "")\",  COUNT - \(imageSet.count)" )
                        DispatchQueue.main.async{completion(imageSet)}
                        
                    }
                    
                }
                catch
                {
                    let e = error as NSError
                    print ("Unresolved error \(e) \(e.userInfo)")
                    DispatchQueue.main.async{completion(nil)}
                    
                }
                
                
        }
    }
}

//MARK: -
