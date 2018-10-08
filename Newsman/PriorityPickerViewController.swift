import Foundation
import UIKit

class PriorityPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
 
    @IBOutlet var snippetPriorityPicker: UIPickerView!
 
    var editedSnippetTableViewCell: SnippetsViewCell!
 
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

      let currentPriority = SnippetPriority(rawValue: editedSnippet.priority!)!
      snippetPriorityPicker.selectRow(currentPriority.section, inComponent: 0, animated: true)
     
    }
    override func viewWillAppear(_ animated: Bool)
    {
      super.viewWillAppear(animated)
      updateEditedSnippet()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
      super.viewWillDisappear(animated)
    }
 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
     
     let selectedPriority = SnippetPriority.priorities[row]
     guard editedSnippet.priority != selectedPriority.rawValue else {return}
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     editedSnippet.priority = selectedPriority.rawValue
     appDelegate.saveContext()
 }
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SnippetPriority.priorities.count
    }
 
 
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
      let titleAttr = [NSAttributedStringKey.font : font,  NSAttributedStringKey.foregroundColor : titleColor]
      return NSAttributedString(string: priority.rawValue, attributes: titleAttr)
    }

    
}

