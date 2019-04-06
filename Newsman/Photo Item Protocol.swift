
import Foundation
import UIKit
import CoreData

//MARK: ----------------- Photo Item Protocol ----------------
protocol PhotoItemProtocol: NSItemProviderWriting, NSItemProviderReading, Codable, Draggable
//------------------------------------------------------------
{
    var photoSnippet: PhotoSnippet     { get      }
 
    var date: Date                     { get     }
    var position: Int16                { get set }
    var priority: Int                  { get     }
    var priorityFlag: String?          { get set }
    var url: URL                       { get     } //conformer url getter to get access to the virtual data files
 
    var hostingCollectionViewCell: PhotoSnippetCellProtocol?  { get set }
    //weak reference to the the CV cell that will display the conformer visual video preview or photo content
 
    func deleteImages()
 
    func cancelImageOperations() //cancells all image loading backgroud operation
    func toggleSelection()
 
    func deleteFromContext()

    
}//protocol PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -

func == (lhs: PhotoItemProtocol?, rhs: PhotoItemProtocol?) -> Bool
{
 return lhs?.hostedManagedObject === rhs?.hostedManagedObject
}

func != (lhs: PhotoItemProtocol?, rhs: PhotoItemProtocol?) -> Bool
{
 return lhs?.hostedManagedObject !== rhs?.hostedManagedObject
}


//MARK: ----------------- Photo Item Protocol Extension ----------------
extension PhotoItemProtocol
//----------------------------------------------------------------------
{
    static var appDelegate: AppDelegate
    {
      if (Thread.current == Thread.main)
      {
       return UIApplication.shared.delegate as! AppDelegate
      }

      return DispatchQueue.main.sync
      {
        return UIApplication.shared.delegate as! AppDelegate
      }
    }
    
    static func saveContext()
    {
        appDelegate.saveContext()
    }
    
    static var MOC: NSManagedObjectContext
    {
        return appDelegate.persistentContainer.viewContext
    }
    
    
}//extension PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -


protocol ImageContextLoadProtocol
{
 var isLoadTaskCancelled: Bool {get set}
}





