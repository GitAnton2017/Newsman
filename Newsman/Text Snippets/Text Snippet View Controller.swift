
import Foundation
import UIKit
import CoreData

class TextSnippetViewController: UIViewController, NCSnippetsScrollProtocol, SnippetsRepresentable
{
 @IBOutlet var saveTextButton: UIBarButtonItem!
 @IBOutlet var clearTextButton: UIBarButtonItem!
 @IBOutlet var textView: UITextView!
 @IBOutlet var textSnippetTitle: UITextField!
 @IBOutlet var textSnippetToolBar: UIToolbar!
 
 static var storyBoardID = "TextSnippetVC"

 weak var currentFRC: SnippetsFetchController?
 {
  didSet { currentSnippet.currentFRC = self.currentFRC }
 }

 var textSnippetRestorationID: String?

 var currentViewController: UIViewController { return self }

 var currentSnippet: BaseSnippet
 {
  get  { return textSnippet }
  set  { textSnippet = newValue as? TextSnippet }
 }

 @IBAction func itemUpBarButtonPress(_ sender: UIBarButtonItem)
 {
  saveTextSnippetData()
  moveToNextSnippet(in: -1)
 }

 @IBAction func itemDownBarButtonPress(_ sender: UIBarButtonItem)
 {
  saveTextSnippetData()
  moveToNextSnippet(in:  1)
 }

 var textSnippet: TextSnippet!
 {
  didSet { navigationItem.title = textSnippet.snippetName }
 }

 func saveTextSnippetData()
 {
  if textView.isFirstResponder { textView.resignFirstResponder() }
  if textSnippetTitle.isFirstResponder { textSnippetTitle.resignFirstResponder() }
  
  guard self.textView.text != self.textSnippet.text ||
        self.textSnippet.snippetName != self.textSnippetTitle.text else { return }
  
  //proceed withcontext saving if we have real changes in one of the text fields...
  
  textSnippet.managedObjectContext?.persist
  {
   self.textSnippet.text = self.textView.text
   self.textSnippet.snippetName = self.textSnippetTitle.text ?? ""
  }
  
 }
 
 @IBAction func saveTextButtonPress(_ sender: UIBarButtonItem)
 {
  saveTextSnippetData()
 }
 
 @IBAction func clearTextButtonPress(_ sender: UIBarButtonItem) { textView.text = "" }
 
 @objc func doneButtonPressed ()
 {
  saveTextSnippetData()
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
  textView.delegate = self
 
 }
 
 override func viewWillDisappear(_ animated: Bool)
 {
  super.viewWillDisappear(animated)
  saveTextSnippetData()
 }

 func updateDateLabel()
 {
  let dateLabel  = UILabel()
  dateLabel.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
  dateLabel.font = UIFont(name: "Avenir", size: 20)
  dateLabel.text = DateFormatters.short.string(from: textSnippet.date! as Date)
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
   case "TextSnippetDatePicker":
    (segue.destination as! DatePickerViewController).editedSnippet = textSnippet
   case "TextSnippetPriorityPicker":
    (segue.destination as! PriorityPickerViewController).editedSnippet = textSnippet
   default: break
  }
 }
 
 
 func createKeyBoardToolBar() -> UIToolbar
 {
  let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textSnippetToolBar.bounds.width, height: 44))
  keyboardToolbar.backgroundColor = textSnippetToolBar.backgroundColor
  let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self, action: #selector(doneButtonPressed))
  
  keyboardToolbar.setItems([flexSpace,doneButton,flexSpace], animated: false)
  
  return keyboardToolbar
 }
}


