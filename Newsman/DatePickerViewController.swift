
import Foundation
import UIKit

class DatePickerViewController: UIViewController
{
 
  var editedSnippet: BaseSnippet!
  {
    didSet
    {
        navigationItem.title = editedSnippet.snippetName
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
    snippetDatePicker.date = editedSnippet.snippetDate
  }
    
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    editedSnippet.snippetDate = snippetDatePicker.date
  }
}
