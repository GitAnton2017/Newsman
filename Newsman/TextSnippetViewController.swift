
import Foundation
import UIKit

class TextSnippetViewController: UIViewController
{
    
    @IBOutlet var saveTextButton: UIBarButtonItem!
    @IBOutlet var clearTextButton: UIBarButtonItem!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textSnippetTitle: UITextField!
    @IBOutlet var textSnippetToolBar: UIToolbar!
    
    var textSnippet: TextSnippet!
    {
        didSet
        {
            navigationItem.title = textSnippet.tag
        }
    }
    
    func saveTextSnippetData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (textSnippet.status == nil || textSnippet.status == SnippetStatus.new.rawValue)
        {
         textSnippet.date = Date() as NSDate
         textSnippet.id = UUID()
         textSnippet.priority = SnippetPriority.normal.rawValue
         textSnippet.type = SnippetType.text.rawValue
         textSnippet.status = SnippetStatus.old.rawValue
        }
        
        textSnippet.text = textView.text
        textSnippet.tag = textSnippetTitle.text
    
        appDelegate.saveContext()

    }
    
    @IBAction func saveTextButtonPress(_ sender: UIBarButtonItem)
    {
        saveTextSnippetData()
        textView.resignFirstResponder()
    }
    
    @IBAction func clearTextButtonPress(_ sender: UIBarButtonItem)
    {
        textView.text = ""
    }
    
    @objc func doneButtonPressed ()
    {
        if textView.isFirstResponder {textView.resignFirstResponder()}
        if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
    }
    
    func createKeyBoardToolBar() -> UIToolbar
    {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textSnippetToolBar.bounds.width, height: 44))
        keyboardToolbar.backgroundColor = textSnippetToolBar.backgroundColor
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        keyboardToolbar.setItems([flexSpace,doneButton,flexSpace], animated: false)
        return keyboardToolbar
       
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textView.inputAccessoryView = createKeyBoardToolBar()
        textSnippetTitle.inputAccessoryView = textView.inputAccessoryView
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        saveTextSnippetData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        textView.text = textSnippet.text
        textSnippetTitle.text = textSnippet.tag
        print ("------------------------->\n" ,#function, textSnippet)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
      if let segueID = segue.identifier, segueID == "DatePicker"
      {
        (segue.destination as! DatePickerViewController).editedSnippet = textSnippet
      }
      if let segueID = segue.identifier, segueID == "PriorityPicker"
      {
        (segue.destination as! PriorityPickerViewController).editedSnippet = textSnippet
      }
      
    }
}


