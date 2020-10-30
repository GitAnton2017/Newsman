//
//  Drop View Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 09/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

protocol DropViewProvidable: class, UIDropInteractionDelegate
{
 var dropView: UIView { get } //provides drop view lazily for Drop activities.
}

extension DropViewProvidable where Self: UIView
{
 func setDropView(ratio: CGFloat = 0.5) -> UIView
 {
   let dv = UIView()
   
   self.addSubview(dv)
   
   dv.translatesAutoresizingMaskIntoConstraints = false
   
   dv.backgroundColor = UIColor.clear
   NSLayoutConstraint.activate(
    [dv.centerYAnchor.constraint(equalTo: self.centerYAnchor                  ),
     dv.widthAnchor  .constraint(equalTo: self.widthAnchor,  multiplier: ratio),
     dv.heightAnchor .constraint(equalTo: self.heightAnchor, multiplier: ratio),
     dv.centerXAnchor.constraint(equalTo: self.centerXAnchor                  )])
   
   return dv
  }
}

