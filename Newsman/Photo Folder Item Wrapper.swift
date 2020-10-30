
import Foundation
import UIKit
import CoreData
import protocol RxSwift.Disposable
import Combine


//MARK: ----------------- Photo Folder Item Class ----------------


final class PhotoFolderItem: NSObject, PhotoItemProtocol
{
 
 
  deinit {
//   print ("Photo FOLDER \(String(describing: id)) destroyed ", #function)
  cancellAllStateSubscriptions()
 }
 
 @Published final var hostingCollectionViewCell: PhotoSnippetCellProtocol?
 
 final var hostingCollectionViewCellPublisher: AnyPublisher<PhotoSnippetCellProtocol?, Never>
 {
  $hostingCollectionViewCell.eraseToAnyPublisher()
 }
 
 //the CV folder cell that is currently displaying this PhotoFolderItem photos or video previews
 
 final var cellImageUpdateSubscription            : AnyCancellable? 
 final var cellRowPositionChangeSubscription      : AnyCancellable?
 final var cellPriorityFlagChangeSubscription     : AnyCancellable?
 
 final var cellDragProceedSubscription            : AnyCancellable?
 final var cellDragLocationSubscription           : AnyCancellable?
 final var cellDropProceedSubscription            : AnyCancellable?

 var isArrowMenuShowing: Bool
 {
  get { folder.isArrowMenuShowing }
  set { folder.managedObjectContext?.perform { self.folder.isArrowMenuShowing = newValue } }
 }
 
 var arrowMenuTouchPoint: CGPoint
 {
  get { (folder.arrowMenuTouchPoint as? CGPoint) ?? .zero }
  set
  {
 
   folder.managedObjectContext?.perform
   {
    if CGRect(x: 0, y: 0, width: 1, height: 1).insetBy(dx: 0.1, dy: 0.1).contains(newValue)
    {
     self.folder.arrowMenuTouchPoint = newValue as NSValue
     self.folder.isArrowMenuShowing = true
    }
   }
  }
 }
 
 var arrowMenuPosition: CGPoint
 {
  get { (folder.arrowMenuPosition as? CGPoint) ?? CGPoint(x: 0.75, y: 0.75) }
  set { folder.managedObjectContext?.perform { self.folder.arrowMenuPosition = newValue as NSValue } }
 }
 
 
 weak var zoomView: ZoomView?

 func cancelImageOperations(){}

 var dragAnimationCancelWorkItem: DispatchWorkItem?
 // the strong ref to work item responsible for cancellation of self draggable visual state.

 

 let  group = DispatchGroup()

 weak var dragSession: UIDragSession?

 static let folderItemUTI = "folderitem.newsman"
 
 let PDFContextSize = CGSize(width: 300, height: 500)

 var folder: PhotoFolder

 var hostedManagedObject: NSManagedObject {return folder}
 //getter for using in Draggable protocol to get wrapped MO

 var photoManagedObject: PhotoItemManagedObjectProtocol { folder }

 var singlePhotoItems: [PhotoItem] { folder.folderedPhotos.map{PhotoItem(photo: $0)} }

 var count: Int  {return self.folder.count}

 var isEmpty: Bool {return self.folder.isEmpty}
 
 var url: URL? {return self.folder.url}
 
 var id: UUID? {return self.folder.id}

 var photoSnippet: PhotoSnippet? {return folder.photoSnippet}

 func deleteFolder ()
 {
  guard let folderURL = self.url else { return }
  PhotoItem.deletePhotoItemFromDisk(at: folderURL)
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
 
 
 var sectionIndex: Int  { return folder.sectionIndex }
 
 var date: Date
 {
  guard folder.managedObjectContext != nil else { return Date.distantPast }
  guard let folderDate = folder.date as Date? else { return Date.distantPast }
  return folderDate
 }
 
 var rowPosition: Int   { return folder.rowPosition }

 var sectionTitle: String? { return folder.sectionTitle }

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
  configueAllStateSubscriptions()
 
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
 
}//class PhotoFolderItem: NSObject, PhotoItemProtocol...




