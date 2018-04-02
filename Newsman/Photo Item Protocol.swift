
import Foundation
import UIKit
import CoreData

//MARK: ----------------- Photo Item Protocol ----------------
protocol PhotoItemProtocol: NSItemProviderWriting, NSItemProviderReading, Codable
    //------------------------------------------------------------
{
    var photoSnippet: PhotoSnippet     { get     }
    var date: Date                     { get     }
    var position: Int16                { get set }
    var priority: Int                  { get     }
    var priorityFlag: String?          { get set }
    var isSelected: Bool               { get set }
    var id: UUID                       { get     }
    var url: URL                       { get     }
 
    var dragSession: UIDragSession?    { get set }
    
    func deleteImages()
    
}//protocol PhotoItemProtocol...
//-------------------------------------------------------------
//MARK: -


//MARK: ----------------- Photo Item Protocol Extension ----------------
extension PhotoItemProtocol
//----------------------------------------------------------------------
{
    static var appDelegate: AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
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


