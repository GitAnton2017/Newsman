import Foundation
import UIKit

extension TextSnippetViewController: UITextFieldDelegate
{
 @IBAction func titleTextChanged (_ sender: UITextField)
 {
  self.navigationItem.title = sender.text
 }
 
 func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
 {
  return (textField.text?.count)! <= 50
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
 
}

