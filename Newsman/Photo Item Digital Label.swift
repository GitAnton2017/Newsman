//
//  Photo Item Digital Label.swift
//  Newsman
//
//  Created by Anton2016 on 12/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class DigitalLabel:  UILabel
{
 var cardinal: Int?
 {
  didSet { text = cardinal == nil ? "" : String(cardinal!) }
 }
 
 override func drawText(in rect: CGRect)
 {
  guard cardinal != nil else { return }
  super.drawText(in: rect.smallerBy(factor: cardinal! < 10 ? 0.5 : 0.15))
 }
 
 init (with frame: CGRect,
       textColor: UIColor,
       markerColor: UIColor,
       cornerRadius: CGFloat = 0.0,
       cardinal: Int? = nil)
 {
  
  self.cardinal = cardinal
  
  super.init(frame: frame)
  
  self.layer.cornerRadius = cornerRadius
  self.layer.masksToBounds = true
  self.textColor = textColor
  self.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
  self.backgroundColor = markerColor
  self.adjustsFontSizeToFitWidth = true
  self.minimumScaleFactor = 0.05
  self.allowsDefaultTighteningForTruncation = true
  self.baselineAdjustment = .alignCenters
  self.textAlignment = .center
  
  
 }
 
 
 required init?(coder aDecoder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
 
}
