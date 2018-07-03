
import Foundation
import UIKit

class TextSnippetViewController: UIViewController, NCSnippetsScrollProtocol
{
   let dateFormatter =
   { () -> DateFormatter in
      let df = DateFormatter()
      df.dateStyle = .short
      df.timeStyle = .none
      return df
  
   }()
 
   var textSnippetRestorationID: String?
 
   var currentViewController: UIViewController {return self}
 
   var currentSnippet: BaseSnippet {return textSnippet}
 
   @IBAction func itemUpBarButtonPress(_ sender: UIBarButtonItem)
   {
    if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
    saveTextSnippetData()
    moveToNextSnippet(in: -1)
   }
 
   @IBAction func itemDownBarButtonPress(_ sender: UIBarButtonItem)
   {
    if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
    saveTextSnippetData()
    moveToNextSnippet(in: 1)
   }
    
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
        textSnippet.text = textView.text
        textSnippet.tag = textSnippetTitle.text
        appDelegate.saveContext()

    }
    
    @IBAction func saveTextButtonPress(_ sender: UIBarButtonItem)
    {
        saveTextSnippetData()
        if textView.isFirstResponder {textView.resignFirstResponder()}
        if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
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
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: self, action: nil)
        textView.inputAccessoryView = createKeyBoardToolBar()
        textSnippetTitle.inputAccessoryView = textView.inputAccessoryView
        textSnippetTitle.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if textView.isFirstResponder {textView.resignFirstResponder()}
        if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
        saveTextSnippetData()
    }
 
    func updateDateLabel()
    {
        let dateLabel  = UILabel()
        dateLabel.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        dateLabel.font = UIFont(name: "Avenir", size: 20)
        dateLabel.text = dateFormatter.string(from: textSnippet.date! as Date)
        navigationItem.titleView = dateLabel
    }
 
    func updateTextSnippet()
    {
        guard textSnippet != nil else {return}
     
        textView.text = textSnippet.text
        textSnippetTitle.text = textSnippet.tag
     
    }
 
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        updateTextSnippet()
    }
 
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        updateDateLabel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
      if let segueID = segue.identifier, segueID == "TextSnippetDatePicker"
      {
        (segue.destination as! DatePickerViewController).editedSnippet = textSnippet
      }
      if let segueID = segue.identifier, segueID == "TextSnippetPriorityPicker"
      {
        (segue.destination as! PriorityPickerViewController).editedSnippet = textSnippet
      }
      
    }
}


