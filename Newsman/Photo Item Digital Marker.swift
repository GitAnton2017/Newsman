//
//  Photo Item Digital Marker.swift
//  Newsman
//
//  Created by Anton2016 on 10/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class DigitalTextView:  UIView
{
 override static var layerClass: AnyClass {return CATextLayer.self}
 
 var textLayer: CATextLayer {return layer as! CATextLayer}
 
 override func layoutSubviews()
 {
  super.layoutSubviews()
  textLayer.fontSize = 0.75 * bounds.height
 }
 
 
 var cardinal: Int?
 {
  didSet
  {
   if let cardinal = cardinal
   {
    textLayer.string = String(cardinal)
   }
   else
   {
    textLayer.string = ""
   }
  }
 }
 
 var textColor: UIColor
 {
  didSet
  {
   textLayer.foregroundColor = textColor.cgColor
  }
 }

 
 init (with frame: CGRect, textColor: UIColor, cardinal: Int? = nil)
 {
  self.textColor = textColor
  self.cardinal = cardinal
  
  super.init(frame: frame)
  
  self.backgroundColor = UIColor.clear
  textLayer.isWrapped = true
  textLayer.needsDisplayOnBoundsChange = true
  textLayer.contentsScale = UIScreen.main.scale
  textLayer.alignmentMode = CATextLayerAlignmentMode.center
  
 }
 
 convenience init()
 {
  self.init(with: .zero, textColor: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1))
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }

}


class DigitalMarkerView: DigitalTextView
{ 
 var markerColor: UIColor
 
 func clear ()
 {
  cardinal = nil
 }
 
 
 init (with frame: CGRect, textColor: UIColor, markerColor: UIColor,
       cornerRadius: CGFloat = 0.0, cardinal: Int? = nil)
 {
  
  self.markerColor = markerColor
  
  super.init(with: frame, textColor: textColor, cardinal: cardinal)
  
  self.backgroundColor = markerColor
  
  self.layer.cornerRadius = cornerRadius
  
  let dtv = DigitalTextView(with: .zero, textColor: textColor, cardinal: cardinal)
  
  addSubview(dtv)
  dtv.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate(
   [
    dtv.centerXAnchor.constraint   (equalTo:  centerXAnchor,    constant:   0),
    dtv.centerYAnchor.constraint   (equalTo:  centerYAnchor,    constant:   0),
    dtv.widthAnchor.constraint     (equalTo:  widthAnchor,      multiplier: 0.75),
    dtv.heightAnchor.constraint    (equalTo:  heightAnchor,     multiplier: 0.75),
    
   ])
  
  
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
}

