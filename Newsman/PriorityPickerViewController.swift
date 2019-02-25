import Foundation
import UIKit
import CoreData

class PriorityPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
 
 
    @IBOutlet var snippetPriorityPicker: UIPickerView!
 
    var editedSnippet: BaseSnippet!
    {
     didSet
     {
      self.navigationItem.title = self.editedSnippet.snippetName
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
      guard let editedSnippet = self.editedSnippet else {return}
      snippetPriorityPicker.selectRow(editedSnippet.snippetPriorityIndex, inComponent: 0, animated: true)
 
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
     guard editedSnippet.snippetPriority != selectedPriority else {return}
     //editedSnippet.setPriority(to: selectedPriority)
     
     editedSnippet.managedObjectContext?.persistAndWait
     {
       editedSnippet.snippetPriority = selectedPriority
     }
    
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
 
    func pickerView(_ pickerView: UIPickerView,
                      attributedTitleForRow row: Int,
                      forComponent component: Int) -> NSAttributedString?
    {
      let priority = SnippetPriority.priorities[row]
      let titleColor = SnippetPriority.priorityColorMap[priority]!
      let fontSize: CGFloat = 50
      let font = UIFont.italicSystemFont(ofSize: fontSize)
      let titleAttr = [NSAttributedStringKey.font : font,  NSAttributedStringKey.foregroundColor : titleColor]
      let tag = NSLocalizedString(priority.rawValue, comment: priority.rawValue)
      return NSAttributedString(string: tag, attributes: titleAttr)
    }

    
}

