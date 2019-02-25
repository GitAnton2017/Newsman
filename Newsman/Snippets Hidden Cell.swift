//
//  Snippets Hidden Cell.swift
//  Newsman
//
//  Created by Anton2016 on 23/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class HiddenCell: UITableViewCell
{
 static let reuseID = "snippetsHiddenCell"
 
 override func prepareForReuse() {
  super.prepareForReuse()
  isHidden = true
 }
 
 
 override func awakeFromNib()
 {
  super.awakeFromNib()
  isHidden = true
 }
}
