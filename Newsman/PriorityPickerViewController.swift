import Foundation
import UIKit

class PriorityPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        snippetPriorityPicker.dataSource = self
        snippetPriorityPicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let priority = SnippetPriority(rawValue: editedSnippet.priority!)!
        snippetPriorityPicker.selectRow(priority.section, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        let index = snippetPriorityPicker.selectedRow(inComponent: 0)
        editedSnippet.priority = SnippetPriority.priorities[index].rawValue
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SnippetPriority.priorities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
      return SnippetPriority.priorities[row].rawValue
    }
    
    var editedSnippet: BaseSnippet!
    {
        didSet
        {
            navigationItem.title = editedSnippet.tag
        }
    }
    @IBOutlet var snippetPriorityPicker: UIPickerView!
    
}

