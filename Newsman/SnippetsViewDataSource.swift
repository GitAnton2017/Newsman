
import Foundation
import UIKit
import CoreData


class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
    var itemsType: SnippetType!
    
    let dateFormatter =
    { () -> DateFormatter in
       let df = DateFormatter()
       df.dateStyle = .medium
       df.timeStyle = .none
       return df
       
    }()
    
    lazy var items: [BaseSnippet] =
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let pred = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
        request.predicate = pred
        request.sortDescriptors = [sort]
        
        do
        {
            let items = try moc.fetch(request)
            return items
        }
        catch
        {
            let e = error as NSError
            print ("Unresolved error \(e) \(e.userInfo)")
            return [BaseSnippet]()
        }
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath)
        
      switch (itemsType)
      {
       case .text:
        (cell as! SnippetsViewCell).snippetDateTag.text = dateFormatter.string(from: items[indexPath.row].date! as Date)
        (cell as! SnippetsViewCell).snippetTextTag.text = items[indexPath.row].tag
        (cell as! SnippetsViewCell).snippetImage.image = UIImage(named: "text.tab.icon")
        
       case .photo: break
       case .video: break
       case .audio: break
       case .sketch: break
       case .report: break
       default: break
      }
        
      return cell
    }
    
    
    
}
