
import Foundation
import UIKit
import CoreData



//MARK: ----------------- Photo Folder Item Class ----------------
 class PhotoFolderItem: NSObject, PhotoItemProtocol
//-------------------------------------------------------------
{
  
    weak var dragSession: UIDragSession?
  
    static let folderItemUTI = "folderitem.newsman"
    
    let PDFContextSize = CGSize(width: 300, height: 500)
    
//-----------------------------------------
    var folder: PhotoFolder
//-----------------------------------------
    
    var singlePhotoItems: [PhotoItem]?
    {
        return (folder.photos?.allObjects as? [Photo])?.map{PhotoItem(photo: $0)}
    }
    
    var url: URL
    {
        let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let snippetURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
        return snippetURL.appendingPathComponent(id.uuidString)
    }
    
    var id: UUID {return folder.id!}
  
  
    func deleteFolder ()
    {
     PhotoItem.deletePhotoItemFromDisk(at: url)
     PhotoItem.MOC.persistAndWait {[weak self] in PhotoItem.MOC.delete(self!.folder)}
    }
  
    func deleteImages()
    {
     PhotoSnippetViewController.removeDraggedItem(PhotoItemToRemove: self)
     (folder.photos?.allObjects as? [Photo])?.forEach
     {photo in
      PhotoItem.imageCacheDict.forEach{$0.value.removeObject(forKey: photo.id!.uuidString as NSString)}
     }
     
     deleteFolder ()
 
    }
    
    var priorityFlag: String?
    {
        get {return folder.priorityFlag}
        set {folder.priorityFlag = newValue}
    }
    
    var priority: Int {return PhotoPriorityFlags(rawValue: folder.priorityFlag ?? "")?.rateIndex ?? -1}
    
    var date: Date {return folder.date! as Date}
    
    var position: Int16
    {
        get {return folder.position}
        set {folder.position = newValue}
    }
    
    var isSelected: Bool
    {
        get {return folder.isSelected}
        set
        {
         folder.isSelected = newValue
         folder.photos?.forEach {($0 as! Photo).isSelected = newValue}
        }
    }
    
    var photoSnippet: PhotoSnippet {return folder.photoSnippet!}
  
    enum FolderMOKeys: CodingKey
    {
       case folderURL
    }
    
    func encode(to encoder: Encoder) throws
    {
        var cont = encoder.container(keyedBy: FolderMOKeys.self)
        try cont.encode(url, forKey: .folderURL)
        
    }
    
    required convenience init(from decoder: Decoder) throws
    {
        var newFolder: PhotoFolder!
        
        let cont = try decoder.container(keyedBy: FolderMOKeys.self)
        let newFolderURL = try cont.decode(UUID.self, forKey: .folderURL)
        print (newFolderURL)
        

        PhotoFolderItem.MOC.performAndWait
        {
        
          newFolder = PhotoFolder(context: PhotoFolderItem.MOC)
          newFolder.id = UUID()
          newFolder.date = Date() as NSDate
          newFolder.isSelected = false
                
        }
        
        self.init(folder: newFolder)
        
        
    }
    
    init (folder: PhotoFolder)
    {
        
        self.folder = folder
        super.init()
    }
  
    class func createNewPhotoFolderOnDisk(at url: URL)
    {
     do
     {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
      print ("PHOTO SNIPPET NEW FOLDER SUCCESSFULLY CREATED AT PATH:\n \(url.path)")
     }
     catch
     {
      print("ERROR! CREATING FOLDER DIRECTORY AT PATH: \(url.path):\n \(error.localizedDescription)")
     }
    }
 
    convenience init?(photoSnippet: PhotoSnippet)
    {
      if let selectedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected})
      {
       var newFolder: PhotoFolder!
       let newFolderID = UUID()
       
       PhotoFolderItem.MOC.persistAndWait
       {
         newFolder = PhotoFolder(context: PhotoFolderItem.MOC)
         newFolder.id = newFolderID
         newFolder.photoSnippet = photoSnippet
         newFolder.date = Date() as NSDate
         newFolder.isSelected = false
        
         let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
         newFolder.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
       
         let sourceSnippetURL = PhotoItem.docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
         let destFolderURL    = sourceSnippetURL.appendingPathComponent(newFolderID.uuidString)
       
         PhotoFolderItem.createNewPhotoFolderOnDisk(at: destFolderURL)
         let type = SnippetType(rawValue: photoSnippet.type!)!
        
         selectedPhotos.forEach
         {photo in
          photo.isSelected = false
          var sourcePhotoURL: URL
          let fileName = photo.id!.uuidString + (type == .video ? PhotoItem.videoFormatFile : "")
          if let folder = photo.folder
          {
           sourcePhotoURL = sourceSnippetURL.appendingPathComponent(folder.id!.uuidString).appendingPathComponent(fileName)
          }
          else
          {
           sourcePhotoURL = sourceSnippetURL.appendingPathComponent(fileName)
          }
          
          let destPhotoURL  = destFolderURL.appendingPathComponent(fileName)
          PhotoItem.movePhotoItemOnDisk(from: sourcePhotoURL, to: destPhotoURL)
         }
        
         newFolder.addToPhotos(NSSet(array: selectedPhotos))
       }
       
       self.init(folder: newFolder)
      }
      else
      {
       return nil
      }
    }
    
    class func removeEmptyFolders(from photoSnippet: PhotoSnippet)
    {
      let emptyFolders = (photoSnippet.folders?.allObjects as? [PhotoFolder])?.filter{($0.photos?.count ?? 0) == 0}
      print ("DELETING \(emptyFolders!.count) EMPTY FOLDERS FROM PHOTO SNIPPET ID: \(photoSnippet.id!)")
      PhotoItem.MOC.persistAndWait
      {
       emptyFolders?.forEach
       {folder in
        print ("DELETING EMPTY FOLDER WITH ID: \(folder.id!)")
       
        let emptyFolderURL = PhotoItem.docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
                                                .appendingPathComponent(      folder.id!.uuidString)
       
        PhotoItem.deletePhotoItemFromDisk(at: emptyFolderURL)
        PhotoItem.MOC.delete(folder)
       }
      }
    }
    
}
//MARK: -


