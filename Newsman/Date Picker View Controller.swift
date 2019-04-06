
import Foundation
import UIKit

class DatePickerViewController: UIViewController
{
 
  var editedSnippet: BaseSnippet!
  {
   didSet { navigationItem.title = editedSnippet.snippetName }
  }
    
  @IBOutlet var snippetDatePicker: UIDatePicker!
 
  @IBAction func dateChanged(_ sender: UIDatePicker, forEvent event: UIEvent)
  {
   guard sender.date != editedSnippet.snippetDate else { return }
   
   editedSnippet.managedObjectContext?.persist
   {
     self.editedSnippet.snippetDate = sender.date
   }
  }
 
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
    
 
}
