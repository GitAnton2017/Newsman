
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
    
    var groupType: GroupSnippets = .plainList
    {
        didSet
        {
         if groupType != oldValue
         {
            snippetsDataSource.groupType = groupType
            snippetsDataSource.rebuildData()
            snippetsTableView.reloadData()
         }
        }
            
    }
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
     super.viewWillAppear(animated)
     snippetsDataSource.rebuildData()
     snippetsTableView.reloadData()
    }
    
    @IBOutlet var createNewSnippet: UIBarButtonItem!
    @IBOutlet var groupSnippets: UIBarButtonItem!
    
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
    
    @IBAction func groupSnippetsPress(_ sender: UIBarButtonItem)
    {
     let groupAC = UIAlertController(title: "Group Snippets", message: "Please select grouping type", preferredStyle: .alert)
     let byPriority = UIAlertAction(title: GroupSnippets.byPriority.rawValue, style: .default)
     { _ in
        self.groupType = .byPriority
     }
     groupAC.addAction(byPriority)
     
     let byDateCreated = UIAlertAction(title: GroupSnippets.byDateCreated.rawValue, style: .default)
     { _ in
        self.groupType = .byDateCreated
     }
     groupAC.addAction(byDateCreated)
        
     let alphabetically = UIAlertAction(title: GroupSnippets.alphabetically.rawValue, style: .default)
     { _ in
        self.groupType = .alphabetically
     }
     groupAC.addAction(alphabetically)
     
     let bySnippetType = UIAlertAction(title: GroupSnippets.bySnippetType.rawValue, style: .default)
     { _ in
       self.groupType = .bySnippetType
     }
     groupAC.addAction(bySnippetType)
    
     let none = UIAlertAction(title: GroupSnippets.plainList.rawValue, style: .default)
     { _ in
        self.groupType = .plainList
     }
     groupAC.addAction(none)
        
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
