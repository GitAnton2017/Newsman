
import Foundation
import UIKit
import CoreData


enum GroupSnippets: String
{
  case byPriority     =  "By Snippet Priority"
  case byDateCreated  =  "By Snippet Date Created"
  case alphabetically =  "Alphabetically"
  case bySnippetType  =  "By Snippet Type"
  case plainList      =  "Plain List"
  case nope           //initial state 
    
  static let groupingTypes: [GroupSnippets] =
  [
   byPriority, byDateCreated, alphabetically, bySnippetType, plainList
  ]
}

class SnippetsViewController: UIViewController
{
    var snippetType: SnippetType!
    var createBarButtonIcon: UIImage!
    
    var menuTitle: String!
    {
     didSet
     {
      navigationItem.title = menuTitle
     }
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
    
    private var currentGrouping: GroupSnippets = .nope 
    
    var groupType: GroupSnippets
    {
        get
        {
          if (!appSettings.isEmpty)
          {
            return GroupSnippets(rawValue: appSettings.first!.grouping!)!
          }
          else
          {
            return currentGrouping
          }
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
    
    override func viewDidLoad()
    {
     super.viewDidLoad()   
      
     snippetsTableView.delegate = self
     snippetsTableView.estimatedRowHeight = 70
     snippetsTableView.rowHeight = UITableViewAutomaticDimension
     createNewSnippet.image = createBarButtonIcon
     snippetsDataSource.itemsType = snippetType
     snippetsDataSource.groupType = groupType
     snippetsTableView.dataSource = snippetsDataSource
     currentToolBarItems = snippetsToolBar.items
     snippetsTableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
     super.viewWillAppear(animated)
     snippetsDataSource.rebuildData()
     snippetsTableView.reloadData()
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
     
     let prioritySelect = UIAlertController(title: "\(self.snippetType.rawValue)", message: "Please select your snippet priority!",
     preferredStyle: .alert)
        
     for priority in SnippetPriority.priorities
     {
      let action = UIAlertAction(title: priority.rawValue, style: .default)
      { _ in
        self.changeSnippetPriority(self.snippetsTableView, selectedSnippets, priority)
        self.toggleEditMode()
      }
      prioritySelect.addAction(action)
     }
        
     let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
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
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editSnippetsPress))
        let deleteItem  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedSnippets))
        let priorityItem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(changeSelectedSnippetsPriority))
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
     let groupAC = UIAlertController(title: "Group Snippets", message: "Please select grouping type", preferredStyle: .alert)
        
     for grouping in GroupSnippets.groupingTypes
     {
        let action = UIAlertAction(title: grouping.rawValue, style: .default)
        { _ in
            self.groupType = grouping
        }
        groupAC.addAction(action)
     }
        
     let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
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
     textSnippetVC.modalTransitionStyle = .partialCurl
      
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     let newTextSnippet = TextSnippet(context: moc)
     newTextSnippet.status = SnippetStatus.new.rawValue
     textSnippetVC.textSnippet = newTextSnippet
     snippetsDataSource.items.insert(newTextSnippet, at: 0)
     self.navigationController?.pushViewController(textSnippetVC, animated: true)
     
    }
    
    func createNewPhotoSnippet()
    {
    }
    
    func createNewVideoSnippet()
    {
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
