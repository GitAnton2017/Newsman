
import Foundation
import UIKit
import CoreData



final class SnippetsFetchController: NSObject, NSFetchedResultsControllerDelegate
{
 static let cacheName = "Newsman_FRC"
 
 deinit
 {
  print (self.debugDescription, "destroyed")
 }
 
 private var descriptors: [NSSortDescriptor]
 {
  switch groupType
  {
   case .plainList:      return [Sort.bySnippetTypeAsc, Sort.byPriorityAsc, Sort.byDateDes,  Sort.byTagAsc ]
   case .byLocation:     return [Sort.byLocationAsc,    Sort.byPriorityAsc, Sort.byDateDes,  Sort.byTagAsc ]
   case .byPriority:     return [Sort.byPriorityAsc,                        Sort.byDateDes,  Sort.byTagAsc ]
   case .bySnippetType:  return [Sort.bySnippetTypeAsc, Sort.byPriorityAsc, Sort.byDateDes,  Sort.byTagAsc ]
   case .byDateCreated:  return [Sort.byDateIndexAsc,   Sort.byPriorityAsc, Sort.byDateDes,  Sort.byTagAsc ]
   case .alphabetically: return [Sort.byAlphabetAsc,    Sort.byPriorityAsc, Sort.byDateDes,  Sort.byTagAsc ]
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

 private lazy var fetchRequest: NSFetchRequest<BaseSnippet> =
 {
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  request.predicate = predicate
  return request
  
 }()
 
 private lazy var frc: NSFetchedResultsController<BaseSnippet> =
 {
  fetchRequest.fetchBatchSize = 50
  fetchRequest.returnsObjectsAsFaults = false
  fetchRequest.sortDescriptors = descriptors
  
  let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: moc,
                                       sectionNameKeyPath: sectionNameKeyPath,
                                       cacheName: snippetType.rawValue)
  frc.delegate = self
  return frc
  
 }()
 
 
 var isSearchMode = false
 
 var ignoreHiddenSections = false
 
 private typealias FRCSection = (rows: Int, frcSection: Int?, hidden: Bool)

 private var sectionCounters: [FRCSection] = []

 var groupType: GroupSnippets
 var predicate: NSPredicate?
 var tableView: UITableView
 var moc: NSManagedObjectContext
 var snippetType: SnippetType

 
// var mocSaveToken: NSObjectProtocol!

// deinit
// {
//  NotificationCenter.default.removeObserver(mocSaveToken)
// }

 init (with tableView: UITableView, groupType:  GroupSnippets,
       using predicate: NSPredicate?, in context: NSManagedObjectContext, snippetType: SnippetType)
 {
 
  self.tableView = tableView
  self.groupType = groupType
  self.predicate = predicate
  self.moc = context
  self.snippetType = snippetType

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
 

 func updateSectionCounters()
 {
  
  sectionCounters.removeAll()
  frc.sections?.enumerated().forEach
  { (offset, section) in
   let objects = section.objects?.compactMap{$0 as? BaseSnippet}
   let totalRows = section.numberOfObjects
   
   let hidden = ignoreHiddenSections ? false : (objects?.allSatisfy{$0[groupType]} ?? true)
   
   let key = BaseSnippet.HiddenSectionKey(snippetType: snippetType,
                                          groupType: groupType,
                                          sectionName: section.name)
   
   BaseSnippet.hiddenSections[key] = hidden
   
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
 
 func moveSnippets(at indexPaths: [IndexPath], to destination: IndexPath)
 {
  let destHidden = isHiddenSection(section: destination.section)
  deactivateDelegate()
  moc.persistAndWait(block:
  {
   indexPaths.forEach
   {path in
    let snippet = self[path]
    snippet.snippetPriority = self.sectionPriority(for: destination.section) ?? .normal
    snippet[self.groupType] = destHidden
   }
  })
  {success in
   guard success else { return }
   indexPaths.forEach
   {path in
    self.sectionCounters[path.section].rows -= 1
    self.sectionCounters[destination.section].rows += 1
   }
   
   self.updateEmptySections()
   self.refetch()
   
   
   self.tableView.performBatchUpdates(
   {
    self.tableView.deleteRows(at: indexPaths, with: .fade)
    
//    let insert_ips = Array(repeating: destination, count: indexPaths.count)
//    self.tableView.insertRows(at: insert_ips, with: .automatic)
   })
   {_ in
    if !destHidden { self.tableView.reloadSections(IndexSet(destination), with: .automatic) }
    self.removeEmptySections()
    self.activateDelegate()
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
//   unfoldSection(section: destination.section)
//   {[weak self] in
//    self?.moveBatchUpdate(for: snippet)
//   }
  }
  else
  {
   moveBatchUpdate(for: snippet)
  }


 }


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
  
  do
  {
   let items = try moc.fetch(fetchRequest)
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
     
     if let date = snippet.date
     {
      snippet.dateFormatIndex = DateFormatters.localizedSearchString(for: date as Date)
     }
     
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
   case .bySnippetType:  return localizedSnippetType  (for: index)
   case .plainList:      return Localized.plainList
   
  }
 }
 
 private func sectionName(for index: Int) -> String?
 {
  guard let section = sectionCounters[index].frcSection else { return nil }
  return frc.sections?[section].name
 }
 
 private func normalizedSectionName(for index: Int) -> String?
 {
  if ( groupType == .plainList ) { return "" }
  guard let name = sectionName(for: index) else { return nil }
  guard groupType == .byDateCreated || groupType == .byPriority else { return name }
  
  
  let pos = name.firstIndex(of: "_")
  return String(name.suffix(from: pos!).dropFirst())
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
 
 func sectionPriority (for index: Int) -> SnippetPriority?
 {
  guard let name = sectionName(for: index), let pos = name.firstIndex(of: "_") else {return nil}
  return SnippetPriority(rawValue: String(name.suffix(from: pos).dropFirst()))
 }
 
 private func localizedSnippetType(for index: Int) -> String?
 {
  guard let snippetType = sectionName(for: index) else { return nil }
  return NSLocalizedString(snippetType, comment: snippetType)
 }
 

 
 final func numberOfSections() -> Int
 {
  return sectionCounters.count
 }
 
 
 var isFRCDelegateUpdatingCells = false
 // this flag indicates if the the hidden rows should be taken into account in TV dataSource
 // when TV updates originate from FRC delegate after the MOC updates
 // if TRUE dataSource uses all MO.
 // if FALSE uses only visible rows in other cases.
 
 final func numberOfRowsInSection(index: Int) -> Int
 {
  return (isFRCDelegateUpdatingCells || ignoreHiddenSections) ? allObjects    (for: index).count :
                                                                visibleObjects(for: index).count
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
 

 
 private func allObjects(for section: Int) -> [BaseSnippet]
 {
  guard section < sectionCounters.count else { return [] }
  guard let frcSection = sectionCounters[section].frcSection else { return [] }
  let objects = frc.sections?[frcSection].objects?.compactMap{$0 as? BaseSnippet} ?? []
  return objects
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
  allObjects(for: section).forEach{ $0[groupType] = state }
  sectionCounters[section].hidden = state
  
  if let name = self.sectionName(for: section)
  {
   let key = BaseSnippet.HiddenSectionKey(snippetType: snippetType, groupType: groupType, sectionName: name)
   BaseSnippet.hiddenSections[key] = state
  }
 
  
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
 
 
 final subscript (snippetID: String?) -> BaseSnippet?
 {
  guard let SID = snippetID else { return nil }
  let snippet = items?.first{ $0.id?.uuidString == SID }
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
 
 
 func toggleFoldSection(section: Int, completion: ( (Bool) -> () )? = nil)
 {
  if sectionCounters.isEmpty { return }
  guard section < sectionCounters.count else { return }
  guard sectionCounters[section].rows > 0 else  { return }
  
  var hidden = isHiddenSection(section: section)
  hidden.toggle()
  
  deactivateDelegate()
  moc.persist(block: { self.setAllObjectsVisibleState(for: section, to: hidden) })
  {flag in
   guard flag else { self.activateDelegate();  return }
   let ips = self.sectionIndexPaths(for: section)
   if hidden
   {
    self.tableView.performBatchUpdates({ self.tableView.deleteRows(at: ips , with: .fade) })
    {_ in
     let rect = self.tableView.rect(forSection: section)
     self.tableView.scrollRectToVisible(rect, animated: true)
     self.activateDelegate()
     completion?(hidden)
    }
   }
   else
   {
    self.tableView.performBatchUpdates({ self.tableView.insertRows(at: ips , with: .fade) })
    {_ in
     if self.tableView.cellForRow(at: ips[0]) != nil
     {
      self.tableView.scrollToRow(at: ips[0], at: .top, animated: true)
     }
     self.activateDelegate()
     completion?(hidden)
    }
   }
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
 
 var hiddenRowsIndexPaths: [IndexPath]
 {
  return sectionCounters.enumerated().filter{$0.element.hidden}.flatMap{sectionIndexPaths(for:$0.offset)}
 }
 
 var isHiddenRowsNeeded: Bool
 {
  guard moc.deletedObjects.isEmpty  else { return true }
  guard moc.insertedObjects.isEmpty else { return true }
  
  let updated = moc.updatedObjects.compactMap{$0 as? BaseSnippet}
  
  if updated.isEmpty { return false }
  
  return updated.contains{ $0.isValidForFRCSortDescriptorsChanges }
  
 }
 
 private func insertHiddenRows(completion: ( () -> () )? = nil)
 {

  guard isHiddenRowsNeeded else { return }
  print(#function)
  isFRCDelegateUpdatingCells = true
  tableView.performBatchUpdates({ tableView.insertRows(at: hiddenRowsIndexPaths, with: .automatic) })
  {_ in
   completion?()
  }
 }
 
 private func deleteHiddenRows(completion: ( () -> () )? = nil)
 {
  guard isHiddenRowsNeeded else { return }
  isFRCDelegateUpdatingCells = false
  print(#function)
  tableView.performBatchUpdates({ tableView.deleteRows(at: hiddenRowsIndexPaths, with: .fade) })
  {_ in
   completion?()
  }
 }
 
 func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
 {
  
  if isSearchMode { return }
  
  print (#function)
  frcDidChangeSections = false
  insertHiddenRows()
  tableView.beginUpdates()

  
 }
 

 func updateSnippetCell(at indexPath: IndexPath?)
 {
  guard let indexPath = indexPath else { return }
  guard let cell = tableView.cellForRow(at: indexPath) as? SnippetsViewCell else { return }
  let snippet = frc.object(at: indexPath)
  
  guard  snippet.isValidForChanges else { return }
  
  let keys = snippet.changedValuesForCurrentEvent().keys
  
  if keys.contains(#keyPath(BaseSnippet.tag))        { cell.snippetTextTag.text = snippet.snippetName       }
  if keys.contains(#keyPath(BaseSnippet.date))       { cell.snippetDateTag.text = snippet.snippetDateTag    }
  if keys.contains(#keyPath(BaseSnippet.isSelected))
  {
   cell.isSnippetRowSelected = snippet.isSelected
  }
  if keys.contains(#keyPath(BaseSnippet.isDragAnimating))
  {
   cell.isDragAnimating = snippet.isDragAnimating
  }
  if keys.contains(#keyPath(BaseSnippet.priority))   { cell.priorityView.priority = snippet.snippetPriority }
  if keys.contains(#keyPath(PhotoSnippet.photos))    { cell.reloadIconView() }
  if keys.contains(#keyPath(TextSnippet.text))       { cell.reloadIconView() }
  
 }
 
 
 private var frcDidChangeSections = false
 
 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange anObject: Any, at indexPath: IndexPath?,
                 for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
 {
  
  //print (#function, "from: ", indexPath, "to: ", newIndexPath, "type: ", type.rawValue)
  
  if isSearchMode { return }
  
  guard let snippet = anObject as? BaseSnippet else { return }
  

  defer { updateSectionCounters() }

  switch type
  {
   case .insert:
    guard let insertIndexPath = newIndexPath else { break }
    let section = insertIndexPath.section
    tableView.insertRows(at: [insertIndexPath], with: .fade)
    (tableView.dataSource as? SnippetsViewDataSource)?.insertSnippet(snippet: snippet)
    updateFootersTitle(for: [section])
   
    print("INSERT --> ", #function)
  
   case .update: updateSnippetCell(at: indexPath)
   
    print("UPDATE --> ", #function)
  
   case .delete:
    guard let deleteIndexPath = indexPath else { break }
    let section = deleteIndexPath.section
    tableView.deleteRows(at: [deleteIndexPath], with: .fade)
    (tableView.dataSource as? SnippetsViewDataSource)?.deleteSnippet(snippet: snippet)
    updateFootersTitle(for: [section])
   
    print("DELETE --> " , #function)

   case .move:
    guard let toIndexPath = newIndexPath, let fromIndexPath = indexPath else { break }
    guard frcDidChangeSections || toIndexPath != fromIndexPath else { break }
    let toSection = toIndexPath.section
    let  fromSection = fromIndexPath.section
    tableView.deleteRows(at: [fromIndexPath], with: .fade)
    tableView.insertRows(at: [toIndexPath],   with: .fade)
    updateFootersTitle(for: [toSection, fromSection])
   
    print("MOVE --> from: \(fromIndexPath) to: \(toIndexPath)", #function)
   

  }
  
  
 }

 func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                 didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                 for type: NSFetchedResultsChangeType)
 {

  print (#function)
  
  if isSearchMode { return }
  
  frcDidChangeSections = true
  
  defer { updateSectionCounters() }
  
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
  if isSearchMode { return }
  
  print (#function)
  tableView.endUpdates()
  deleteHiddenRows()
 
 }

}


