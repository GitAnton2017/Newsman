import Foundation
import UIKit

extension TextSnippetViewController: UITextFieldDelegate
{
 @IBAction func titleTextChanged (_ sender: UITextField)
 {
  self.navigationItem.title = sender.text
 }
 
 func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
 {
  guard reason == .committed else { return }
  
  guard textField.text != textSnippet.snippetName else { return }

  textSnippet.managedObjectContext?.perform
  {
   self.textSnippet.snippetName = textField.text ?? ""
  }

 }
 
 func textField(_ textField: UITextField,
                  shouldChangeCharactersIn range: NSRange,
                  replacementString string: String) -> Bool
 {
  return (textField.text?.count)! <= 50
 }

 
}

