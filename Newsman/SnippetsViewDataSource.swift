//
import Foundation
import UIKit
import CoreData
import GameplayKit

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
 
    var images: [UIImage] = []
 
    let imagesForAnimation = 30
    lazy var imagesAnimators: [([UIImage], SnippetsViewCell, TimeInterval, TimeInterval) -> Void] =
    [
     /*{imgs, cell, duration, delay in
      let kfa = CAKeyframeAnimation(keyPath: #keyPath(CALayer.contents))
      kfa.beginTime = CACurrentMediaTime() + delay
      kfa.values = imgs.map{$0.cgImage!}
      kfa.duration = duration * Double(imgs.count)
      kfa.repeatCount = .infinity
      kfa.autoreverses = true
      kfa.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      kfa.calculationMode = kCAAnimationCubic
      cell.snippetImage.layer.add(kfa, forKey: "movie")
      
     },*/
     
     {imgs, cell, duration, delay in
      
      cell.animating["trans1" + cell.snippetID] = true
      
      var i = 0
      
      let options: [UIViewAnimationOptions] =
       [.transitionFlipFromTop,
        .transitionFlipFromBottom,
        .transitionFlipFromRight,
        .transitionFlipFromLeft
       ]
      
      let arc4rnd = GKRandomDistribution(lowestValue: 0, highestValue: options.count - 1)
      
      func animate ()
      {
       guard let status = cell.animating["trans1" + cell.snippetID], status else {return}
       let option = options[arc4rnd.nextInt()]
       UIView.transition(with: cell.snippetImage, duration: 0.25 * duration,
                         options: [option, .curveEaseInOut],
                         animations: {cell.snippetImage.image = imgs[i]},
                         completion:
                         {finished  in
                          guard finished else {return}
                          guard let status = cell.animating["trans1" + cell.snippetID], status else {return}
                          if (i < imgs.count - 1) {i += 1} else {i = 0}
                          let id = cell.snippetID
                          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75 * duration)
                          {
                           guard cell.snippetID == id else {return}
                           animate()
                          }
                          
                         })
      }
      
      let id = cell.snippetID
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
      {
       guard cell.snippetID == id else {return}
       animate()
      }
      
     },
     
     {imgs, cell, duration, delay in
      
      cell.animating["trans2" + cell.snippetID] = true
      
      var i = 0
      
      let types = [kCATransitionPush, kCATransitionMoveIn, kCATransitionReveal]
      let a4rnd_t = GKRandomDistribution(lowestValue: 0, highestValue: types.count - 1)
      let subtypes = [kCATransitionFromTop, kCATransitionFromBottom, kCATransitionFromRight, kCATransitionFromLeft]
      let a4rnd_st = GKRandomDistribution(lowestValue: 0, highestValue: subtypes.count - 1)
     
      func animate (_ duration: TimeInterval)
      {
       guard let status = cell.animating["trans2" + cell.snippetID], status else {return}
       let trans = CATransition()
       trans.delegate = cell
       trans.type = types[a4rnd_t.nextInt()]
       trans.subtype = subtypes[a4rnd_st.nextInt()]
       trans.duration = duration
       cell.snippetImage.layer.add(trans, forKey: "trans2")
       cell.snippetImage.image = imgs[i]
       if (i < imgs.count - 1) {i += 1} else {i = 0}
       
      }
      
      cell.transDuration = duration
      cell.animate = animate
      
      let id = cell.snippetID
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
      {
       guard cell.snippetID == id else {return}
       animate(duration * 0.25)
      }
      
     }
     
     
     
    ]
 
    var groupTitles = [String]()
    var itemsType: SnippetType!
    var snippetsData: [[BaseSnippet]] = []
    
    var aniImageSetDict: [BaseSnippet : [UIImage]] = [:]
    
    
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
                groupTitles.append(NSLocalizedString(filter.title, comment: filter.title))

            }
            
         case .byDateCreated:
            for filter in SnippetDates.dateFilter
            {
               let group = items.filter(filter.predicate)
               snippetsData.append(group)
               groupTitles.append(NSLocalizedString(filter.title, comment: filter.title))
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
            
            snippetsData.append(items.filter
                {
                    ($0.tag?.isEmpty) ?? true
                    
            })
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
    
     
      (cell as! SnippetsViewCell).clear()
      (cell as! SnippetsViewCell).snippetID = (item.id?.uuidString)!
      (cell as! SnippetsViewCell).snippetDateTag.text = dateFormatter.string(from: item.date! as Date)
      (cell as! SnippetsViewCell).snippetTextTag.text = item.tag
     
      if let snippetPriority = item.priority,
         let priority = SnippetPriority(rawValue: snippetPriority)
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
       
       case .video: fallthrough
       case .photo:
        
        let photoSnippet = item as! PhotoSnippet
        let photoSnippetCell = cell as! SnippetsViewCell
        
        let sort = NSSortDescriptor(key: #keyPath(Photo.date), ascending: true)
        if let latestPhoto = photoSnippet.photos?.sortedArray(using: [sort]).last as? Photo
        {
          let iconWidth = photoSnippetCell.snippetImage.frame.width
         
          PhotoItem(photo: latestPhoto).getImage(requiredImageWidth: iconWidth, context: photoSnippetCell)
          {[weak self] (image) in
           
           guard image != nil else {return}
           
           guard let ip = {self?.groupType == .byPriority ? self?.snippetIndexPath(snippet: photoSnippet) : indexPath}(),
                 let cell = tableView.cellForRow(at: ip) as? SnippetsViewCell else {return}
           
       
           
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1))
           {
            cell.imageSpinner.stopAnimating()
            
            UIView.transition(with: cell.snippetImage, duration: 0.35, options: [.transitionFlipFromTop, .curveEaseInOut],
                              animations: {cell.snippetImage.image = image},
                              completion:
                              {_ in
                              
                               cell.snippetImage.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                               UIView.animate(withDuration: 0.15, delay: 0.25, usingSpringWithDamping: 3500,
                               initialSpringVelocity: 0,
                               options: .curveEaseInOut,
                               animations: {cell.snippetImage.transform = .identity},
                               completion:
                               {_ in
                                
                                
                                PhotoItem.getRandomImages3(for: photoSnippet, number: self!.imagesForAnimation,
                                                           requiredImageWidth: iconWidth,
                                                           loadContext: cell)
                                {[weak self] images in
                                 
                                 guard let ip  = {self?.groupType == .byPriority ? self?.snippetIndexPath(snippet:          photoSnippet) : indexPath}(),
                                       let _cell = tableView.cellForRow(at: ip) as? SnippetsViewCell else {return}
                                
                                 _cell.snippetImage.layer.removeAllAnimations()
                                 _cell.animating = [:]
                                 
                                 guard var imgs = images else {return}
                                 
                                 if let firstImage = image
                                 {
                                  imgs.insert(firstImage, at: 0)
                                 }
                                 
                                 let a4rnd = GKRandomDistribution(lowestValue: 0,
                                                                highestValue: self!.imagesAnimators.count - 1)
                                 
                                 self?.imagesAnimators[a4rnd.nextInt()](imgs, _cell, 2.0, 5.0)
                                
                              
                                }
                               })
                              })
                              
           
           }
          }
        }
        else
        {
         
           photoSnippetCell.imageSpinner.stopAnimating()
           photoSnippetCell.snippetImage.image = UIImage(named: "photo.main")
        }

       
       case .audio: break
       case .sketch: break
       case .report: break
       default: break
      }
        
      return cell
    }
    
 
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
     return (groupType == .byPriority || groupType == .plainList)
    }
 
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
     
     let from = sourceIndexPath
     let to = destinationIndexPath
      
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
     }
     
     
     tableView.reloadData()
    
    }
 
    func snippetIndexPath(snippet: BaseSnippet) -> IndexPath
    {
     let path = snippetsData.enumerated().lazy.map{($0.offset, $0.element.index(of: snippet))}.first{$0.1 != nil}
     return IndexPath(row: path!.1!, section: path!.0)
    }
    
}
