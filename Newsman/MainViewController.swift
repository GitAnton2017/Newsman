
import UIKit

class MainViewController: UIViewController
{
    @IBOutlet var mainCollectionView : UICollectionView!
    
    let mainViewDataSource = MainViewDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mainCollectionView.dataSource = mainViewDataSource
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
       
    }


}

