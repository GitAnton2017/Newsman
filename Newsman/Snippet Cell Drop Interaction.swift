//
//  Snippet Cell Drop Interaction.swift
//  Newsman
//
//  Created by Anton2016 on 23/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell
{
 func configueDropInteraction()
 {
  let dropper = UIDropInteraction(delegate: self)
  dropView.addInteraction(dropper)
 }
}
