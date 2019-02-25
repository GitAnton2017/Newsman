
import Foundation
import UIKit
import CoreData

final class SnippetsFetchController: NSObject, NSFetchedResultsControllerDelegate
{
 
 deinit{
  print (self.debugDescription, "destroyed")
 }
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
 

 private typealias FRCSection = (rows: Int, frcSection: Int?, hidden: Bool)

 private var sectionCounters: [FRCSection] = []


 var groupType: GroupSnippets
 var predicate: NSPredicate
 var tableView: UITableView
 var moc: NSManagedObjectContext
 
// var mocSaveToken: NSObjectProtocol!

// deinit
// {
//  NotificationCenter.default.removeObserver(mocSaveToken)
// }

 init (with tableView: UITableView, groupType:  GroupSnippets,
       using predicate: NSPredicate, in context: NSManagedObjectContext)
 {
 
  self.tableView = tableView
  self.groupType = groupType
  self.predicate = predicate
  self.moc = context

  super.init()
  
  print(#function)
  print(self.debugDescription)

  
//  mocSaveToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave,
//                                                        object: moc, queue: nil)
//  {notification in
//   //print (notification)
//  }
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
 
 
// func setSnippetsPriority(at indexPaths: [IndexPath], to newPriority: SnippetPriority)
// {
////  guard groupType == .byPriority else
////  {
////   moc.persist{ indexPaths.forEach { self[$0].snippetPriority = newPriority } }
////   return
////  }
////
////  deactivateDelegate()
//  moc.persistAndWait(block: { indexPaths.map{self[$0]}.forEach {$0.snippetPriority = newPriority } })
////  {flag in
//// 
////   guard flag else
////   {
////    self.activateDelegate()
////    return
////   }
////   
////   self.refetch()
////   self.updateSectionCounters()
////   self.tableView.reloadData()
////   self.activateDelegate()
////   
////  }
// }
 
 
 func updateSectionCounters()
 {
  
  sectionCounters.removeAll()
  frc.sections?.enumerated().forEach
  { (offset, section) in
   let totalRows = section.numberOfObjects
   let hidden = section.objects?.compactMap{$0 as? BaseSnippet}.allSatisfy{$0[groupType]} ?? true
   sectionCounters.append((rows: totalRows, frcSection: offset, hidden: hidden))
  }
  
//  sectionCounters.enumerated().forEach{
//   print ("\($0.0) | rows - \($0.1.rows) | frcs - \($0.1.frcSection ?? -1) | hidden: \($0.1.hidden) |")
//  }
 }


 private func updateEmptySections ()
 {
  sectionCounters.enumerated().filter{$0.element.rows == 0}.map{$0.offset}.forEach
  {offset in
   sectionCounters[offset].frcSection = nil
   sectionCounters[offset].hidden = true
   for i in 0..<sectionCounters.count where i > offset && sectionCounters[i].frcSection != nil
   {
    sectionCounters[i].frcSection! -= 1
    let k = sectionCounters[i].frcSection!
    sectionCounters[i].hidden = frc.sections?[k].objects?.compactMap{$0 as? BaseSnippet}.allSatisfy{$0[groupType]} ?? true
   }
  }
 }
 
 
 private func moveBatchUpdate(for snippet: BaseSnippet)
 {
  tableView.performBatchUpdates({[weak self] in self?.tableView.reloadData()})
  {[weak self]_ in
   self?.tableView.performBatchUpdates({[weak self] in self?.removeEmptySections()})
   {[weak self] _ in
    self?.tableView.selectRow(at: self?[snippet], animated: false, scrollPosition: .top)
   }
  }
 }
 
 func move (from source: IndexPath, to destination: IndexPath)
 {

  let snippet = self[source]
  deactivateDelegate()
  moc.persistAndWait
  {[unowned self] in
   snippet.snippetPriority = self.sectionPriority(for: destination.section) ?? .normal
   snippet[groupType] = isHiddenSection(section: destination.section)
  }
  activateDelegate()
  sectionCounters[source.section].rows -= 1
  sectionCounters[destination.section].rows += 1

  updateEmptySections()

  refetch()

  if isHiddenSection(section: destination.section)
  {
   unfoldSection(section: destination.section)
   {[weak self] in
    self?.moveBatchUpdate(for: snippet)
   }
  }
  else
  {
   moveBatchUpdate(for: snippet)
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
 
 func refetch()
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
  print (#function)
  
  batchUpdate()
  refetch()
  updateSectionCounters()
  
  print (frc.debugDescription)
  
 }
 
 private func batchUpdate()
 {
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  request.predicate = predicate
  do
  {
   let items = try moc.fetch(request)
   moc.persistAndWait
   {
    items.forEach
    {snippet in
     snippet.priorityIndex = String(snippet.snippetPriorityIndex) + "_" + snippet.snippetPriority.rawValue
     
     if let first_ch = snippet.tag?.first { snippet.alphaIndex = String(first_ch)}
     else
     {
      snippet.alphaIndex = ""
     }
     
     snippet.dateIndex = BaseSnippet.snippetDates.datePredicates.first{$0.predicate(snippet)}?.title
     
     if snippet.location == nil {snippet.snippetLocation = ""}
     
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
   case .byPriority:     return localizedSectionName  (for: index)
   case .alphabetically: return localizedAlphabetName (for: index)
   case .byLocation:     return locationName          (for: index)
   case .bySnippetType:  return sectionName           (for: index)
   default :             return nil
  }
 }
 
 private func sectionName(for index: Int) -> String?
 {
  guard let section = sectionCounters[index].frcSection else {return nil}
  return frc.sections?[section].name
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
 
 private func locationName (for index: Int) -> String?
 {
  guard let name = sectionName(for: index) else {return nil}
  return name.isEmpty ? Localized.undefinedLocationSection : name
 }
 
 private func sectionPriority (for index: Int) -> SnippetPriority?
 {
  guard let name = sectionName(for: index), let pos = name.firstIndex(of: "_") else {return nil}
  return SnippetPriority(rawValue: String(name.suffix(from: pos).dropFirst()))
 }
 

 
 final func numberOfSections() -> Int
 {
  return sectionCounters.count
 }
 
 
 var isUpdatingCells = false
 
 final func numberOfRowsInSection(index: Int) -> Int
 {
  return isUpdatingCells ? allObjects(for: index).count : visibleObjects(for: index).count
 }
 
 
 final func totalNumberOfRowsInSection(index: Int) -> Int
 {
  return allObjects(for: index).count
 }

 
 final func isHiddenSection(section: Int) -> Bool
 {
  guard section < sectionCounters.count else { return true }
  return sectionCounters[section].hidden
 }
 
// final func isHiddenSection(predicate: (BaseSnippet) -> Bool ) -> Bool
// {
// 
//  let N  = sectionCounters.count
//  return (0..<N).contains
//  {index in
//   isHiddenSection(section: index) && allObjects(for: index).allSatisfy(predicate)
//  }
// }
 

 
 private func allObjects(for section: Int) -> [BaseSnippet]
 {
  guard section < sectionCounters.count else { return [] }
  guard let frcSection = sectionCounters[section].frcSection else { return [] }
  return frc.sections?[frcSection].objects?.compactMap{$0 as? BaseSnippet} ?? []
 }
 
 private func hiddenObjects(for section: Int) -> [BaseSnippet]
 {
  return allObjects(for: section).filter{ $0[groupType] }
 }
 
 private func visibleObjects(for section: Int) -> [BaseSnippet]
 {
  return allObjects(for: section).filter{!$0[groupType]}
 }
 
 private func setAllObjectsVisibleState(for section: Int, to state: Bool)
 {
  allObjects(for: section).forEach{$0[groupType] = state}
  sectionCounters[section].hidden = state
 }
 
 
 final subscript (indexPath: IndexPath) -> BaseSnippet
 {
  let snippet = allObjects(for: indexPath.section)[indexPath.row]
  snippet.currentFRC = self
  return snippet
 }
 
 final subscript (snippet: BaseSnippet) -> IndexPath?
 {
  if let ip  = frc.indexPath(forObject: snippet),
     let section = sectionCounters.index(where: {$0.frcSection == ip.section})
  {
    let visibles = visibleObjects(for: section)
    if let row = visibles.index(of: snippet)
    {
     return IndexPath(row: row, section: section)
    }
    return nil
  }

  return nil
 
 }
 
 
 final var items: [BaseSnippet]?
 {
  return frc.fetchedObjects
 }
 
 
 final subscript (snippetID: String) -> BaseSnippet?
 {
  let snippet = items?.first{ $0.id?.uuidString == snippetID }
  snippet?.currentFRC = self
  return snippet
 }
 
 
 final func activateDelegate()
 {
  if (frc.delegate == nil) {frc.delegate = self}
 }
 
 
 final func deactivateDelegate()
 {
  if (frc.delegate != nil) {frc.delegate = nil}
 }
 
 
 
 final func isDisclosedCell(for indexPath: IndexPath) -> Bool
 {
  return self[indexPath].disclosedCell
 }
 

 private func sectionIndexPaths (for section: Int) -> [IndexPath]
 {
  let count = sectionCounters[section].rows
  return (0..<count).map{IndexPath(row: $0, section: section)}
 }
 
 private func sectionCells (for section: Int) -> [SnippetsViewCell]
 {
  return sectionIndexPaths(for: section).compactMap
  {
   tableView.cellForRow(at: $0) as? SnippetsViewCell
  }
 }
 
 private func cancelAllOperations(for section: Int)
 {
  sectionCells(for: section).forEach
  {
   guard $0.bounds.height == 0 else {return}
   $0.stopImageProvider()
  }
 }
 
 private func reset(section: Int, state: Bool)
 {
  deactivateDelegate()
  moc.persistAndWait
  {
   self.sectionIndexPaths(for: section).forEach{self[$0][groupType] = state}
  }
  activateDelegate()
 }
 
 
 func toggleFoldSection(section: Int, completion: ((Bool) -> ())? = nil)
 {
  if sectionCounters.isEmpty { return }
  guard section < sectionCounters.count else { return }
  guard sectionCounters[section].rows > 0 else  { return }
  
  var hidden = isHiddenSection(section: section)
  hidden.toggle()
  deactivateDelegate()
  moc.persistAndWait(block:
  {
   self.setAllObjectsVisibleState(for: section, to: hidden)
  })
  {flag in
   DispatchQueue.main.async
   {
    guard flag else
    {
     self.activateDelegate()
     return
    }
    let ips = self.sectionIndexPaths(for: section)
    if hidden
    {
     self.tableView.performBatchUpdates(
     {
      self.tableView.deleteRows(at: ips , with: .automatic)
      //self.tableView.insertRows(at: ips , with: .automatic)
     })
     {_ in
      let rect = self.tableView.rect(forSection: section)
      self.tableView.scrollRectToVisible(rect, animated: true)
      self.activateDelegate()
      completion?(hidden)
     }
    }
    else
    {
     self.tableView.performBatchUpdates(
     {
      //self.tableView.deleteRows(at: ips , with: .automatic)
      self.tableView.insertRows(at: ips , with: .automatic)
     })
     {_ in
      self.tableView.scrollToRow(at: ips[0], at: .none, animated: true)
      self.activateDelegate()
      completion?(hidden)
     }
    }
   }
  }
 }
 
 
 func foldSection (section: Int)
 {
//  let indexPaths = sectionIndexPaths(for: section)
//  if indexPaths.isEmpty {return}
 
  if isHiddenSection(section: section)
  {
   reset(section: section, state: false)
   //hiddenSections.remove(section)
   //tableView.reloadSections([section], with: .automatic)
   
   tableView.reloadRows(at: sectionIndexPaths(for: section), with: .automatic)
   sectionCells(for: section).forEach{$0.snippetImage.layer.removeAllAnimations()}
   
//   tableView.performBatchUpdates(nil)
//   {[weak self] _ in
//    self?.tableView.reloadSections([section], with: .automatic)
//   }
   
  
//   tableView.performBatchUpdates({tableView.insertRows(at: indexPaths, with: .automatic)})
//   {_ in
//    self.tableView.scrollToRow(at: indexPaths.first!, at: .top, animated: true)
//   }
  }
  else
  {
   
   //hiddenSections.insert(section)
   
   reset(section: section, state: true)
   tableView.performBatchUpdates(nil)
   {[weak self] _ in
    self?.cancelAllOperations(for: section)
   }
//   tableView.performBatchUpdates({tableView.deleteRows(at: indexPaths, with: .automatic)})
//   {_ in
//    let rect = self.tableView.rect(forSection: section)
//    self.tableView.scrollRectToVisible(rect, animated: true)
//   }
  }
  
 }
 
 private func unfoldSection (section: Int, with block: @escaping () -> Void)
 {
//  let indexPaths = sectionIndexPaths(for: section)
//  if indexPaths.isEmpty {return}
  
  //hiddenSections.remove(section)
  
  reset(section: section, state: false)
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
 
 
 private func updateFootersTitle(for sections: [Int])
 {
  sections.forEach
  {section in
   if let footer = tableView.footerView(forSection: section) as? SnippetsTableViewFooterView
   {
    footer.title = Localized.totalSnippets + String(totalNumberOfRowsInSection(index: section))
   }
  }
 }
 
 
 func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
 {
  print (#function)
  isUpdatingCells = true
  tableView.reloadData()
  tableView.beginUpdates()
  
 }
 
 
 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange anObject: Any, at indexPath: IndexPath?,
                 for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
 {
  
  //print (#function, "from: ", indexPath, "to: ", newIndexPath, "type: ", type.rawValue)
  
  defer
  {
   updateSectionCounters()
  }

  switch type
  {
   case .insert:
    guard let insertIndexPath = newIndexPath else { break }
    let section = insertIndexPath.section
    tableView.insertRows(at: [insertIndexPath], with: .fade)
    updateFootersTitle(for: [section])
  
   case .update:
    
    guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? SnippetsViewCell else { break }
    cell.hostedSnippet = frc.object(at: indexPath) as? SnippetImagesPreviewProvidable

   case .delete:
    guard let deleteIndexPath = indexPath else {break}
    let section = deleteIndexPath.section
    tableView.deleteRows(at: [deleteIndexPath], with: .fade)
    updateFootersTitle(for: [section])

   case .move:
    guard let toIndexPath = newIndexPath, let fromIndexPath = indexPath else { break }
    let toSection = toIndexPath.section
    let  fromSection = fromIndexPath.section
    tableView.deleteRows(at: [fromIndexPath], with: .fade)
    tableView.insertRows(at: [toIndexPath],   with: .fade)
    
    
    updateFootersTitle(for: [toSection, fromSection])
   

  }
  
  
 }

 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                 for type: NSFetchedResultsChangeType)
 {
//  print (#function, "section: ", sectionIndex, "type: ", type.rawValue)
  
  defer
  {
   updateSectionCounters()
  }
  
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
  print (#function)
  tableView.endUpdates()
  isUpdatingCells = false
  tableView.reloadData()
 }

}


