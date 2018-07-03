
import Foundation
import UIKit

extension PhotoSnippetViewController: UITextFieldDelegate
{
 //---------------------------------------------------------------------------
 @IBAction func titleTextChanged (_ sender: UITextField)
 //---------------------------------------------------------------------------
 {
  self.navigationItem.title = sender.text
 }
 //---------------------------------------------------------------------------
 
 
 //---------------------------------------------------------------------------
 func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
 //---------------------------------------------------------------------------
 {
  //self.navigationItem.title = textField.text! + string
  return (textField.text?.count)! <= 50
 }
 //---------------------------------------------------------------------------
 
 
 
 //MARK: ------------- PREPARING PHOTO SNIPPET TOOLBAR -----------------------
 //---------------------------------------------------------------------------
 func createKeyBoardToolBar() -> UIToolbar
  //---------------------------------------------------------------------------
 {
  let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: photoSnippetToolBar.bounds.width, height: 44))
  keyboardToolbar.backgroundColor = photoSnippetToolBar.backgroundColor
  let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
  keyboardToolbar.setItems([flexSpace,doneButton,flexSpace], animated: false)
  return keyboardToolbar
 }
 //---------------------------------------------------------------------------
 //MARK: -
 
 
}
