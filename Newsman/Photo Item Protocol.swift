
import Foundation
import UIKit
import CoreData
import Combine

protocol PhotoItemProtocol: NSItemProviderWriting, NSItemProviderReading, Codable, Draggable, UndoableItem
{

 func cancellAllStateSubscriptions()
 func configueAllStateSubscriptions()
 
 var cellRowPositionChangeSubscription: AnyCancellable?     { get set } // not managed...
 var cellPriorityFlagChangeSubscription: AnyCancellable?    { get set } // not managed...
 var cellImageUpdateSubscription: AnyCancellable?           { get set } // not managed...
 var imagePublisher: AnyPublisher<UIImage, Never>           { get }
 
 var photoManagedObject: PhotoItemManagedObjectProtocol    { get     }

 var photoSnippet: PhotoSnippet?    { get     }

 var date: Date                     { get     }
 var rowPosition: Int               { get     }
 var sectionTitle: String?          { get     }
 // the section string title for Photo Item if snippet is grouped into sectiones

 var sectionIndex: Int              { get     }
 // the section integer index of Photo Item section if snippet is grouped into sectiones

 var priorityFlagIndex: Int         { get     }
 // the colored priority flag index to sort items by flags in sectiones

 var priorityFlag: String?          { get set }

 var priorityFlagColor: UIColor?    { get set }

 var url: URL?                       { get     } //conformer url getter to get access to the virtual data files

 var hostingCollectionViewCell: PhotoSnippetCellProtocol?  { get set }
 
 var hostingCollectionViewCellPublisher: AnyPublisher<PhotoSnippetCellProtocol?, Never> { get }
 
 //weak reference to the the CV cell that will display the conformer visual video preview or photo content

 //func deleteImages()

 func cancelImageOperations() //cancells all image loading backgroud operation

 func toggleSelection()

 func deleteFromContext()

 var isArrowMenuShowing: Bool       { get set }
 var arrowMenuTouchPoint: CGPoint   { get set }
 var arrowMenuPosition: CGPoint     { get set }

    
}//protocol PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -

func == (lhs: PhotoItemProtocol?, rhs: PhotoItemProtocol?) -> Bool
{
 return lhs?.hostedManagedObject.objectID == rhs?.hostedManagedObject.objectID
}

func != (lhs: PhotoItemProtocol?, rhs: PhotoItemProtocol?) -> Bool
{
 return lhs?.hostedManagedObject.objectID != rhs?.hostedManagedObject.objectID
}

extension PhotoItemProtocol
{
 func deleteFromContext()
 {
  terminate()
  photoManagedObject.delete()
 }
}


extension PhotoItemProtocol
{
 var priorityFlag: String?
 {
  get { return photoManagedObject.priorityFlag     }
  set { photoManagedObject.priorityFlag = newValue }
 }
 
 var priorityFlagIndex: Int { return PhotoPriorityFlags(rawValue: priorityFlag ?? "")?.rateIndex ?? -1 }
 
 var priorityFlagColor: UIColor?
 {
  get { photoManagedObject.priorityFlagColor            }
  set { photoManagedObject.priorityFlagColor = newValue }
 }
 
 var searchTag: String?
 {
  get { photoManagedObject.searchTag            }
  set { photoManagedObject.searchTag = newValue }
 }
 
 static var appDelegate: AppDelegate
 {
  if (Thread.current == Thread.main) { return UIApplication.shared.delegate as! AppDelegate }
  return DispatchQueue.main.sync { UIApplication.shared.delegate as! AppDelegate }
 }

 
 static var MOC: NSManagedObjectContext { appDelegate.viewContext }
 var photoGroupType: GroupPhotos? { return photoManagedObject.groupType }
 
}//extension PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -


protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
}





