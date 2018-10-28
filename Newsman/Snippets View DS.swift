//
import Foundation
import UIKit
import CoreData
import GameplayKit

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
 
     var snippetsTableView: UITableView!
 
    //var images: [UIImage] = []
 
 
//    let imagesForAnimation = 30
 
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
                          {[weak cell] in
                           guard let cell = cell, cell.snippetID == id else {return}
                           animate()
                          }
                          
                         })
      }
      
      let id = cell.snippetID
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
      {[weak cell] in
       guard let cell = cell, cell.snippetID == id else {return}
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
      {[weak cell] in
       guard let cell = cell, cell.snippetID == id else {return}
       animate(duration * 0.25)
      }
      
     }

    ]
 
    var groupTitles = [String]()
    var itemsType: SnippetType!
    var snippetsData: [[BaseSnippet]] = []
    
    var aniImageSetDict: [BaseSnippet : [UIImage]] = [:]
 
    var hiddenSections = Set<Int>()
 
    var sectionNameKeyPath: String?
 
    func configueCurrentFRC() -> SnippetsFetchController
    {
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     let predicate = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
     return SnippetsFetchController(with: snippetsTableView, groupType: groupType, using: predicate, in: moc)

    }
 
    var items: [BaseSnippet]? {return currentFRC.items}
 
    lazy var currentFRC: SnippetsFetchController = configueCurrentFRC()
 
    var groupType: GroupSnippets!
    {
      didSet
      {
       if oldValue == nil
       {
        currentFRC.fetch()
       }
       else if let groupType = self.groupType, groupType != oldValue
       {
        currentFRC = configueCurrentFRC()
        currentFRC.fetch()
       }

      }
    }
 
    var fetchSortDescriptors: [NSSortDescriptor] = []
 

    static let dateFormatter =
    { () -> DateFormatter in
       let df = DateFormatter()
       df.dateStyle = .medium
       df.timeStyle = .none
       return df
       
    }()
 
 
 
//    lazy var items: [BaseSnippet] =
//    {
//            
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let moc = appDelegate.persistentContainer.viewContext
////        let mom = moc.persistentStoreCoordinator?.managedObjectModel
//        let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
////        guard let  request = mom?.fetchRequestFromTemplate(withName: "Snippets", substitutionVariables: ["p1" : itemsType.rawValue])?.copy() as? NSFetchRequest<BaseSnippet>
////        else
////        {
////         return []
////        }
//        let sort = NSSortDescriptor(key: #keyPath(BaseSnippet.date), ascending: false)
//        let pred = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
//        request.predicate = pred
//        request.sortDescriptors = [sort]
//        
//        do
//        {
//            let items = try moc.fetch(request)
//            return items
//        }
//        catch
//        {
//            let e = error as NSError
//            print ("Unresolved error \(e) \(e.userInfo)")
//            return []
//        }
//    }()
//    
//    func rebuildData ()
//    {
//     
//        guard let gtype = groupType else {return}
//        snippetsData = []
//        groupTitles = []
//     
//     
//        switch gtype
//        {
//         case .byPriority:
//            for filter in SnippetPriority.priorityFilters
//            {
//                let group = items.filter(filter.predicate)
//                snippetsData.append(group)
//                groupTitles.append(NSLocalizedString(filter.title, comment: filter.title))
//
//            }
//            
//         case .byDateCreated:
//            for filter in SnippetDates.dateFilter
//            {
//               let group = items.filter(filter.predicate)
//               snippetsData.append(group)
//               groupTitles.append(NSLocalizedString(filter.title, comment: filter.title))
//            }
//         case .alphabetically:
//            var letterSet = Set<Character>()
//            for item in items
//            {
//             if let firstLetter = item.tag?.first
//             {
//              letterSet.insert(firstLetter)
//             }
//            }
//            
//            snippetsData.append(items.filter
//                {
//                    ($0.tag?.isEmpty) ?? true
//                    
//            })
//            groupTitles.append("Untitled")
//            
//            for letter in letterSet.sorted()
//            {
//              let group = items.filter
//              {item in
//                if let firstLetter = item.tag?.first, firstLetter == letter
//                {
//                  return true
//                }
//                else
//                {
//                  return false
//                }
//              }
//              snippetsData.append(group.sorted{$0.tag! < $1.tag!})
//              groupTitles.append(String(letter))
//             }
//            
//         case .byLocation:
//            var locationSet = Set<String>()
//            for item in items
//            {
//              if let location = item.location
//              {
//               locationSet.insert(location)
//              }
//            }
//            
//            snippetsData.append(items.filter{$0.location == nil})
//            groupTitles.append("Undefined Location")
//            
//            for location in locationSet
//            {
//              let group = items.filter{$0.location == location}
//              snippetsData.append(group)
//              groupTitles.append(location)
//            }
//            
//         case .bySnippetType: break
//         case .plainList: snippetsData.append(items)
//         default: break
//        }
//    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//    {
//      return currentFRC.sectionTitle(for: section)
//    }
 

    
    func numberOfSections(in tableView: UITableView) -> Int
    {
      guard itemsType != nil else {return 0}
      return currentFRC.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     return currentFRC.numberOfRowsInSection(index: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath) as! SnippetsViewCell
      let item = currentFRC[indexPath]
      cell.hostedSnippet = item as? SnippetImagesPreviewProvidable
      cell.snippetDateTag.text = item.snippetDateTag
      cell.snippetTextTag.text = item.snippetName
      cell.backgroundColor = item.snippetPriority.color
      return cell
    }
    
 
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
     return groupType == .byPriority 
    }

 
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
     guard groupType == .byPriority, sourceIndexPath.section != destinationIndexPath.section else {return}
     currentFRC.move(from: sourceIndexPath, to: destinationIndexPath)
    }
 
    func snippetIndexPath(snippet: BaseSnippet) -> IndexPath
    {
     let path = snippetsData.enumerated().lazy.map{($0.offset, $0.element.index(of: snippet))}.first{$0.1 != nil}
     return IndexPath(row: path!.1!, section: path!.0)
    }
    
}
