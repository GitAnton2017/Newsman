//
//  Draw Flag Menu Button.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class DrawFlagMenuButton: MenuItemButton
{
 
 
 var fillColor: UIColor
 
 init(frame: CGRect = .zero, fillColor: UIColor, handler: @escaping () -> ())
 {
  self.fillColor = fillColor
  super.init(frame: frame, handler: handler)
  backgroundColor = .clear
 }
 
 override func draw(_ rect: CGRect)
 {
  fillColor.setFill()
  let p1 = CGPoint(x: 0, y: 0)
  let p2 = CGPoint(x: 0, y: bounds.height)
  let p3 = CGPoint(x: bounds.width/2, y: bounds.height * 0.75)
  let p4 = CGPoint(x: bounds.width, y: bounds.height)
  let p5 = CGPoint(x: bounds.width, y: 0)
  let flagDrawPath = UIBezierPath(points: [p1,p2,p3,p4,p5])
  flagDrawPath.fill()
  
  layer.cornerRadius = bounds.width * 0.075
  layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
  layer.masksToBounds = true
  

 }
 
 required init?(coder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
}

