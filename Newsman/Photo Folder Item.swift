
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
    
    func deleteImages()
    {
        if let photos = folder.photos
        {
            //remove images from all size caches...
            
            for photo in photos
            {
                let photoID = (photo as! Photo).id!.uuidString
                for item in PhotoItem.imageCacheDict
                {
                    item.value.removeObject(forKey: photoID as NSString)
                }
            }
            
            //delete folder with photos as directory on disk...
            do
            {
                try FileManager.default.removeItem(at: url)
                
                print("*****************************************************************")
                print("IMAGE FOLDER DIRECTORY DELETED SUCCESSFULLY AT PATH:\n\(url.path)")
                print("*****************************************************************")
            }
            catch
            {
                print("******************************************************************************************")
                print("ERROR DELETING IMAGE FOLDER DIRECTORY AT PATH:\n\(url.path)\n\(error.localizedDescription)")
                print("******************************************************************************************")
            }
            
            //delete cascade the folder and photos from context and save...
            PhotoFolderItem.MOC.delete(folder)
            PhotoFolderItem.saveContext()
            
        }
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
            
            if newValue == false,
                let session = PhotoFolderItem.appDelegate.currentDragSession,
                (session.items.map{$0.localObject as! PhotoItemProtocol}.contains(where: {[weak self] in $0.id == self?.id}))
            {
                return
            }
            
            folder.isSelected = newValue
            folder.photos?.forEach {($0 as! Photo).isSelected = newValue}
        }
    }
    
    var photoSnippet: PhotoSnippet
    {
        return folder.photoSnippet!
        
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
    
    convenience init?(photoSnippet: PhotoSnippet)
    {
        if let selectedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.isSelected})
        {
            
            var newFolder: PhotoFolder!
            PhotoFolderItem.MOC.performAndWait
            {
                    newFolder = PhotoFolder(context: PhotoFolderItem.MOC)
                    newFolder.id = UUID()
                    newFolder.photoSnippet = photoSnippet
                    newFolder.date = Date() as NSDate
                    newFolder.isSelected = false
                    let unfolderedPhotos = (photoSnippet.photos?.allObjects as? [Photo])?.filter({$0.folder == nil})
                    newFolder.position = Int16(unfolderedPhotos?.count ?? 0) + Int16(photoSnippet.folders?.count ?? 0)
                    
            }
            self.init(folder: newFolder)
            
            do
            {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                
                print("******************************************************************************************")
                print ("PHOTO SNIPPET NEW PHOTO FOLDER DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\n \(url.path)")
                print("******************************************************************************************")
                
                try selectedPhotos.map{PhotoItem(photo: $0)}.forEach
                {
                    $0.isSelected = false
                    let newPhotoFolderURL = url.appendingPathComponent($0.id.uuidString)
                    try FileManager.default.moveItem(at: $0.url, to: newPhotoFolderURL)
                    
                    print("******************************************************************************************")
                    print("IMAGE FILE MOVED SUCCESSFULLY TO NEW PHOTO FOLDER AT PATH:\n\(newPhotoFolderURL.path)")
                    print("******************************************************************************************")
                }
            }
            catch
            {
                print("******************************************************************************************")
                print("ERROR MOVING IMAGES TO NEW FOLDER:\n \(error.localizedDescription)")
                print("******************************************************************************************")
            }
            
            PhotoFolderItem.MOC.performAndWait
            {
                    newFolder.addToPhotos(NSSet(array: selectedPhotos))
            }
            
            PhotoFolderItem.saveContext()
            
        }
        else
        {
            return nil
        }
        
    }
    
    class func removeEmptyFolders(from photoSnippet: PhotoSnippet)
    {
        if let emptyFolders = (photoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({($0.photos?.count ?? 0) == 0})
        {
            emptyFolders.map{PhotoFolderItem(folder: $0)}.forEach{$0.deleteImages()}
        }
        
        PhotoFolderItem.saveContext()
    }
    
}
//MARK: -


