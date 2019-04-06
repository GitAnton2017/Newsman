//
import Foundation
import UIKit
import CoreData
import GameplayKit

extension IndexPath
{
 static let zero = IndexPath(row: 0, section: 0)
}

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
 
 var observers = Set<NSObject>()
 
 private func clearAllNotificationObservers()
 {
  print (#function)
  let center = NotificationCenter.default
  observers.forEach { center.removeObserver($0) }
  observers.removeAll()
 }
 
 private func addSnippetsContextObservers()
 {
  print (#function)
  addSnippetsContextDeleteObserver()
  addSnippetsContextInsertObserver()
  addSnippetsContextUpdateObserver()
  
  
 }
 
 
 
 private func configueChangeContextObserver(for changeKey: String,
                                            handler: @escaping ([BaseSnippet]) -> () ) -> NSObject
 {
  let center = NotificationCenter.default
  let queue = OperationQueue.main
  
  let observer = center.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: moc, queue: queue)
  {[unowned self] notification in
   if self.searchString.isEmpty { return }
   guard let userInfo = notification.userInfo else { return }
   guard let changed = userInfo[changeKey] as? Set<NSManagedObject> else { return }
   let changedSnippets = changed.compactMap{$0 as? BaseSnippet}
   if changedSnippets.isEmpty { return }
   handler(changedSnippets)
  }
  
  return observer as! NSObject
 }
 
 private func refreshFooterView(for section: Int)
 {
  let footer = snippetsTableView.footerView(forSection: section) as? SnippetsTableViewFooterView
  let NRows = totalNumberOfRowsInSection(index: section)
  footer?.title = Localized.totalSnippets + String(NRows)
 }
 
 
 private func addSnippetsContextDeleteObserver()
 //sets .NSManagedObjectContextObjectsDidChange observer for NSDeletedObjectsKey that is for
 // processing deleting proper objects from searchedItems MO array & fechedItems MO array
 {
  print (#function)
  let observer = configueChangeContextObserver(for: NSDeletedObjectsKey)
  {[unowned self] deleted in
   let searchIndexes = deleted.compactMap{ s in self.searchedItems.index{$0 === s} }.sorted(by: >)
   //delete them in row index descending order to keep up deletion integrity
   
   searchIndexes.forEach{ self.searchedItems.remove(at: $0) }

   //remove MOs that deleted from current MOC from fetchedItems as well!
   let fetchIndexes = deleted.compactMap{ s in self.fetchedItems.index{$0 === s} }.sorted(by: >)
   fetchIndexes.forEach{ self.fetchedItems.remove(at: $0) }

   let indexPaths = searchIndexes.map{ IndexPath(row: $0, section: 0) }
   
   //perform visial TV batch deletion in one single animation...
   self.snippetsTableView.performBatchUpdates(
   {
    self.snippetsTableView.deleteRows(at: indexPaths, with: .fade)
   })
   {_ in
    self.refreshFooterView(for: 0)
   }
  }
  
  observers.insert(observer)
 }
 
 
 private func refreshRowsAfterSorting()
 //updates the TV if sorting order with the given set of sort descriptors changes when MO NSUpdatedObjectsKey
 //event fires within the .NSManagedObjectContextObjectsDidChange notification
 {
  let sortedToUpdate = NSArray(array: searchedItems).sortedArray(using: currentSortDescriptors) as! [BaseSnippet]
  
  guard self.searchedItems != sortedToUpdate else { return } // checks if sorting order actually changed?!
  
  //Prepares FROM-TO IndexPath pairs array for move batch updates below...
  let moves = searchedItems.enumerated().map
  {pair -> (from: IndexPath, to: IndexPath) in
   let from_ip = IndexPath(row: pair.offset, section: 0)
   let index = sortedToUpdate.index{ $0 === pair.element }
   let to_ip = IndexPath(row: index!, section: 0)
   return (from: from_ip, to: to_ip)
  }
  
  searchedItems = sortedToUpdate // then we set new model array with new sort order and finally...
  
  
  snippetsTableView.performBatchUpdates(
  {
   moves.forEach { self.snippetsTableView.moveRow(at: $0.from, to: $0.to) }
  })
  
 }
 
 private func addSnippetsContextUpdateObserver()
 //sets .NSManagedObjectContextObjectsDidChange observer for NSUpdatedObjectsKey that is for
 // processing updates of proper objects from searchedItems MO array only!
 {
  print (#function)
  let observer = configueChangeContextObserver(for: NSUpdatedObjectsKey)
  {[unowned self] updated in
   //filter out all updated all MOs contained in this searchedItems that do not satisfy current predicates
   let indexesToDelete = updated.compactMap
   { s in
    self.searchedItems.index{$0 === s && !self.evaluate(snippet: $0)}
   }.sorted(by: >) //delete them in row index descending order to keep up model integrity
   
   let deleteIndexPaths = indexesToDelete.map{IndexPath(row: $0, section: 0)}
   
   indexesToDelete.forEach{ self.searchedItems.remove(at: $0) } //first delete them from searchedItems
   
   let evaluatedObjects = updated.filter { $0.isValidForChanges && self.evaluate(snippet: $0) }
   //then filter out all updated MOs that do satisfy current predicates with only needed changed #keyPathes!
   
   //then insert newly created objects that turned out to satisfy current set of predicates after editing
   let objectsToInsert = evaluatedObjects.filter{ !self.searchedItems.contains($0) }
   self.searchedItems.insert(contentsOf: objectsToInsert, at: 0)
   let insertIndexPaths = Array<IndexPath>(repeating: .zero, count: objectsToInsert.count)
   
   // then we  prepare indexPathes for MOs to update their data fields
   let indexesToUpdate = evaluatedObjects.compactMap{ s in self.searchedItems.index {$0 === s} }
   let updateIndexPaths = indexesToUpdate.map{IndexPath(row: $0, section: 0)}
   
   self.updateSnippetCells(at: updateIndexPaths) //updates visual fields in corresponding TV cells
   //whiout reloading whole cells
   
   //perform visual TV batch update of rows in one single animation...
   self.snippetsTableView.performBatchUpdates(
   {
    self.snippetsTableView.deleteRows(at: deleteIndexPaths, with: .fade)
    self.snippetsTableView.insertRows(at: insertIndexPaths, with: .automatic)
   })
   {_ in
    self.refreshFooterView(for: 0) //update total rows
    self.refreshRowsAfterSorting() //refresh with applied sort descriptors!
 
   }
  }
  
  observers.insert(observer)
 }
 
 func updateSnippetCell(at indexPath: IndexPath)
 {
  guard let cell = snippetsTableView.cellForRow(at: indexPath) as? SnippetsViewCell else { return }
  let snippet = self[indexPath]
  let keys = snippet.changedValuesForCurrentEvent().keys
  
  if keys.contains(#keyPath(BaseSnippet.tag))        { cell.snippetTextTag.text = snippet.snippetName       }
  if keys.contains(#keyPath(BaseSnippet.date))       { cell.snippetDateTag.text = snippet.snippetDateTag    }
  if keys.contains(#keyPath(BaseSnippet.isSelected)) { cell.isSnippetRowSelected = snippet.isSelected       }
  if keys.contains(#keyPath(BaseSnippet.isDragAnimating))
  {
   cell.isDragAnimating = snippet.isDragAnimating
  }
  if keys.contains(#keyPath(BaseSnippet.priority))   { cell.priorityView.priority = snippet.snippetPriority }
  if keys.contains(#keyPath(PhotoSnippet.photos))    { cell.reloadIconView() }
  if keys.contains(#keyPath(TextSnippet.text))       { cell.reloadIconView() }
 }
 
 func updateSnippetCells(at indexPaths: [IndexPath])
 {
  indexPaths.forEach{ updateSnippetCell(at: $0)}
 }
 
 private func addSnippetsContextInsertObserver()
 //sets .NSManagedObjectContextObjectsDidChange observer for NSInsertedObjectsKey that is for
 // processing newly created proper objects and adding them to searchedItems MO array and fetched ones!
 {
  print (#function)
  let observer = configueChangeContextObserver(for: NSInsertedObjectsKey)
  {[unowned self] inserted in
   
   self.fetchedItems.append(contentsOf: inserted) //firstly add newly crerated MOs to fetchedItems!
   
   let objectsToInsert = inserted.filter //then filter out newly inserted MOs that satisfy current predicates
   {
    self.evaluate(snippet: $0)
   }
   
   if objectsToInsert.isEmpty { return } //no object to insert into TV with applied filter we return!
   
   //insert newly created objects that turned out to satisfy current set of predicates after creation
   self.searchedItems.insert(contentsOf: objectsToInsert, at: 0) // insert all at the head of searchedItems
   let insertIndexPaths = Array<IndexPath>(repeating: .zero, count: objectsToInsert.count)
   
   //perform visial TV batch update of rows in one single animation...
   self.snippetsTableView.performBatchUpdates(
   {
    self.snippetsTableView.insertRows(at: insertIndexPaths, with: .automatic)
   })
   {_ in
    self.refreshFooterView(for: 0) //update total rows
    self.refreshRowsAfterSorting() //refresh with applied sort descriptors!
    
   }
   
  }
  
  observers.insert(observer)
 }
 
 
 
 override init ()
 {
  super.init()
  addSnippetsContextObservers()
 }
 
 deinit
 {
  print("\(self.debugDescription) is destroyed)")
  clearAllNotificationObservers()
 }

 lazy var moc: NSManagedObjectContext =
  {
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
   let moc = appDelegate.persistentContainer.viewContext
   return moc
 }()


 weak var snippetsTableView: UITableView!
 weak var snippetsVC: SnippetsViewController!

 var itemsType: SnippetType!

 var nameScopePredicate: NSPredicate
 {
  return NSPredicate(format: "SELF.snippetName CONTAINS[n] %@", searchString)
 }

 
 var dateScopePredicate: NSPredicate
 {
  //return NSPredicate(value: false)
  return NSPredicate(format: "SELF.dateFormatIndex CONTAINS[n] %@", searchString)
 }
 

 var priorityScopePredicate: NSPredicate
 {
  return NSPredicate(format: "SELF.localizedPriority CONTAINS[n] %@", searchString)
 }
 

 var textScopePredicate: NSPredicate
 {
  return NSPredicate(format: "SELF.text CONTAINS[n] %@", searchString)
 }
 

 var locationScopePredicate: NSPredicate
 {
  return NSPredicate(format: "SELF.snippetLocation CONTAINS[n] %@", searchString)
 }
 

 var baseOverallScopePredicate: NSCompoundPredicate
 {
  return NSCompoundPredicate(orPredicateWithSubpredicates: [
    nameScopePredicate, dateScopePredicate,
    priorityScopePredicate, locationScopePredicate])
 }

 var textOverallScopePredicate: NSCompoundPredicate
 {
  return NSCompoundPredicate(orPredicateWithSubpredicates: [baseOverallScopePredicate,  textScopePredicate])
 }

 
 var baseScopePredicates: [NSPredicate]
 {
  return [nameScopePredicate,        /* searchScopeIndex = 1 */
          dateScopePredicate,        /* searchScopeIndex = 2 */
          priorityScopePredicate,    /* searchScopeIndex = 3 */
          locationScopePredicate     /* searchScopeIndex = 4 */ ]
 }
 
 var allTypesScopePredicates: [NSPredicate]
 {
  return [baseOverallScopePredicate] + /* searchScopeIndex = 0 */
          baseScopePredicates          /* searchScopeIndex = 1...4 */
 }
 
 
 var textTypeSearchScopePredicate: [NSPredicate]
 {
  return [textOverallScopePredicate] + /* searchScopeIndex = 0 */
         baseScopePredicates +         /* searchScopeIndex = 1...4 */
         [textScopePredicate]          /* searchScopeIndex = 5 */
 }
 

 var searchScopePredicates : [SnippetType : [NSPredicate]]
 {
  return [
   .text   : textTypeSearchScopePredicate,
   .photo  : allTypesScopePredicates,
   .video  : allTypesScopePredicates,
   .audio  : allTypesScopePredicates,
   .sketch : allTypesScopePredicates,
   .report : allTypesScopePredicates
  ]
  
 }

 var currentSearchPredicate: NSPredicate
 {
  return searchScopePredicates[itemsType]![searchScopeIndex]
 }
 
 var currentSortDescriptors: [NSSortDescriptor]
 {
  return itemsType!.scopeSearchSortDescriptors[searchScopeIndex]
  
 }


 func configueCurrentFRC() -> SnippetsFetchController
 {

  let predicate = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
  return SnippetsFetchController(with: snippetsTableView,
                                 groupType: groupType,
                                 using: predicate,
                                 in: moc, snippetType: itemsType)

 }


 func configueSearchFRC() -> SnippetsFetchController
 {
  
  let typePredicate = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
  let searchPredicate = NSPredicate(format: "SELF.tag CONTAINS[n] %@", searchString)
  let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, searchPredicate])
  let sfc = SnippetsFetchController(with: snippetsTableView,
                                    groupType: .plainList,
                                    using: predicate,
                                    in: moc, snippetType: itemsType)
  sfc.ignoreHiddenSections = true
  return sfc
  
 }


 var items: [BaseSnippet]?
 {
  return searchString.isEmpty ? currentFRC.items : searchedItems
 }
 
 
 private func performFetchRequest() -> [BaseSnippet]
 {
  guard itemsType != nil else { return [] }
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  let predicate = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
  request.predicate = predicate
  //request.sortDescriptors = [Sort.byTagAsc, Sort.byDateDes, Sort.byPriorityAsc]
  return (try? moc.fetch(request)) ?? []
 }
 
 
 private var isFetched = false
 private lazy var fetchedItems =
 { () -> [BaseSnippet] in
  isFetched = true
  return performFetchRequest()
 }() //once fetched snippets from MOC.
 
 func deleteSnippet(snippet: BaseSnippet)
 {
  guard isFetched else { return }
  guard let index = fetchedItems.index(where: {$0 === snippet}) else { return }
  fetchedItems.remove(at: index)
 }

 func insertSnippet(snippet: BaseSnippet)
 {
  guard isFetched else { return }
  fetchedItems.append(snippet)
 }
 
 
 var searchedItems: [BaseSnippet] = [] //current filtered out snippets
 
 private func evaluate(snippet: BaseSnippet) -> Bool
 {//evaluates the current set of predicates for snippet with proper type
  switch itemsType!
  {
   case .text:   return currentSearchPredicate.evaluate(with: snippet as! TextSnippet)
   case .photo:  fallthrough
   case .video:  return currentSearchPredicate.evaluate(with: snippet as! PhotoSnippet)
   case .audio:  break
   case .sketch: break
   case .report: break
   default: break
  }
  
  return false
 }
 
 private func performSearchRequest() -> [BaseSnippet]
 { //filter out from all fetched snippets the ones that satisfy the current set of predicates
  
  var filtered = [BaseSnippet]()
  
  switch itemsType!
  {
   case .text:   filtered = (fetchedItems as! [TextSnippet ]).filter{currentSearchPredicate.evaluate(with: $0)}
   case .photo:  fallthrough
   case .video:  filtered = (fetchedItems as! [PhotoSnippet]).filter{currentSearchPredicate.evaluate(with: $0)}
   case .audio:  break
   case .sketch: break
   case .report: break
   default: break
  }
  
  return NSArray(array: filtered).sortedArray(using: currentSortDescriptors) as! [BaseSnippet]
 }

 
 final func reloadSearchData()
 {
  if searchString.isEmpty { return }
  fetchedItems = performFetchRequest()
  searchedItems = performSearchRequest()
  snippetsTableView.reloadData()
 }


 lazy var currentFRC = configueCurrentFRC()

 var isSearchModeEnabled = true
 //This flag is to prevent double SnippetsTV reload when setting searchString = ""
 

 var searchScopeIndex: Int = 0
 {
  didSet
  {
   if searchString.isEmpty { return }
   guard oldValue != searchScopeIndex else { return }
   searchedItems = performSearchRequest()
   snippetsTableView.reloadData()
  }
 }
 

 var searchString: String = ""
 {
  didSet
  {
   guard isSearchModeEnabled else { return }
   guard oldValue != searchString else { return }
   
   if searchString == ""
   {
    NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: itemsType.rawValue)
    currentFRC.fetch()
    currentFRC.isSearchMode = false
   }
   else
   {
    currentFRC.isSearchMode = true
    searchedItems = performSearchRequest()
   }
   
   snippetsTableView.reloadData()
  }
 }


 private func updateCurrentFRC()
 {
  NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: itemsType.rawValue)
  isSearchModeEnabled = false
  searchString = ""
  snippetsVC.navigationItem.searchController?.searchBar.text = ""
  isSearchModeEnabled = true
  currentFRC = self.configueCurrentFRC()
  currentFRC.fetch()
  snippetsTableView.reloadData()
 }



 var groupType: GroupSnippets!
 {
  didSet
  {
   if oldValue == nil { currentFRC.fetch() }
   else if let groupType = self.groupType, groupType != oldValue
   {
    if searchString.isEmpty { updateCurrentFRC() }
    else
    {
     snippetsVC.dismiss(animated: true) { self.updateCurrentFRC() }
    }
   }
  }
 }


 final subscript(indexPath: IndexPath) -> BaseSnippet
 {
  guard searchString.isEmpty else { return searchedItems[indexPath.row] }
  return currentFRC[indexPath]
 }
 
 final subscript(indexPaths: [IndexPath]) -> [BaseSnippet]
 {
  guard searchString.isEmpty else { return indexPaths.map{searchedItems[$0.row]} }
  return indexPaths.map{currentFRC[$0]}
 }
 
 
 final subscript(snippetID: String?) -> BaseSnippet?
 {
  guard let SID = snippetID else { return nil }
  guard searchString.isEmpty else { return searchedItems.first{$0.id?.uuidString == SID} }
  return currentFRC[SID]
 }
 
 final subscript(snippet: BaseSnippet) -> IndexPath?
 {
  if searchString.isEmpty { return currentFRC[snippet] }
  guard let row = searchedItems.index(of: snippet) else { return nil }
  return IndexPath(row: row, section: 0)
  
 }

 
 
 final func totalNumberOfRowsInSection(index: Int) -> Int
 {
  guard searchString.isEmpty else { return searchedItems.count }
  return currentFRC.totalNumberOfRowsInSection(index:index)
 }
 
 

 final func isHiddenSection(section: Int) -> Bool
 {
  guard searchString.isEmpty else { return false }
  return currentFRC.isHiddenSection(section: section)
 }
 
 

 final func isDisclosedCell(for indexPath: IndexPath) -> Bool
 {
  return self[indexPath].disclosedCell
 }
 
 

 final func sectionTitle (for index: Int) -> String?
 {
  return currentFRC.sectionTitle(for: index)
 }
 
 final func sectionPriority (for index: Int) -> SnippetPriority?
 {
  guard searchString.isEmpty else { return nil }
  return currentFRC.sectionPriority(for: index)
 }

 func numberOfSections(in tableView: UITableView) -> Int
 {
  guard itemsType != nil else { return 0 }
  guard searchString.isEmpty else { return 1 }

  return currentFRC.numberOfSections()
 }
 
 

 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
 {
  guard searchString.isEmpty else { return searchedItems.count }
  return currentFRC.numberOfRowsInSection(index: section)
 }



 private func configueGroupCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
 {
  if currentFRC.isHiddenSection(section: indexPath.section)
  {
   let cell = tableView.dequeueReusableCell(withIdentifier: HiddenCell.reuseID, for: indexPath)
   return cell
  }
  
  let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath) as! SnippetsViewCell
  cell.hostedSnippet = currentFRC[indexPath] as? SnippetImagesPreviewProvidable
  return cell
 }



 private func configueSearchCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
 {
  let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath) as! SnippetsViewCell
  cell.hostedSnippet = searchedItems[indexPath.row] as? SnippetImagesPreviewProvidable
  return cell
 }
 


 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
 {
  guard searchString.isEmpty else { return configueSearchCell(tableView, indexPath: indexPath) }
  return configueGroupCell(tableView, indexPath: indexPath)
 }
 


 func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
 {
  return groupType == .byPriority
 }
 
}
