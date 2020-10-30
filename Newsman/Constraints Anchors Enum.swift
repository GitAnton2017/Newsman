//
//  Constraints Anchors.swift
//  Newsman
//
//  Created by Anton2016 on 20.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

protocol CALayerCornerRadiusObservable where Self: UIView
{
 var cornerRadiusObservation: AnyCancellable? { get set }
}


extension UIEdgeInsets
{
 var anchors: Set<Anchors>
 {
  [.top(top), .bottom(-bottom), .trailing(-right), .leading(left)]
 }
 
 static func equal(by: CGFloat) -> Self
 {
  Self(top: by, left: by, bottom: by, right: by)
 }
 
 static func equallyAnchored(by: CGFloat) -> Set<Anchors>
 {
  equal(by: by).anchors
 }
}

indirect enum Anchors: Hashable
{
 case top     (_ const: CGFloat = 0, _ to: Anchors? = nil,  _ multiplier: CGFloat = 1)
 case bottom  (_ const: CGFloat = 0, _ to: Anchors? = nil,  _ multiplier: CGFloat = 1)
 case leading (_ const: CGFloat = 0, _ to: Anchors? = nil,  _ multiplier: CGFloat = 1)
 case trailing(_ const: CGFloat = 0, _ to: Anchors? = nil,  _ multiplier: CGFloat = 1)
 
 case width   (_ const: CGFloat = 0)
 case widthR  (_ ratio: CGFloat = 1)
 
 case height  (_ const: CGFloat = 0)
 case heightR (_ ratio: CGFloat = 1)

 case aspect  (_ ratio: CGFloat = 1)
 
 case cornerRadius (_ ratio: CGFloat = 1)
 
 case centerX (_ const: CGFloat = 0,  _ to: Anchors? = nil,  _ multiplier: CGFloat = 1 )
 case centerY (_ const: CGFloat = 0,  _ to: Anchors? = nil,  _ multiplier: CGFloat = 1 )
 
 
 static func centerXYConstrained(view: UIView, shift: CGPoint = .zero, width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .centerX(shift.x), .centerY(shift.y), .width(width), .height(height))
 }
 
 static func centerXYConstrained(view: UIView?,
                                shift: CGPoint = .zero, widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .centerX(shift.x), .centerY(shift.y), .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func topCenterXConstrained(view: UIView?,
                                   shiftX: CGFloat = 0, top: CGFloat = 0,
                                   width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .centerX(shiftX), .top(top), .width(width), .height(height))
 }
 
 static func topCenterXConstrained(view: UIView?,
                                   shiftX: CGFloat = 0, top: CGFloat = 0,
                                   widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .centerX(shiftX), .top(top), .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func topTrailingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                        widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .trailing(shift.x, .centerX()), .top(shift.y, .centerY()),
            .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func CenterToTopTrailingConstrained(view: UIView?, shift: CGPoint = .zero,
                                            widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .centerX(shift.x, trailing()), .centerY(shift.y, .top()),
            .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func topTrailingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                            width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .trailing(shift.x, .centerX()), .top(shift.y, .centerY()),
            .width(width), .height(height))
 }
 
 
 static func CenterToTopTrailingConstrained(view: UIView?, shift: CGPoint = .zero,
                                            width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .centerX(shift.x, trailing()), .centerY(shift.y, .top()),
            .width(width), .height(height))
 }
 
 static func topLeadingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                            widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .leading(shift.x, .centerX()), .top(shift.y, .centerY()),
            .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func topLeadingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                            width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .leading(shift.x, .centerX()), .top(shift.y, .centerY()),
            .width(width), .height(height))
 }
 
 static func bottomLeadingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                              widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .leading(shift.x, .centerX()), .bottom(shift.y, .centerY()),
            .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func bottomLeadingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                              width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .leading(shift.x, .centerX()), .bottom(shift.y, .centerY()),
            .width(width), .height(height))
 }
 
 static func bottomTrailingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                               widthRatio: CGFloat = 1, heightRatio: CGFloat = 1)
 {
  constrain(view: view, with: .trailing(shift.x, .centerX()), .bottom(shift.y, .centerY()),
            .widthR(widthRatio), .heightR(heightRatio))
 }
 
 static func bottomTrailingToCenterConstrained(view: UIView?, shift: CGPoint = .zero,
                                               width: CGFloat, height: CGFloat)
 {
  constrain(view: view, with: .trailing(shift.x, .centerX()), .bottom(shift.y, .centerY()),
            .width(width), .height(height))
 }
 
 static func centerAspectConstrained(view: UIView?, shift: CGPoint = .zero,
                                     widthRatio: CGFloat = 1,
                                     aspectRatio: CGFloat = 1)
 {
  constrain(view: view, with: .centerX(shift.x), .centerY(shift.y), .widthR(widthRatio), .aspect(aspectRatio))
 }
 
 static func centerAspectConstrained(view: UIView?, shift: CGPoint = .zero, heightRatio: CGFloat = 1,
                                    aspectRatio: CGFloat = 1)
 {
  constrain(view: view, with: .centerX(shift.x), .centerY(shift.y), .widthR(heightRatio), .aspect(aspectRatio))
 }
 
 static func edgeConstrained(view: UIView?, top: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0,
                             leading: CGFloat = 0)
 {
  constrain(view: view, with: .top(top), .bottom(bottom), .trailing(trailing), .leading(leading))
 }
 
 static func edgeConstrained(view: UIView?, with ins: UIEdgeInsets = .zero)
 {
  constrain(view: view, with: .top(ins.top), .bottom(-ins.bottom), .trailing(ins.left), .leading(-ins.right))
 }
 
 static func equallyEdgeConstrained(view: UIView?, with inset: CGFloat)
 {
  edgeConstrained(view: view, with: .equal(by: inset))
 }
 
 static func constrain(view: UIView?, with anchors: Self...)
 {
  guard let view = view else { return }
  view.translatesAutoresizingMaskIntoConstraints = false
  anchors.forEach{ $0.constrain(view: view) }
 }
 
 static func constrain(view: UIView?, with anchors: [Self])
 {
  guard let view = view else { return }
  view.translatesAutoresizingMaskIntoConstraints = false
  anchors.forEach{ $0.constrain(view: view) }
 }
 
 static func constrain(view: UIView?, with anchors: Set<Self>)
 {
  guard let view = view else { return }
  view.translatesAutoresizingMaskIntoConstraints = false
  anchors.forEach{ $0.constrain(view: view) }
 }
 
 
 func constrain(view: UIView)
 {
  guard let superview = view.superview else { return }
  
  switch self
  {
   case let .top(const, nil, 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .top &&
                                             $0.secondAttribute == .top })
    { c.constant = const; return }
    
    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: const).isActive = true

   case let .top(const, .centerY(cc, nil, 1), 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .top &&
                                             $0.secondAttribute == .centerY })
    { c.constant = const + cc; return }
   
    view.topAnchor.constraint(equalTo: superview.centerYAnchor, constant: const).isActive = true
   
   
   case let .bottom(const, nil, 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .bottom &&
                                             $0.secondAttribute == .bottom })
    { c.constant = const; return }
    
    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: const).isActive = true
   
   case let .bottom(const, .centerY(cc, nil, 1), 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .bottom &&
                                             $0.secondAttribute == .centerY })
    { c.constant = const + cc; return }
    
    view.bottomAnchor.constraint(equalTo: superview.centerYAnchor, constant: const).isActive = true
   
   
   
   case let .leading(const, nil, 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .leading &&
                                             $0.secondAttribute == .leading })
    { c.constant = const; return }
    
    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: const).isActive = true
   
   case let .leading(const, .centerX(cc, nil, 1), 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .leading &&
                                             $0.secondAttribute == .centerX })
    { c.constant = const + cc; return }
    
    view.leadingAnchor.constraint(equalTo: superview.centerXAnchor, constant: const).isActive = true
   
   case let .trailing(const, nil, 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .trailing &&
                                             $0.secondAttribute == .trailing })
    { c.constant = const; return }
    
    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: const).isActive = true
   
   case let .trailing(const, .centerX(cc, nil, 1), 1):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .trailing &&
                                             $0.secondAttribute == .centerX })
    { c.constant = const + cc; return }
     
    view.trailingAnchor.constraint(equalTo: superview.centerXAnchor, constant: const).isActive = true
     
    
   case let .width(const):
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem == nil &&
                                             $0.firstAttribute == .width &&
                                             $0.secondAttribute == .notAnAttribute })
    { c.constant = const; return }
    
    view.widthAnchor.constraint(equalToConstant: const).isActive = true
    
   case let .widthR(ratio) where ratio > 0:
    
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .width &&
                                             $0.secondAttribute == .width })
    {
     guard c.multiplier != ratio else { return }
     c.isActive = false
    }
    
    view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: ratio).isActive = true
    
 
   
   case let .height(const) :
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem == nil &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .notAnAttribute })
    { c.constant = const; return }
    
    view.heightAnchor.constraint(equalToConstant: const).isActive = true
   
   case let .heightR(ratio) where ratio > 0:
    
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .height })
    {
     guard c.multiplier != ratio else { return }
     c.isActive = false
    }
    
    view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: ratio).isActive = true
    
   
   case let .aspect(ratio) where ratio > 0 :
    
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === view &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .width })
    {
     guard c.multiplier != ratio else { return }
     c.isActive = false
    }
    
    view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ratio).isActive = true
   
  
   case let .centerX(const, nil, 1):
    
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .centerX })
    { c.constant = const; return }
    
    view.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: const).isActive = true
   
   case let .centerX(const, nil, multiplier) where multiplier != 1:
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .centerX &&
                                             abs($0.multiplier - multiplier) < 1e-4 })
    {
     guard c.multiplier != multiplier else { c.constant = const; return }
     c.isActive = false
    }
    
    NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal,
                       toItem: superview, attribute: .centerX,
                       multiplier: multiplier, constant: const).isActive = true
   
   case let .centerY(const, nil, multiplier) where multiplier != 1:
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .centerY &&
                                             abs($0.multiplier - multiplier) < 1e-4 })
    {
     guard c.multiplier != multiplier else { c.constant = const; return }
     c.isActive = false
    }
    
    NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal,
                       toItem: superview, attribute: .centerY,
                       multiplier: multiplier, constant: const).isActive = true
   
   case let .centerX(const, .leading(lc , nil, 1), 1):
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .leading })
    { c.constant = const + lc; return }
   
    view.centerXAnchor.constraint(equalTo: superview.leadingAnchor, constant: const).isActive = true
   
   case let .centerX(const, .trailing(tc , nil, 1), 1):
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .trailing })
    { c.constant = const + tc; return }
   
    view.centerXAnchor.constraint(equalTo: superview.trailingAnchor, constant: const).isActive = true
   
   case let .centerY(const, nil, 1):
    
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .centerY })
    { c.constant = const; return }
    
    view.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: const).isActive = true
   
   case let .centerY(const, .top(tc , nil, 1 ), 1):
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .top })
    { c.constant = const + tc; return }
    
    view.centerYAnchor.constraint(equalTo: superview.topAnchor, constant: const).isActive = true
   
   case let .centerY(const, .bottom(bc , nil, 1), 1):
   
    if let c = (superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .bottom })
    { c.constant = const + bc; return }
    
    view.centerYAnchor.constraint(equalTo: superview.bottomAnchor, constant: const).isActive = true
   
   case let .cornerRadius(ratio):
    guard let superView = superview as? CALayerCornerRadiusObservable else { break }
    
    superView.cornerRadiusObservation = superview
     .publisher(for: \.layer.cornerRadius, options: [.initial])
     .map{ ratio * $0 }
     .assignWeakly(to: \.layer.cornerRadius, on: view)
     
    
   default: break
  }
 }

 
 subscript (view: UIView) -> NSLayoutConstraint?
 {
  get { constraint(of: view) }
  set { constrain(view: view) }
 }
 
 func constraint(of view: UIView) -> NSLayoutConstraint?
 {
  guard let superview = view.superview else { return nil }
  
  switch self
  {
   case .top(_, nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .top &&
                                             $0.secondAttribute == .top }
 
   case .top(_, .centerY(_ , nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .top &&
                                             $0.secondAttribute == .centerY }
 
   case .bottom(_ , nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .bottom &&
                                             $0.secondAttribute == .bottom }
   
   case .bottom(_, .centerY(_, nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .bottom &&
                                             $0.secondAttribute == .centerY }
    
   case .leading(_, nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .leading &&
                                             $0.secondAttribute == .leading }
   
   
   case .leading(_, .centerX(_, nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .leading &&
                                             $0.secondAttribute == .centerX }
  
   
   case .trailing(_, nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .trailing &&
                                             $0.secondAttribute == .trailing }
   
   
   case .trailing(_ , .centerX(_ , nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .trailing &&
                                             $0.secondAttribute == .centerX }
    
   case .width(_):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem == nil &&
                                             $0.firstAttribute == .width &&
                                             $0.secondAttribute == .notAnAttribute }
    
   case let .widthR(ratio) where ratio > 0:
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .width &&
                                             $0.secondAttribute == .width }
   
   
   case .height(_) :
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem == nil &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .notAnAttribute }
    
   case let .heightR(ratio) where ratio > 0 :
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .height }
  
   
   case let .aspect(ratio) where ratio > 0 :
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === view &&
                                             $0.firstAttribute == .height &&
                                             $0.secondAttribute == .width }
   
  
   case .centerX(_, nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .centerX }
   
   case let .centerX(_ , nil, multiplier) where multiplier != 1:
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .centerX &&
                                             abs($0.multiplier - multiplier) < 1e-4 }
   
   case let .centerY(_, nil, multiplier) where multiplier != 1:
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .centerY &&
                                             abs($0.multiplier - multiplier) < 1e-4 }
    
   case .centerX(_, .leading(_ , nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .leading }
   
   case .centerX(_, .trailing(_ , nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerX &&
                                             $0.secondAttribute == .trailing }
   
   case .centerY(_, nil, 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .centerY }
  
   case .centerY(_, .top(_ , nil, 1 ), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .top }
    
    
   case .centerY(_, .bottom(_ , nil, 1), 1):
         return superview.constraints.first{ $0.firstItem === view &&
                                             $0.secondItem === superview &&
                                             $0.firstAttribute == .centerY &&
                                             $0.secondAttribute == .bottom }
   
   default: return nil
  }
 }
}
