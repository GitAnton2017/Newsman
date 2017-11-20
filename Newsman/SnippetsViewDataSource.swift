
import Foundation
import UIKit
import CoreData

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
    
    var groupTitles = [String]()
    var itemsType: SnippetType!
    var spippetsData: [[BaseSnippet]] = []
    var groupType: GroupSnippets!
    {
        didSet
        {
         rebuildData()
        }
    }
    
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
        let sort = NSSortDescriptor(key: #keyPath(BaseSnippet.date), ascending: false)
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
    
    func rebuildData ()
    {
        spippetsData = []; groupTitles = []
        
        switch (groupType)
        {
         case .byPriority:
            for filter in SnippetPriority.priorityFilters
            {
                let group = items.filter(filter.predicate)
                if group.count > 0
                {
                 spippetsData.append(group)
                 groupTitles.append(filter.title)
                }
            }
            
         case .byDateCreated:
            for filter in SnippetDates.dateFilter
            {
               let group = items.filter(filter.predicate)
               if group.count > 0
               {
                spippetsData.append(group)
                groupTitles.append(filter.title)
               }
            }
         case .alphabetically: break
         case .bySnippetType: break
         case .plainList:
            spippetsData.append(items)
         default: break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return groupType == .plainList ? nil : groupTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return groupType == .plainList ? 1 : spippetsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return spippetsData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath)
      let item = spippetsData[indexPath.section][indexPath.row]
      (cell as! SnippetsViewCell).snippetDateTag.text = dateFormatter.string(from: item.date! as Date)
      (cell as! SnippetsViewCell).snippetTextTag.text = item.tag
      
      let priority = SnippetPriority(rawValue: item.priority!)
      (cell as! SnippetsViewCell).backgroundColor = priority?.color
        
      switch (itemsType)
      {
       case .text: (cell as! SnippetsViewCell).snippetImage.image = UIImage(named: "text.tab.icon")
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
