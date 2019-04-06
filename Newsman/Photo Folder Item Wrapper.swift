
import Foundation
import UIKit
import CoreData



//MARK: ----------------- Photo Folder Item Class ----------------
 class PhotoFolderItem: NSObject, PhotoItemProtocol
//-------------------------------------------------------------
 {
  
    weak var zoomView: ZoomView?
 
    func cancelImageOperations(){}
  
    var dragAnimationCancelWorkItem: DispatchWorkItem?
    // the strong ref to work item responsible for cancellation of self draggable visual state.
  
    weak var hostingCollectionViewCell: PhotoSnippetCellProtocol?
    //the CV folder cell that is currently displaying this PhotoFolderItem photos or video previews
  
    let  group = DispatchGroup()
  
    weak var dragSession: UIDragSession?
  
    static let folderItemUTI = "folderitem.newsman"
    
    let PDFContextSize = CGSize(width: 300, height: 500)
  
    var folder: PhotoFolder

    var hostedManagedObject: NSManagedObject {return folder}
    //getter for using in Draggable protocol to get wrapped MO
  
    var singlePhotoItems: [PhotoItem]
    {
     return self.folder.folderedPhotos.map{PhotoItem(photo: $0)}
    }
  
    var count: Int  {return self.folder.count}
  
    var isEmpty: Bool {return self.folder.isEmpty}
    
    var url: URL {return self.folder.url}
    
    var id: UUID {return self.folder.id!}
  
    var photoSnippet: PhotoSnippet {return folder.photoSnippet!}
  
    func deleteFolder ()
    {
     PhotoItem.deletePhotoItemFromDisk(at: url)
     PhotoItem.MOC.delete(self.folder)
    }
  
    func deleteImages()
    {
     self.removeFromDrags() //remove folder from drags
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
    
    var priority: Int {return self.folder.priorityIndex}
    
    var date: Date {return self.folder.date! as Date}
    
    var position: Int16
    {
     get {return self.folder.position}
     set {self.folder.position = newValue}
    }
  
    
  
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
  
  
    class func createNewPhotoFolderOnDisk(at url: URL, with completion: @escaping (Bool) -> ())
    {
     DispatchQueue.global(qos: .userInitiated).async
     {
      do
      {
       try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
       print ("PHOTO SNIPPET NEW FOLDER SUCCESSFULLY CREATED AT PATH:\n \(url.path)")
       completion(true)
      }
      catch
      {
       print("ERROR! CREATING FOLDER DIRECTORY AT PATH: \(url.path):\n \(error.localizedDescription)")
       completion(false)
      }
     }
    }
 
    convenience init?(photoSnippet: PhotoSnippet)
    {
       let selected = photoSnippet.selectedPhotos
      //make copy of selected Photos array to prevent deselection side effect in selected.forEach afterwards...
     
       if selected.isEmpty {return nil}
     
       var newFolder: PhotoFolder!
       let newFolderID = UUID()
       
       PhotoFolderItem.MOC.persistAndWait
       {
         newFolder = PhotoFolder(context: PhotoFolderItem.MOC)
         newFolder.id = newFolderID
         newFolder.photoSnippet = photoSnippet
         newFolder.date = Date() as NSDate
         newFolder.isSelected = false
        
         newFolder.position = Int16(photoSnippet.unfolderedPhotos.count) + Int16(photoSnippet.allFolders.count)
       
         let sourceSnippetURL = PhotoItem.docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
         let destFolderURL    = sourceSnippetURL.appendingPathComponent(newFolderID.uuidString)
       
         PhotoFolderItem.createNewPhotoFolderOnDisk(at: destFolderURL)
         let type = SnippetType(rawValue: photoSnippet.type!)!
        
         selected.forEach
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
        
         newFolder.addToPhotos(NSSet(array: selected))
       }
       
       self.init(folder: newFolder)
     
    }
    
    class func removeEmptyFolders(from photoSnippet: PhotoSnippet)
    {
     let empty = photoSnippet.emptyFolders
    
     if empty.isEmpty {return}
   
     empty.forEach
     {folder in
      print ("DELETING EMPTY FOLDER WITH ID: \(folder.id!)")
     
      let emptyFolderURL = PhotoItem.docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
                                              .appendingPathComponent(      folder.id!.uuidString)
     
      PhotoItem.deletePhotoItemFromDisk(at: emptyFolderURL)
      PhotoItem.MOC.delete(folder)
     }
     
    }
    
}
//MARK: -


