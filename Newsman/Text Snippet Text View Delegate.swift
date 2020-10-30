//
//  Text Snippet TextView Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 10/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension TextSnippetViewController: UITextViewDelegate
{
 func textViewDidEndEditing(_ textView: UITextView)
 {
  guard textView.text != textSnippet.text else { return }
  
  textSnippet.managedObjectContext?.perform
  {
   self.textSnippet.text = self.textView.text
  }
  
 }
}
