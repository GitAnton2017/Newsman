import Foundation
import UIKit

class PriorityPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    var editedSnippet: BaseSnippet!
    {
     didSet
     {
      self.navigationItem.title = self.editedSnippet.tag
     }
    }
 
    var editedSnippetRestorationID: String? = nil
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        snippetPriorityPicker.dataSource = self
        snippetPriorityPicker.delegate = self
        
    }
 
    func updateEditedSnippet()
    {
        guard self.editedSnippet != nil else {return}
     
        let priority = SnippetPriority(rawValue: editedSnippet.priority!)!
        snippetPriorityPicker.selectRow(priority.section, inComponent: 0, animated: true)
     
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        updateEditedSnippet()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        let index = snippetPriorityPicker.selectedRow(inComponent: 0)
        editedSnippet.priority = SnippetPriority.priorities[index].rawValue
    }
 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        editedSnippet.priority = SnippetPriority.priorities[row].rawValue
    }
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SnippetPriority.priorities.count
    }
    
    /*func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
      return SnippetPriority.priorities[row].rawValue
    }*/
 
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
      return 50
    }
 
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
      let priority = SnippetPriority.priorities[row]
      let titleColor = SnippetPriority.priorityColorMap[priority]!
      let fontSize: CGFloat = 50
      let font = UIFont.italicSystemFont(ofSize: fontSize)
      let titleAttr =
        [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor: titleColor
            
           
        ]
      return NSAttributedString(string: priority.rawValue, attributes: titleAttr)
    }
 
    @IBOutlet var snippetPriorityPicker: UIPickerView!
    
}

