
import Foundation
import UIKit
import CoreData

class SnippetsFetchController: NSObject, NSFetchedResultsControllerDelegate
{
 private let byDate =        NSSortDescriptor(key: #keyPath(BaseSnippet.date),     ascending: false)
 private let byTag =         NSSortDescriptor(key: #keyPath(BaseSnippet.tag),      ascending: true)
 private let byLocation =    NSSortDescriptor(key: #keyPath(BaseSnippet.location), ascending: true)
 private let byPriority =    NSSortDescriptor(key: #keyPath(BaseSnippet.priority), ascending: true)
 private let bySnippetType = NSSortDescriptor(key: #keyPath(BaseSnippet.type),     ascending: true)
 
 private var descriptors: [NSSortDescriptor]
 {
  switch groupType
  {
   case .plainList:      return [bySnippetType, byPriority, byDate, byTag]
   case .byLocation:     return [byLocation, byPriority, byDate, byTag   ]
   case .byPriority:     return [byPriority, byDate, byTag               ]
   case .bySnippetType:  return [bySnippetType, byPriority, byDate, byTag]
   case .byDateCreated:  return []
   case .alphabetically: return []
   case .nope:           return []
   
  }
 }
 
 private var sectionNameKeyPath: String?
 {
  switch groupType
  {
   case .plainList:      return nil
   case .byLocation:     return #keyPath(BaseSnippet.location)
   case .byPriority:     return #keyPath(BaseSnippet.priority)
   case .bySnippetType:  return #keyPath(BaseSnippet.type)
   case .byDateCreated:  return nil
   case .alphabetically: return nil
   case .nope:           return nil
   
  }
 }
 private lazy var frc: NSFetchedResultsController<BaseSnippet> =
 {
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
//  request.fetchBatchSize = 20
//  request.returnsObjectsAsFaults = false
  request.predicate = predicate
  request.sortDescriptors = descriptors
  
  let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc,
                                       sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
  frc.delegate = self
  return frc
  
 }()
 

 private var sectionCounters: [(rows: Int, frcSection: Int?)] = []

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
  
  //tableView.reloadData()
  
 }
 
 
 private func updateSectionCounters()
 {

  sectionCounters.removeAll()
  frc.sections?.enumerated().forEach{sectionCounters.append((rows: $0.1.numberOfObjects, frcSection: $0.0))}
 }
 
 
 func move (from source: IndexPath, to destination: IndexPath)
 {
  let snippet = self[source]
  deactivateDelegate()
  moc.persistAndWait 
  {[unowned self] in
   snippet.priority = self.sectionName(for: destination.section)
  }
  activateDelegate()
  sectionCounters[source.section].rows -= 1
  sectionCounters[destination.section].rows += 1
  var section = 0

  for i in 0..<sectionCounters.count
  {
   if sectionCounters[i].rows == 0
   {
    sectionCounters[i].frcSection = nil
    continue
    
   }
   sectionCounters[i].frcSection = section
   section += 1
  }

  refetch()
  
  tableView.performBatchUpdates({[weak self] in self?.tableView.reloadData()})
  {[weak self]_ in
   self?.tableView.performBatchUpdates({[weak self] in self?.removeEmptySections()})
   {[weak self] _ in
    let selected = self?[snippet]
    self?.tableView.selectRow(at: selected, animated: false, scrollPosition: .top)
   }
  }
  
  
  

 }
 
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
  refetch()
  updateSectionCounters()
 }
 
 func sectionName(for index: Int) -> String?
 {
   if let ind = sectionCounters[index].frcSection
   {
    return frc.sections?[ind].name
   }
  
   return nil
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
 
 func activateDelegate()
 {
  frc.delegate = self
 }
 
 func deactivateDelegate()
 {
  frc.delegate = nil
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
    if let indexPath = newIndexPath
    {
     tableView.insertRows(at: [indexPath], with: .fade)
    }
   
   case .update:
    if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? SnippetsViewCell
    {
     let snippet = frc.object(at: indexPath)
     let priority = SnippetPriority(rawValue: snippet.priority!)
     cell.backgroundColor = priority?.color
     cell.snippetTextTag.text = snippet.tag
     cell.snippetDateTag.text = SnippetsViewDataSource.dateFormatter.string(from: snippet.date! as Date)
    }
   
   case .delete:
    if let indexPath = indexPath
    {
     tableView.deleteRows(at: [indexPath], with: .fade)
    }
   
   case .move:
    if let toIndexPath = newIndexPath, let fromIndexPath = indexPath//, toIndexPath != fromIndexPath
    {
     tableView.deleteRows(at: [fromIndexPath], with: .fade)
     tableView.insertRows(at: [toIndexPath], with: .fade)
    }
   
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


