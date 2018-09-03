
import Foundation
import UIKit
import CoreData
import CoreLocation


enum GroupSnippets: String
{
  case byPriority     =  "By Snippet Priority"
  case byDateCreated  =  "By Snippet Date Created"
  case alphabetically =  "Alphabetically"
  case bySnippetType  =  "By Snippet Type"
  case plainList      =  "Plain List"
  case byLocation     =  "By Snippet Location"
  case nope           //initial state 
    
  static let groupingTypes: [GroupSnippets] =
  [
   byPriority, byDateCreated, alphabetically, bySnippetType, plainList, byLocation 
  ]
}

class SnippetsViewController: UIViewController
{
    
    var snippetType: SnippetType!
    var createBarButtonIcon: UIImage!
    var createBarButtonTitle: String!
    
    var editedSnippet: BaseSnippet!
    {
       didSet {sourceSnippet = oldValue}
    }
 
    var sourceSnippet: BaseSnippet!
    
    var snippetLocation: CLLocation?
    
    var menuTitle: String!
    {
     didSet {navigationItem.title = menuTitle}
    }
    
    private lazy var appSettings: [Settings] =
    {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
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
            snippetsDataSource.rebuildData()
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
     super.viewDidLoad()   
     navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
     snippetsTableView.delegate = self
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
        
     
     editSnippets.title = "⚒︎"
     editSnippets.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], for: .selected)
     editSnippets.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .normal)
     
     snippetsDataSource.groupType = groupType
     snippetsTableView.dataSource = snippetsDataSource
     currentToolBarItems = snippetsToolBar.items
     snippetsTableView.allowsMultipleSelectionDuringEditing = true
     
     //snippetsTableView.translatesAutoresizingMaskIntoConstraints = false
        
     setLocationPermissions()

    }
 
    func updateSnippets()
    {
     guard snippetType != nil else {return}
     
     createNewSnippet.title = createBarButtonTitle
     createNewSnippet.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], for: .selected)
     createNewSnippet.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)], for: .normal)
     
     snippetsDataSource.itemsType = snippetType
     snippetsDataSource.rebuildData()
     snippetsTableView.reloadData()
    }
 
 
    override func viewWillAppear(_ animated: Bool)
    {
     super.viewWillAppear(animated)
     updateSnippets()
     
     print("NAVIGATION STACK COUNT: \(navigationController!.viewControllers.count)")
    }
 
    override func viewWillDisappear(_ animated: Bool)
    {
     super.viewWillDisappear(animated)
     snippetsDataSource.cancelAllImageLoadTasks()
  
//     snippetsTableView.visibleCells.map{$0 as! SnippetsViewCell}.forEach
//     {
//       $0.isLoadTaskCancelled = true
//     }
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
      switch (snippetType)
      {
        case .text:    createNewTextSnippet()
        case .photo:   createNewPhotoSnippet()
        case .video:   createNewVideoSnippet()
        case .audio:   createNewAudioSnippet()
        case .sketch:  createNewSketchSnippet()
        case .report:  createNewReport()
        default: break
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
     guard let selectedSnippets = snippetsTableView.indexPathsForSelectedRows else
     {
      return
     }
     
     let loc_title = NSLocalizedString(self.snippetType.rawValue, comment: self.snippetType.rawValue)
     let loc_message = NSLocalizedString("Please select your snippet priority!", comment: "Priority Selection Alerts")
     let prioritySelect = UIAlertController(title: loc_title, message: loc_message, preferredStyle: .alert)
        
     for priority in SnippetPriority.priorities
     {
      let loc_pr_title = NSLocalizedString(priority.rawValue, comment: priority.rawValue)
      let action = UIAlertAction(title: loc_pr_title, style: .default)
      { _ in
        self.changeSnippetPriority(self.snippetsTableView, selectedSnippets, priority)
        self.toggleEditMode()
      }
      prioritySelect.addAction(action)
     }
      
     let loc_cnx_title = NSLocalizedString("CANCEL", comment: "Cancel Alert Action")
     let cancelAction = UIAlertAction(title: loc_cnx_title , style: .cancel, handler: nil)
        
     prioritySelect.addAction(cancelAction)
        
     self.present(prioritySelect, animated: true, completion: nil)
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
     let loc_title = NSLocalizedString("Group Snippets", comment: "Group Snippets Alerts Title")
     let loc_message = NSLocalizedString("Please select grouping type", comment: "Group Snippets Alerts Message")
     let groupAC = UIAlertController(title: loc_title, message: loc_message, preferredStyle: .alert)
        
     for grouping in GroupSnippets.groupingTypes
     {
       let loc_gr_title = NSLocalizedString(grouping.rawValue, comment: grouping.rawValue)
       let action = UIAlertAction(title: loc_gr_title, style: .default)
       { _ in
            self.groupType = grouping
       }
      groupAC.addAction(action)
     }
     
     let loc_cnx_title = NSLocalizedString("CANCEL",comment: "Cancel Alert Action")
     let cancel = UIAlertAction(title: loc_cnx_title, style: .cancel, handler: nil)
        
     groupAC.addAction(cancel)
      
     self.present(groupAC, animated: true, completion: nil)
    }
    
    func createNewTextSnippet()
    {
     guard let textSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "TextSnippetVC") as? TextSnippetViewController
     else
     {
      return
     }
     
     textSnippetVC.modalTransitionStyle = .crossDissolve
      
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     let newTextSnippet = TextSnippet(context: moc)

     newTextSnippet.date = Date() as NSDate
     newTextSnippet.id = UUID()
     newTextSnippet.priority = SnippetPriority.normal.rawValue
     newTextSnippet.type = SnippetType.text.rawValue
     newTextSnippet.status = SnippetStatus.new.rawValue
        
     if let location = snippetLocation
     {
       newTextSnippet.logitude = location.coordinate.longitude
       newTextSnippet.latitude = location.coordinate.latitude
     }
     
     getLocationString {location in newTextSnippet.location = location}
        
     textSnippetVC.textSnippet = newTextSnippet
     snippetsDataSource.items.insert(newTextSnippet, at: 0)
     self.navigationController?.pushViewController(textSnippetVC, animated: true)
     
    }
    
    func createNewPhotoSnippet()
    {
     guard let photoSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController
     else
     {
      return
     }
     photoSnippetVC.modalTransitionStyle = .partialCurl
        
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     let newPhotoSnippet = PhotoSnippet(context: moc)

     newPhotoSnippet.date = Date() as NSDate
     let newPhotoSnippetID = UUID()
     newPhotoSnippet.id = newPhotoSnippetID
     newPhotoSnippet.priority = SnippetPriority.normal.rawValue
     newPhotoSnippet.type = SnippetType.photo.rawValue
     newPhotoSnippet.status = SnippetStatus.new.rawValue
    
     let fileManager = FileManager.default
     let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
     let newPhotoSnippetURL = docFolder.appendingPathComponent(newPhotoSnippetID.uuidString)
     do
     {
      try fileManager.createDirectory(at: newPhotoSnippetURL, withIntermediateDirectories: false, attributes: nil)
      print ("PHOTO SNIPPET PHOTOS DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newPhotoSnippetURL.path)")
     }
     catch
     {
      print ("ERROR OCCURED WHEN CREATING PHOTO SNIPPET PHOTOS DIRECTORY: \(error.localizedDescription)")
     }
        
     if let location = snippetLocation
     {
      newPhotoSnippet.logitude = location.coordinate.longitude
      newPhotoSnippet.latitude = location.coordinate.latitude
     }
        
     getLocationString {location in newPhotoSnippet.location = location}
        
     photoSnippetVC.photoSnippet = newPhotoSnippet
     snippetsDataSource.items.insert(newPhotoSnippet, at: 0)
     self.navigationController?.pushViewController(photoSnippetVC, animated: true)
     
    }
    
    func createNewVideoSnippet()
    {
     guard let photoSnippetVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSnippetVC") as? PhotoSnippetViewController
      else
     {
      return
     }
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     let newVideoSnippet = PhotoSnippet(context: moc)
     
     newVideoSnippet.date = Date() as NSDate
     let newVideoSnippetID = UUID()
     newVideoSnippet.id = newVideoSnippetID
     newVideoSnippet.priority = SnippetPriority.normal.rawValue
     newVideoSnippet.type = SnippetType.video.rawValue
     newVideoSnippet.status = SnippetStatus.new.rawValue
     
     let fileManager = FileManager.default
     let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
     let newVideoSnippetURL = docFolder.appendingPathComponent(newVideoSnippetID.uuidString)
     do
     {
      try fileManager.createDirectory(at: newVideoSnippetURL, withIntermediateDirectories: false, attributes: nil)
      print ("VIDEO SNIPPET VIDEO FILES DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newVideoSnippetURL.path)")
     }
     catch
     {
      print ("ERROR OCCURED WHEN CREATING VIDEO SNIPPET VIDEO FILES DIRECTORY: \(error.localizedDescription)")
     }
     
     if let location = snippetLocation
     {
      newVideoSnippet.logitude = location.coordinate.longitude
      newVideoSnippet.latitude = location.coordinate.latitude
     }
     
     getLocationString {location in newVideoSnippet.location = location}
     
     photoSnippetVC.photoSnippet = newVideoSnippet
     snippetsDataSource.items.insert(newVideoSnippet, at: 0)
     self.navigationController?.pushViewController(photoSnippetVC, animated: true)
    }
    
    func createNewAudioSnippet()
    {
    }
    
    func createNewSketchSnippet()
    {
    }
    
    func createNewReport()
    {
    }
    
    
}

