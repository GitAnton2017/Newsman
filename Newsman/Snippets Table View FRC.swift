
import Foundation
import UIKit
import CoreData

final class SnippetsFetchController: NSObject, NSFetchedResultsControllerDelegate
{
 private let byDate =        NSSortDescriptor(key: #keyPath(BaseSnippet.date),          ascending: false)
 private let byTag =         NSSortDescriptor(key: #keyPath(BaseSnippet.tag),           ascending: true)
 private let byLocation =    NSSortDescriptor(key: #keyPath(BaseSnippet.location),      ascending: true)
 private let byPriority =    NSSortDescriptor(key: #keyPath(BaseSnippet.priorityIndex), ascending: true)
 private let bySnippetType = NSSortDescriptor(key: #keyPath(BaseSnippet.type),          ascending: true)
 private let byAlphabet =    NSSortDescriptor(key: #keyPath(BaseSnippet.alphaIndex),    ascending: true)
 private let byDateIndex =   NSSortDescriptor(key: #keyPath(BaseSnippet.dateIndex),     ascending: true)
 
 private var descriptors: [NSSortDescriptor]
 {
  switch groupType
  {
   case .plainList:      return [bySnippetType, byPriority, byDate, byTag ]
   case .byLocation:     return [byLocation, byPriority, byDate, byTag    ]
   case .byPriority:     return [byPriority, byDate, byTag                ]
   case .bySnippetType:  return [bySnippetType, byPriority, byDate, byTag ]
   case .byDateCreated:  return [byDateIndex, byPriority, byDate, byTag   ]
   case .alphabetically: return [byAlphabet, byPriority, byDate, byTag    ]
   case .nope:           return []
   
  }
 }
 
 private var sectionNameKeyPath: String?
 {
  switch groupType
  {
   case .plainList:      return nil
   case .byLocation:     return #keyPath(BaseSnippet.location)
   case .byPriority:     return #keyPath(BaseSnippet.priorityIndex)
   case .bySnippetType:  return #keyPath(BaseSnippet.type)
   case .byDateCreated:  return #keyPath(BaseSnippet.dateIndex)
   case .alphabetically: return #keyPath(BaseSnippet.alphaIndex)
   case .nope:           return nil
   
  }
 }
 private lazy var frc: NSFetchedResultsController<BaseSnippet> =
 {
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  request.fetchBatchSize = 20
  request.returnsObjectsAsFaults = false
  request.predicate = predicate
  request.sortDescriptors = descriptors
  
  let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,
                                       sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
  frc.delegate = self
  return frc
  
 }()
 
 
 private typealias FRCSection = (rows: Int, frcSection: Int?)

 private var sectionCounters: [FRCSection] = []
 
 private var hiddenSections: Set<Int> = []

 var groupType: GroupSnippets
 var predicate: NSPredicate
 var tableView: UITableView
 var moc: NSManagedObjectContext


 init (with tableView: UITableView, groupType:  GroupSnippets,
       using predicate: NSPredicate, in context: NSManagedObjectContext)
 {
  self.tableView = tableView
  self.groupType = groupType
  self.predicate = predicate
  self.moc = context

  super.init()
 }
 
 func removeEmptySections()
 {
  let emptySet = sectionCounters.enumerated().filter{$0.element.rows == 0}.map{$0.offset}.sorted{$0 > $1}
  if !emptySet.isEmpty
  {
   emptySet.forEach{sectionCounters.remove(at: $0)}
   tableView.deleteSections(IndexSet(emptySet), with: .none)
  }
 }
 
 
 private func updateSectionCounters()
 {
  sectionCounters.removeAll()
  frc.sections?.enumerated().forEach{sectionCounters.append((rows: $0.1.numberOfObjects, frcSection: $0.0))}
 }

 
 private func updateEmptySections ()
 {
  sectionCounters.enumerated().filter{$0.element.rows == 0}.map{$0.offset}.forEach
  {offset in
   sectionCounters[offset].frcSection = nil
   for i in 0..<sectionCounters.count where i > offset && sectionCounters[i].frcSection != nil
   {
    sectionCounters[i].frcSection! -= 1
   }
  }
 }
 
 
 private func moveBatchUpdate(with indexPath: IndexPath?)
 {
  tableView.performBatchUpdates({[weak self] in self?.tableView.reloadData()})
  {[weak self]_ in
   self?.tableView.performBatchUpdates({[weak self] in self?.removeEmptySections()})
   {[weak self] _ in
    self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
   }
  }
 }
 
 func move (from source: IndexPath, to destination: IndexPath)
 {
  
  let snippet = self[source]
  deactivateDelegate()
  moc.persistAndWait {[unowned self] in snippet.snippetPriority = self.sectionPriority(for: destination.section) ?? .normal}
  activateDelegate()
  sectionCounters[source.section].rows -= 1
  sectionCounters[destination.section].rows += 1
  
  updateEmptySections()

  refetch()
  
  let selected = self[snippet]
  if isHiddenSection(section: destination.section)
  {
   unfoldSection(section: destination.section)
   {[weak self] in
    self?.moveBatchUpdate(with: selected)
   }
  }
  else
  {
   moveBatchUpdate(with: selected)
  }
 

 }
 
// func move (from sources: [IndexPath], to destination: IndexPath)
// {
//  
//  deactivateDelegate()
//  moc.persistAndWait
//   {[unowned self] in
//    sources.forEach {self[$0].priority = self.sectionName(for: destination.section)}
//  }
//  activateDelegate()
//  sources.forEach{sectionCounters[$0.section].rows -= 1}
//  sectionCounters[destination.section].rows += 1
//  
//  
// 
//  
//  refetch()
//  
//  tableView.performBatchUpdates({[weak self] in self?.tableView.reloadData()})
//  {[weak self]_ in
//   self?.tableView.performBatchUpdates({[weak self] in self?.removeEmptySections()})
//   {[weak self] _ in
//    
//   }
//  }
//  
// }
 
 private func refetch()
 {
  do
  {
   try frc.performFetch()
  }
  catch let error as NSError
  {
   print ("Fetching Error: \(error) \(error.userInfo)")
  }
 }
 
 func fetch()
 {
  batchUpdate()
  refetch()
  updateSectionCounters()
 }
 
 private func batchUpdate()
 {
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  request.predicate = predicate
  do
  {
   let items = try moc.fetch(request)
   moc.persist
   {
    items.forEach
    {snippet in
     snippet.priorityIndex = String(snippet.snippetPriorityIndex) + "_" + snippet.snippetPriority.rawValue
     if let first_ch = snippet.tag?.first
     {
      snippet.alphaIndex = String(first_ch)
     }
     else
     {
      snippet.alphaIndex = ""
     }
     snippet.dateIndex = BaseSnippet.snippetDates.datePredicates.first{$0.predicate(snippet)}?.title
    }
    
    print ("\(items.count) RECORDS UPDATED SUCCESSFULLY")
   }
  
  }
  catch
  {
    let e = error as NSError
    print ("Unresolved error \(e) \(e.userInfo)")
 
  }
  
 }
 
 func sectionTitle (for index: Int) -> String?
 {
  switch groupType
  {
   case .byDateCreated:  fallthrough
   case .byPriority:     return localizedSectionName (for: index)
   case .alphabetically: return localizedAlphabetName(for: index)
   case .byLocation:     fallthrough
   case .bySnippetType:  return sectionName(for: index)
   default :             return nil
  }
 }
 
 private func localizedAlphabetName (for index: Int) -> String?
 {
  guard let name = sectionName(for: index) else {return nil}
  return name.isEmpty ? Localized.unnamedSection : name
 }
 
 private func localizedSectionName (for index: Int) -> String?
 {
  guard let name = sectionName(for: index), let pos = name.firstIndex(of: "_") else {return nil}
  let title = String(name.suffix(from: pos).dropFirst())
  return NSLocalizedString(title, comment: title)
 }
 
 private func sectionPriority (for index: Int) -> SnippetPriority?
 {
  guard let name = sectionName(for: index), let pos = name.firstIndex(of: "_") else {return nil}
  return SnippetPriority(rawValue: String(name.suffix(from: pos).dropFirst()))
 }
 
 private func sectionName(for index: Int) -> String?
 {
  guard let section = sectionCounters[index].frcSection else {return nil}
  return frc.sections?[section].name
  
 }
 
 func numberOfSections() -> Int
 {
  return sectionCounters.count
 }
 
 func numberOfRowsInSection(index: Int) -> Int
 {
  return sectionCounters[index].rows
 }
 
 subscript (indexPath: IndexPath) -> BaseSnippet
 {
  get
  {
   let section = sectionCounters[indexPath.section].frcSection
   let ip = IndexPath(row: indexPath.row, section: section!)
   return frc.object(at: ip)
  }
 }
 
 subscript (snippet: BaseSnippet) -> IndexPath?
 {
  get
  {
   if let ip  = frc.indexPath(forObject: snippet),
      let section = sectionCounters.index(where: {$0.frcSection == ip.section})
   {
     return IndexPath(row: ip.row, section: section)
   }
   
   return nil
  }
 }
 
 var items: [BaseSnippet]? {return frc.fetchedObjects}
 
 subscript (snippetID: String) -> BaseSnippet?
 {
  get {return items?.first{$0.id?.uuidString == snippetID}}
 }
 
 func activateDelegate()
 {
  if (frc.delegate == nil) {frc.delegate = self}
 }
 
 func deactivateDelegate()
 {
  if (frc.delegate != nil) {frc.delegate = nil}
 }
 
 func isHiddenSection(section: Int) -> Bool {return hiddenSections.contains(section)}
 
// func sectionIndexPaths (for section: Int) -> [IndexPath]
// {
//  let count = sectionCounters[section].rows
//  return (0..<count).map{IndexPath(row: $0, section: section)}
// }
 
 func foldSection (section: Int)
 {
//  let indexPaths = sectionIndexPaths(for: section)
//  if indexPaths.isEmpty {return}
 
  if isHiddenSection(section: section)
  {
   hiddenSections.remove(section)
//   tableView.performBatchUpdates({tableView.insertRows(at: indexPaths, with: .automatic)})
//   {_ in
//    self.tableView.scrollToRow(at: indexPaths.first!, at: .top, animated: true)
//   }
  }
  else
  {
   hiddenSections.insert(section)
//   tableView.performBatchUpdates({tableView.deleteRows(at: indexPaths, with: .automatic)})
//   {_ in
//    let rect = self.tableView.rect(forSection: section)
//    self.tableView.scrollRectToVisible(rect, animated: true)
//   }
  }
  tableView.performBatchUpdates(nil)
 }
 
 private func unfoldSection (section: Int, with block: @escaping () -> Void)
 {
//  let indexPaths = sectionIndexPaths(for: section)
//  if indexPaths.isEmpty {return}
  
  hiddenSections.remove(section)
  if let header = tableView.headerView(forSection: section) as? SnippetsTableViewHeaderView
  {
   header.isHiddenSection = false
  }
  
//  tableView.performBatchUpdates({tableView.insertRows(at: indexPaths, with: .automatic)})
//  {_ in
//   block()
//  }
  
    tableView.performBatchUpdates(nil)
    {_ in
     block()
    }

 }
 
 
 func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
 {
  tableView.beginUpdates()
 }
 
 
 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange anObject: Any, at indexPath: IndexPath?,
                 for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
 {
  updateSectionCounters()
  
  switch type
  {
   case .insert:
    guard let indexPath = newIndexPath else {break}
    tableView.insertRows(at: [indexPath], with: .fade)
    let section = indexPath.section
    if let footer = tableView.footerView(forSection: section) as? SnippetsTableViewFooterView
    {
     footer.title = Localized.totalSnippets + String(numberOfRowsInSection(index: section))
    }
   
  
   case .update:
    guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? SnippetsViewCell else {break}
    let snippet = frc.object(at: indexPath)
    cell.backgroundColor = snippet.snippetPriority.color
    cell.snippetTextTag.text = snippet.snippetName
    cell.snippetDateTag.text = snippet.snippetDateTag
  
   case .delete:
    guard let indexPath = indexPath else {break}
    tableView.deleteRows(at: [indexPath], with: .fade)
    let section = indexPath.section
    if let footer = tableView.footerView(forSection: section) as? SnippetsTableViewFooterView
    {
     footer.title = Localized.totalSnippets + String(numberOfRowsInSection(index: section))
   }

   case .move:
    guard let toIndexPath = newIndexPath, let fromIndexPath = indexPath else {break}
    tableView.deleteRows(at: [fromIndexPath], with: .fade)
    tableView.insertRows(at: [toIndexPath], with: .fade)
  
  }
 }
 
 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                 for type: NSFetchedResultsChangeType)
 {
  updateSectionCounters()
  let indexSet = IndexSet(integer: sectionIndex)
  switch type
  {
   case .delete: tableView.deleteSections(indexSet, with: .fade)
   case .insert: tableView.insertSections(indexSet, with: .fade)
   default: break
  }
 }
 
 func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
 {
  tableView.endUpdates()
 }

}


