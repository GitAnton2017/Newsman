
import Foundation
import UIKit
import CoreData

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
    
    var groupTitles = [String]()
    var itemsType: SnippetType!
    var snippetsData: [[BaseSnippet]] = []
    let photoCache = (UIApplication.shared.delegate as! AppDelegate).photoCache
    
    var groupType: GroupSnippets!
    {
        didSet
        {
         //rebuildData()
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
        snippetsData = []; groupTitles = []
        
        switch (groupType)
        {
         case .byPriority:
            for filter in SnippetPriority.priorityFilters
            {
                let group = items.filter(filter.predicate)
                snippetsData.append(group)
                groupTitles.append(filter.title)

            }
            
         case .byDateCreated:
            for filter in SnippetDates.dateFilter
            {
               let group = items.filter(filter.predicate)
               snippetsData.append(group)
               groupTitles.append(filter.title)
            }
         case .alphabetically:
            var letterSet = Set<Character>()
            for item in items
            {
             if let firstLetter = item.tag?.first
             {
              letterSet.insert(firstLetter)
             }
            }
            
            snippetsData.append(items.filter{($0.tag?.isEmpty)!})
            groupTitles.append("Untitled")
            
            for letter in letterSet.sorted()
            {
              let group = items.filter
              {item in
                if let firstLetter = item.tag?.first, firstLetter == letter
                {
                  return true
                }
                else
                {
                  return false
                }
              }
              snippetsData.append(group.sorted{$0.tag! < $1.tag!})
              groupTitles.append(String(letter))
             }
            
         case .byLocation:
            var locationSet = Set<String>()
            for item in items
            {
              if let location = item.location
              {
               locationSet.insert(location)
              }
            }
            
            snippetsData.append(items.filter{$0.location == nil})
            groupTitles.append("Undefined Location")
            
            for location in locationSet
            {
              let group = items.filter{$0.location == location}
              snippetsData.append(group)
              groupTitles.append(location)
            }
            
         case .bySnippetType: break
         case .plainList: snippetsData.append(items)
         default: break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (groupType == .plainList)
        {
         return nil
        }
        else
        {
          if (snippetsData[section].isEmpty)
          {
           return nil
          }
          else
          {
           return groupTitles[section]
          }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return snippetsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return snippetsData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath)
      let item = snippetsData[indexPath.section][indexPath.row]
      (cell as! SnippetsViewCell).snippetDateTag.text = dateFormatter.string(from: item.date! as Date)
      (cell as! SnippetsViewCell).snippetTextTag.text = item.tag
      if let snippetPriority = item.priority, let priority = SnippetPriority(rawValue: snippetPriority)
      {
       (cell as! SnippetsViewCell).backgroundColor = priority.color
      }
      else
      {
       (cell as! SnippetsViewCell).backgroundColor = SnippetPriority.normal.color
       item.priority = SnippetPriority.normal.rawValue
      }
      
      switch (itemsType)
      {
       case .text: (cell as! SnippetsViewCell).snippetImage.image = UIImage(named: "text.main")
       case .photo:
        let photoSnippet = item as! PhotoSnippet
        if let icon = photoCache.getPhotos(photoSnippet: photoSnippet).first
        {
          (cell as! SnippetsViewCell).snippetImage.image = icon.image
        }
        else
        {
          (cell as! SnippetsViewCell).snippetImage.image = UIImage(named: "photo.main")
        }

       case .video: break
       case .audio: break
       case .sketch: break
       case .report: break
       default: break
      }
        
      return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
     
     let from = sourceIndexPath;  let to = destinationIndexPath
      
     if (from.section == to.section)
     {
        let moved = snippetsData[from.section].remove(at: from.row)
        snippetsData[to.section].insert(moved, at: to.row)
     }
     else
     {
       if (groupType == .byPriority)
       {
        let moved = snippetsData[from.section].remove(at: from.row)
        snippetsData[to.section].insert(moved, at: to.row)
        let cell = tableView.cellForRow(at: to)
        let priority = SnippetPriority.priorities[to.section]
        moved.priority = priority.rawValue
        cell?.backgroundColor = SnippetPriority.priorityColorMap[priority]
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
       }
       else
       {
        tableView.moveRow(at: to, to: from)
       }
       
     }
     tableView.reloadData()
    
    }
    
}
