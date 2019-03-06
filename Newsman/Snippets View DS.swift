//
import Foundation
import UIKit
import CoreData
import GameplayKit

class SnippetsViewDataSource: NSObject, UITableViewDataSource
{
 deinit { print("\(self.debugDescription) is destroyed)") }

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
  return NSPredicate(format: "SELF.dateSearchIndex CONTAINS[n] %@", searchString)
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
  return currentFRC.items
 }
 
 
 private func performFetchRequest() -> [BaseSnippet]
 {
  guard itemsType != nil else { return [] }
  let request: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  let predicate = NSPredicate(format: "%K = %@", #keyPath(BaseSnippet.type), itemsType.rawValue)
  request.predicate = predicate
  return (try? moc.fetch(request)) ?? []
 }
 
 
 private lazy var fetchedItems = performFetchRequest()

 var searchedItems: [BaseSnippet] = []
 
 
 
 private func performSearchRequest() -> [BaseSnippet]
 {
  let searchPredicate = searchScopePredicates[itemsType]![searchScopeIndex]
  
  switch itemsType!
  {
   case .text:   return (fetchedItems as! [TextSnippet]).filter{searchPredicate.evaluate(with: $0)}
   case .photo:  fallthrough
   case .video:  return (fetchedItems as! [PhotoSnippet]).filter{searchPredicate.evaluate(with: $0)}
   case .audio:  break
   case .sketch: break
   case .report: break
   default: break
  }
  
  return []
 }

 
 final func reloadSearchData()
 {
  if searchString.isEmpty { return }
  fetchedItems = performFetchRequest()
  searchedItems = performSearchRequest()
  snippetsTableView.reloadData()
 }


 lazy var currentFRC = configueCurrentFRC()

 var isSearchModeEnabled = true //This flag is to prevent double SnippetsTV reload when setting searchString = ""
 

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
