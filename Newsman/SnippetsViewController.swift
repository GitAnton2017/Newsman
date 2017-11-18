
import Foundation
import UIKit
import CoreData

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
     snippetsTableView.dataSource = snippetsDataSource
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
     super.viewWillAppear(animated)
     snippetsTableView.reloadData()
    }
    
    @IBOutlet var createNewSnippet: UIBarButtonItem!
    
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
