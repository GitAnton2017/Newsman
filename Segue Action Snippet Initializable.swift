//
//  Segue Action Snippet Initializable.swift
//  Newsman
//
//  Created by Anton2016 on 21.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

protocol SegueActionSnipppetInitializable
{
 var editedSnippet: BaseSnippet! { get set }
}

extension SegueActionSnipppetInitializable where Self: UIViewController
{
 init?(coder: NSCoder, snippet: BaseSnippet)
 {
  self.init(coder: coder)
  self.editedSnippet = snippet
  self.navigationItem.title = snippet.snippetName
 }
}

