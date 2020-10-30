
import Foundation
import UIKit
import CoreData
import CoreLocation

class SnippetsTableView: UITableView
{
 override func layoutSubviews()
 {
  guard window != nil else { return }
  super.layoutSubviews()
 }
}

class SnippetsViewController: UIViewController, ManagedObjectContextSavable
{
 
 
 var isVisible = false
 override func viewDidAppear(_ animated: Bool)
 {
  super.viewDidAppear(false)
  isVisible = true
  let value = UIInterfaceOrientation.portrait.rawValue
  UIDevice.current.setValue(value, forKey: "orientation")
  UINavigationController.attemptRotationToDeviceOrientation()
 }

 deinit { print("\(self.debugDescription) is destroyed") }
 
 lazy var moc: NSManagedObjectContext =
 {
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let moc = appDelegate.viewContext
  return moc
 }()

 override var prefersStatusBarHidden: Bool { false }
 
 @GeoLocator var currentLocation: CLLocation?

 
 //=================================================================

 @IBOutlet var snippetsToolBar:     UIToolbar!
 @IBOutlet var snippetsTableView:   UITableView!
 @IBOutlet var createNewSnippet:    UIBarButtonItem!
 @IBOutlet var groupSnippets:       UIBarButtonItem!
 @IBOutlet var editSnippets:        UIBarButtonItem!
 @IBOutlet var searchBarButtonItem: UIBarButtonItem!

 //=================================================================

 

 var snippetType: SnippetType!

 var createBarButtonIcon: UIImage!
 var createBarButtonTitle: String!

 var editedSnippetIndexPath: IndexPath?
 var swipedSnippetIndexPath: IndexPath?

 var editedSnippet: BaseSnippet?
 {
  didSet { sourceSnippet = oldValue }
 }

 var sourceSnippet: BaseSnippet?
 
 var snippetLocation: CLLocation?
 
 var menuTitle: String!
 {
  didSet { navigationItem.title = menuTitle }
 }

 
 var groupType: GroupSnippets
 {

  get { return Defaults.groupType(for: snippetType) }
  set
  {
   if groupType != newValue
   {
    Defaults.setGroupType(groupType: newValue, for: snippetType)
    snippetsDataSource.groupType = groupType // fetch with FRC...
   }
  }
 }

 
 var currentToolBarItems: [UIBarButtonItem]!
 
 let snippetsDataSource = SnippetsViewDataSource()

 let locationManager = CLLocationManager()

 override func viewDidLoad()
 {
  additionalSafeAreaInsets = UIEdgeInsets.init(top: 1, left: 0, bottom: 0, right: 0)
  super.viewDidLoad()
  navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
  snippetsTableView.delegate = self
  snippetsTableView.dragDelegate = self
  snippetsTableView.dropDelegate = self
  snippetsTableView.dragInteractionEnabled = true
  
  //Core Location Manager Settings ************************
//  locationManager.delegate = self
//  locationManager.desiredAccuracy = kCLLocationAccuracyBest
//  locationManager.distanceFilter = 20 //meters
  //*******************************************************
  
  
  //snippetsTableView.estimatedRowHeight = 70
  snippetsTableView.rowHeight = 70
  //snippetsTableView.rowHeight = UITableView.automaticDimension
  //createNewSnippet.image = createBarButtonIcon
  
  snippetsTableView.register(SnippetsTableViewHeaderView.self,
                             forHeaderFooterViewReuseIdentifier: SnippetsTableViewHeaderView.reuseID)
  
  snippetsTableView.register(SnippetsTableViewFooterView.self,
                             forHeaderFooterViewReuseIdentifier: SnippetsTableViewFooterView.reuseID)
  
  snippetsTableView.register(HiddenCell.self, forCellReuseIdentifier: HiddenCell.reuseID)
  
  editSnippets.title = "⚒︎"
  editSnippets.setTitleTextAttributes(
   [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28)], for: .selected)
  
  editSnippets.setTitleTextAttributes(
   [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)], for: .normal)
  
  
  snippetsTableView.dataSource = snippetsDataSource
  snippetsDataSource.snippetsTableView = self.snippetsTableView
  snippetsDataSource.snippetsVC = self
  
  currentToolBarItems = snippetsToolBar.items
  snippetsTableView.allowsMultipleSelectionDuringEditing = true
  
  setLocationPermissions()
  configueSearchController()
  updateSnippets()


 }

 func updateSnippets()
 {
  guard snippetType != nil else { return }
 
  createNewSnippet.title = createBarButtonTitle
  
  createNewSnippet.setTitleTextAttributes(
   [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28)], for: .selected)
  
  createNewSnippet.setTitleTextAttributes(
   [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)], for: .normal)
  
  snippetsDataSource.itemsType = snippetType
  snippetsDataSource.groupType = groupType // fetch with FRC...
  let index = Defaults.searchScopeIndex(for: snippetType)
  snippetsDataSource.searchScopeIndex = index
  navigationItem.searchController?.searchBar.selectedScopeButtonIndex = index
  snippetsTableView.reloadData()
 }



 override func viewWillDisappear(_ animated: Bool)
 {
  super.viewWillDisappear(animated)
  isVisible = false
  self.dismiss(animated: true, completion: nil) //Have to dismiss UISearchController to prevent VC ref cycle!!!
  snippetsTableView.visibleCells.forEach
  {
   ($0 as? SnippetsViewCell)?.stopImageProvider()
  }
 }



 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
 {
  super.viewWillTransition(to: size, with: coordinator)
  coordinator.animate(alongsideTransition:
  {ctx in
   self.snippetsTableView.alpha = size.width > size.height ? 0.85 : 1
   self.currentToolBarItems.forEach{$0.tintColor = size.width > size.height ? UIColor.lightGray : UIColor.white}
  }, completion: {_ in })
  
  self.snippetsTableView.setEditing(false, animated: false)

 }

 
 @IBAction func createNewSnippetPress(_ sender: UIBarButtonItem)
 {
   guard let type = snippetType else {return}
  
   editedSnippet = nil
  
   switch type
   {
     case .text:    createSnippet(with: TextSnippetViewController.self, TextSnippet.self, snippetType: type)
     case .photo:   fallthrough
     case .video:   createSnippet(with: PhotoSnippetViewController.self, PhotoSnippet.self, snippetType: type)
     case .audio:   break
     case .sketch:  break
     case .report:  break
     case .undefined: break
   
   }
 }
 
 @objc func deleteSelectedSnippets()
 {
  guard let selectedSnippets = snippetsTableView.indexPathsForSelectedRows else { return }
  deleteSnippet(snippetsTableView, selectedSnippets)
  toggleEditMode()
 }
 
 @objc func changeSelectedSnippetsPriority()
 {
  guard let selectedSnippets = snippetsTableView.indexPathsForSelectedRows else { return }
  
  let ac = SnippetPriority.caseSelectorController(title: snippetType.localizedString,
                                                  message: Localized.prioritySelect,
                                                  style: .alert)
  {
   self.changeSnippetsPriority(self.snippetsTableView, selectedSnippets, $0)
   self.toggleEditMode()
  }
  
  self.presenter.present(ac, animated: true, completion: nil)
 }
 
 func toggleEditMode()
 {
  if snippetsTableView.isEditing
  {
   snippetsTableView.setEditing(false, animated: true)
   snippetsToolBar.setItems(currentToolBarItems, animated: true)
  
   self.searchBarButtonItem.tintColor = UIColor.white
   searchBarButtonItem.isEnabled = true
   
  }
  else
  {
 
   snippetsTableView.setEditing(true, animated: true)
  
   self.searchBarButtonItem.tintColor = UIColor.clear
   searchBarButtonItem.isEnabled = false
  
   let doneItem = UIBarButtonItem(title: "⏎", style: .plain, target: self, action: #selector(editSnippetsPress))
   doneItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28)], for: .selected)
   doneItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)], for: .normal)
   
   let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedSnippets))
   let priorityItem = UIBarButtonItem(title: "⚠︎", style: .plain, target: self, action: #selector(changeSelectedSnippetsPriority))
   priorityItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)], for: .selected)
   priorityItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 33)], for: .normal)
   
   let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
   
   snippetsToolBar.setItems([deleteItem, flexSpace, priorityItem,flexSpace, doneItem], animated: true)
  }
 }
 
 @IBAction func editSnippetsPress(_ sender: UIBarButtonItem) { toggleEditMode() }
 
 @IBAction func groupSnippetsPress(_ sender: UIBarButtonItem)
 {
  let ac = GroupSnippets.caseSelectorController(title: Localized.groupingTitle,
                                                message: Localized.groupingSelect,
                                                style: .alert) {self.groupType = $0}
  
  self.presenter.present(ac, animated: true, completion: nil)
 }
 
 
 

 @IBAction func searchButtonPress(_ sender: UIBarButtonItem)
 {
  
 }
 
 
}

