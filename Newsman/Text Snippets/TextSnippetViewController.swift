
import Foundation
import UIKit
import CoreData

class TextSnippetViewController: UIViewController, NCSnippetsScrollProtocol
{
   let dateFormatter =
   { () -> DateFormatter in
      let df = DateFormatter()
      df.dateStyle = .short
      df.timeStyle = .none
      return df
  
   }()
 
   lazy var moc: NSManagedObjectContext =
    {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let moc = appDelegate.persistentContainer.viewContext
     return moc
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
    
    var textSnippet: TextSnippet! {didSet {navigationItem.title = textSnippet.snippetName}}
 
    weak var currentFRC: SnippetsFetchController?
    
    func saveTextSnippetData()
    {
     moc.persistAndWait
     {
       textSnippet.text = textView.text
       guard let text = textSnippetTitle.text else {return}
       guard text != Localized.unnamedSnippet else {return}
       textSnippet.snippetName = text
     }
    }
    
    @IBAction func saveTextButtonPress(_ sender: UIBarButtonItem)
    {
     saveTextSnippetData()
     if textView.isFirstResponder {textView.resignFirstResponder()}
     if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
    }
    
    @IBAction func clearTextButtonPress(_ sender: UIBarButtonItem) {textView.text = ""}
    
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
     //textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 2, right: 5)
     textView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 2, right: 5)
     textSnippetTitle.inputAccessoryView = textView.inputAccessoryView
     textSnippetTitle.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
     super.viewWillDisappear(animated)
     if textView.isFirstResponder {textView.resignFirstResponder()}
     if textSnippetTitle.isFirstResponder {textSnippetTitle.resignFirstResponder()}
     saveTextSnippetData()
     currentFRC?.tableView.reloadData()
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
     textSnippetTitle.text = (textSnippet.snippetName == Localized.unnamedSnippet ? "" : textSnippet.snippetName)
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
     switch segue.identifier
     {
      case "TextSnippetDatePicker":     (segue.destination as! DatePickerViewController    ).editedSnippet = textSnippet
      case "TextSnippetPriorityPicker": (segue.destination as! PriorityPickerViewController).editedSnippet = textSnippet
      default: break
     }
    }
}


