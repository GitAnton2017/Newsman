
import UIKit

class MainViewController: UIViewController
{
    @IBOutlet var mainCollectionView : UICollectionView!
    
    let mainViewDataSource = MainViewDataSource()
 
    override var prefersStatusBarHidden: Bool { false }
 
    @IBAction func unwind(_ seg: UIStoryboardSegue)
    {
 
    }
    
    override func viewDidLoad()
    {
     super.viewDidLoad()
     mainCollectionView.dataSource = mainViewDataSource
     navigationItem.backBarButtonItem =
        UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
     if let segueID = segue.identifier, segueID == "DetailPhotoView",
        let indexPath = mainCollectionView.indexPathsForSelectedItems?.first
     {
      (segue.destination as! SnippetsViewController).snippetType = mainViewDataSource.items[indexPath.row].type
      (segue.destination as! SnippetsViewController).menuTitle = mainViewDataSource.items[indexPath.row].title
      (segue.destination as! SnippetsViewController).createBarButtonIcon = mainViewDataSource.items[indexPath.row].tabIcon
      (segue.destination as! SnippetsViewController).createBarButtonTitle = mainViewDataSource.items[indexPath.row].tabTitle
     }
        
    }
    
}

