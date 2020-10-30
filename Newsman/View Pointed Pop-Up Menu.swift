//
//  ViewPointedMenu.swift
//  Newsman
//
//  Created by Anton2016 on 27.09.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//
//
//import UIKit
//
//class MenuArrowView: UIView
//{
// var widthRatio: CGFloat
// var leftShiftRatio: CGFloat
// var fillColor: UIColor
// 
// init(frame: CGRect = .zero, fillColor: UIColor, widthRatio: CGFloat, leftShiftRatio: CGFloat)
// {
//  self.widthRatio = widthRatio
//  self.leftShiftRatio = leftShiftRatio
//  self.fillColor = fillColor
//  super.init(frame: frame)
//  self.backgroundColor = .clear
//  
// }
// 
// override func draw(_ rect: CGRect)
// {
//  let p1 = CGPoint(x: 0, y: 0)
//  let p2 = CGPoint(x: bounds.width * leftShiftRatio, y: bounds.height)
//  let p3 = CGPoint(x: bounds.width * (leftShiftRatio + widthRatio), y: bounds.height)
//  let arrowPath = UIBezierPath(points: [p1, p2, p3])
//  
//  fillColor.setFill()
//  arrowPath.fill()
// }
// 
// required init?(coder: NSCoder)
// {
//  fatalError("init(coder:) has not been implemented")
// }
// 
//}
//
//class MenuBaseView: UIView
//{
// var fillColor: UIColor
// var cornerRadius: CGFloat
// 
// init(frame: CGRect = .zero, fillColor: UIColor, cornerRadius: CGFloat)
// {
//  self.fillColor = fillColor
//  self.cornerRadius = cornerRadius
//  super.init(frame: frame)
//  self.backgroundColor = .clear
// }
// 
// override func draw(_ rect: CGRect)
// {
//  let rectPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
//  fillColor.setFill()
//  rectPath.fill()
// }
// 
// required init?(coder: NSCoder)
// {
//  fatalError("init(coder:) has not been implemented")
// }
// 
//}
//
//class PointedMenuView: UIView
//{
// var fillColor:      UIColor
// 
// var menuSizeRatio:  CGFloat
// var cornerRadius:   CGFloat
// var arrowWidthRatio:     CGFloat
// var arrowLeftShiftRatio: CGFloat
// 
// init(frame: CGRect,
//      menuSizeRatio:       CGFloat,
//      menuCornerRadius:    CGFloat,
//      arrowWidthRatio:     CGFloat,
//      arrowLeftShiftRatio: CGFloat,
//      fillColor: UIColor)
// {
//  self.menuSizeRatio = menuSizeRatio
//  self.fillColor = fillColor
//  self.cornerRadius = menuCornerRadius
//  self.arrowWidthRatio = arrowWidthRatio
//  self.arrowLeftShiftRatio = arrowLeftShiftRatio
//  
//  super.init(frame: frame)
//  self.backgroundColor = .clear
//  
//  self.translatesAutoresizingMaskIntoConstraints = false
//  
//  let arrowView = MenuArrowView(fillColor: fillColor,
//                                widthRatio: arrowWidthRatio,
//                                leftShiftRatio: arrowLeftShiftRatio)
//  
//  arrowView.translatesAutoresizingMaskIntoConstraints = false
//  
//  self.addSubview(arrowView)
//  
//  let baseView = MenuBaseView(fillColor: fillColor, cornerRadius: menuCornerRadius)
//  
//  baseView.translatesAutoresizingMaskIntoConstraints = false
//  
//  self.addSubview(baseView)
//  
//  NSLayoutConstraint.activate(
//  [
//   arrowView.topAnchor.constraint     (equalTo:  self.topAnchor,
//                                       constant: self.bounds.height/2 ),
//   
//   arrowView.leadingAnchor.constraint (equalTo: self.leadingAnchor,
//                                       constant: self.bounds.width/2  ),
//   
//   arrowView.widthAnchor.constraint   (equalTo: baseView.widthAnchor,
//                                       multiplier: arrowWidthRatio + arrowLeftShiftRatio,
//                                       constant: menuCornerRadius),
//   
//   arrowView.heightAnchor.constraint(equalTo: self.heightAnchor,
//                                     multiplier: 0.5 * (1 - menuSizeRatio),
//                                     constant: 0.0),
//   
//   baseView.topAnchor.constraint(equalTo: arrowView.bottomAnchor,
//                                 constant: 0.0),
//   
//   baseView.leadingAnchor.constraint (equalTo: self.leadingAnchor,
//                                      constant: self.bounds.width/2  ),
//   
//   baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
//   
//   baseView.widthAnchor.constraint(equalTo: baseView.heightAnchor, multiplier: 1.0)
//  ])
// }
// 
// required init?(coder: NSCoder)
// {
//  fatalError("init(coder:) has not been implemented")
// }
// 
// 
//}
