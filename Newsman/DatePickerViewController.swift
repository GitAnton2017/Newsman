
import Foundation
import UIKit

class DatePickerViewController: UIViewController
{
  var editedSnippetTableViewCell: SnippetsViewCell!
 
  var editedSnippet: BaseSnippet!
  {
    didSet
    {
        navigationItem.title = editedSnippet.tag
    }
  }
    
  @IBOutlet var snippetDatePicker: UIDatePicker!
    
  override func viewDidLoad()
  {
    super.viewDidLoad()
    snippetDatePicker.maximumDate = Date()
    snippetDatePicker.minimumDate = Date() - 24 * 60 * 60 * 10
  }
    
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    snippetDatePicker.date = editedSnippet.date! as Date
  }
    
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    editedSnippet.date = snippetDatePicker.date as NSDate
   
    if editedSnippetTableViewCell != nil
    {
     editedSnippetTableViewCell.snippetDateTag.text = SnippetsViewDataSource.dateFormatter.string(from: snippetDatePicker.date)
    }
  }
}
