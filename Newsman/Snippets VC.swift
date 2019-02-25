
import Foundation
import UIKit
import CoreData
import CoreLocation

class SnippetsViewController: UIViewController
{
 deinit {
  print("\(self.debugDescription) is destroyed")
 }
    lazy var moc: NSManagedObjectContext =
    {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     return moc
    }()
 
    var snippetType: SnippetType!
 
    var createBarButtonIcon: UIImage!
    var createBarButtonTitle: String!
 
    var editedSnippetIndexPath: IndexPath?
    var swipedSnippetIndexPath: IndexPath?
 
 
 
    var editedSnippet: BaseSnippet?
    {
       didSet {sourceSnippet = oldValue}
    }
 
    var sourceSnippet: BaseSnippet?
    
    var snippetLocation: CLLocation?
    
    var menuTitle: String!
    {
     didSet {navigationItem.title = menuTitle}
    }
    
    private lazy var appSettings: [Settings] =
    {
     let request: NSFetchRequest<Settings> = Settings.fetchRequest()
     
     do
     {
      let settings = try moc.fetch(request)
      return settings
     }
     catch
     {
      return [Settings]()
     }
     
    }()
    
    private var currentGrouping: GroupSnippets = .plainList
    
    var groupType: GroupSnippets
    {
        get
        {
         if let savedGroupingRaw = appSettings.first?.grouping,
            let savedGrouping = GroupSnippets(rawValue: savedGroupingRaw)
          {
            currentGrouping = savedGrouping
          }
         
          return currentGrouping
        }
        set
        {
         if (currentGrouping != newValue)
         {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            currentGrouping = newValue
            snippetsDataSource.groupType = newValue
            //snippetsDataSource.rebuildData()
            snippetsTableView.reloadData()
          
            if (!appSettings.isEmpty)
            {
             appSettings.first!.grouping = currentGrouping.rawValue
            }
            else
            {
             let moc = appDelegate.persistentContainer.viewContext
             let newSettings = Settings(context: moc)
             newSettings.grouping = currentGrouping.rawValue
             appSettings.append(newSettings)
            }
          
            appDelegate.saveContext()
         }
        }
    }
    
    @IBOutlet var snippetsToolBar: UIToolbar!
    
    var currentToolBarItems: [UIBarButtonItem]!
    
    @IBOutlet var snippetsTableView: UITableView!
    
    let snippetsDataSource = SnippetsViewDataSource()
 
    let locationManager = CLLocationManager()

 
    override func viewDidLoad()
    {
     additionalSafeAreaInsets = UIEdgeInsetsMake(1, 0, 0, 0)
     super.viewDidLoad()
     navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
     snippetsTableView.delegate = self
     snippetsTableView.dragDelegate = self
     snippetsTableView.dropDelegate = self
     snippetsTableView.dragInteractionEnabled = true
     
     //Core Location Manager Settings ************************
     locationManager.delegate = self
     locationManager.desiredAccuracy = kCLLocationAccuracyBest
     locationManager.distanceFilter = 20 //meters
     //*******************************************************
     //snippetsTableView.estimatedRowHeight = 70
     snippetsTableView.rowHeight = 70
     //snippetsTableView.rowHeight = UITableViewAutomaticDimension
     //createNewSnippet.image = createBarButtonIcon
     
     snippetsTableView.register(SnippetsTableViewHeaderView.self,
                                forHeaderFooterViewReuseIdentifier: SnippetsTableViewHeaderView.reuseID)
     
     snippetsTableView.register(SnippetsTableViewFooterView.self,
                                forHeaderFooterViewReuseIdentifier: SnippetsTableViewFooterView.reuseID)
     
     snippetsTableView.register(HiddenCell.self, forCellReuseIdentifier: HiddenCell.reuseID)
     
     editSnippets.title = "⚒︎"
     editSnippets.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], for: .selected)
     editSnippets.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .normal)
     
     
     snippetsTableView.dataSource = snippetsDataSource
     snippetsDataSource.snippetsTableView = self.snippetsTableView
     
     currentToolBarItems = snippetsToolBar.items
     snippetsTableView.allowsMultipleSelectionDuringEditing = true
     
     
     
     //snippetsTableView.translatesAutoresizingMaskIntoConstraints = false
        
     setLocationPermissions()
     updateSnippets()

    }
 
    func updateSnippets()
    {
     guard snippetType != nil else {return}
     
     createNewSnippet.title = createBarButtonTitle
     createNewSnippet.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], for: .selected)
     createNewSnippet.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .normal)
     
     snippetsDataSource.itemsType = snippetType
     
//     snippetsDataSource.rebuildData()
     
     snippetsDataSource.groupType = groupType // fetch with FRC...
     
     snippetsTableView.reloadData()
     
    }
 
    override func viewWillAppear(_ animated: Bool)
    {
     super.viewWillAppear(animated)
     
//     if let indexPaths = snippetsTableView.indexPathsForVisibleRows
//     {
//      snippetsTableView.reloadRows(at: indexPaths, with: .automatic)
//     }
     
    
    }
 
    override func viewDidAppear(_ animated: Bool)
    {
     super.viewDidAppear(animated)
    }
 
 
    override func viewWillDisappear(_ animated: Bool)
    {
     super.viewWillDisappear(animated)
     snippetsTableView.visibleCells.forEach{($0 as? SnippetsViewCell)?.stopImageProvider()}
    }
 
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
     super.viewWillTransition(to: size, with: coordinator)
     coordinator.animate(alongsideTransition:
      {ctx in
       self.snippetsTableView.alpha = size.width > size.height ? 0.85 : 1
       self.currentToolBarItems.forEach{$0.tintColor = size.width > size.height ? UIColor.lightGray : UIColor.white}
      },
      completion: nil)
    }
 
    @IBOutlet var createNewSnippet: UIBarButtonItem!
    
    @IBOutlet var groupSnippets: UIBarButtonItem!
    
    @IBOutlet var editSnippets: UIBarButtonItem!
    
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
     guard let selectedSnippets = snippetsTableView.indexPathsForSelectedRows else
     {
       return
     }
     deleteSnippet(snippetsTableView, selectedSnippets)
     toggleEditMode()
    }
    
    @objc func changeSelectedSnippetsPriority()
    {
     guard let selectedSnippets = snippetsTableView.indexPathsForSelectedRows else {return}
     
     let ac = SnippetPriority.caseSelectorController(title: snippetType.localizedString,
                                                     message: Localized.prioritySelect,
                                                     style: .alert)
     {
      self.changeSnippetsPriority(self.snippetsTableView, selectedSnippets, $0)
      self.toggleEditMode()
     }
        
     self.present(ac, animated: true, completion: nil)
    }
    
    func toggleEditMode()
    {
      if snippetsTableView.isEditing
      {
       
        snippetsTableView.setEditing(false, animated: true)
        snippetsToolBar.setItems(currentToolBarItems, animated: true)
      }
      else
      {
       
   
        snippetsTableView.setEditing(true, animated: true)

        let doneItem = UIBarButtonItem(title: "⏎", style: .plain, target: self, action: #selector(editSnippetsPress))
        doneItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], for: .selected)
        doneItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .normal)
        
        let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedSnippets))
        let priorityItem = UIBarButtonItem(title: "⚠︎", style: .plain, target: self, action: #selector(changeSelectedSnippetsPriority))
        priorityItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .selected)
        priorityItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 33)], for: .normal)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        snippetsToolBar.setItems([deleteItem, flexSpace, priorityItem,flexSpace, doneItem], animated: true)
      }
    }
    
    @IBAction func editSnippetsPress(_ sender: UIBarButtonItem)
    {
     toggleEditMode()
    }
    
    @IBAction func groupSnippetsPress(_ sender: UIBarButtonItem)
    {
     let ac = GroupSnippets.caseSelectorController(title: Localized.groupingTitle,
                                                   message: Localized.groupingSelect,
                                                   style: .alert) {self.groupType = $0}
     
     self.present(ac, animated: true, completion: nil)
    }
    
 
    
}

