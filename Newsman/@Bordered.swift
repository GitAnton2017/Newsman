//
//  @Bordered.swift
//  Newsman
//
//  Created by Anton2016 on 19.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Bordered<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private var borderWidth: CGFloat
 private var borderColor: UIColor?
 
 private var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.drawBorder(borderWidth, borderColor) }
   guard let newView = wrapped as? UIView else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: newView)
  }
 }
 
 private final var decorationViewChange: AnyCancellable?

 var wrappedValue: T
 {
  get { wrapped }
  set { wrapped = newValue }
 }
 
 init (wrappedValue: T, borderWidth: CGFloat, borderColor: UIColor )
 {
  defer { decoratedView?.drawBorder(borderWidth, borderColor) }
  
  self.borderWidth = borderWidth
  self.borderColor = borderColor
  self.wrapped = wrappedValue
 
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{ $0.object as? UIView }
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.drawBorder(borderWidth, borderColor) }
  

 }
 
 var projectedValue: Decoration
 {
  get { .bordered(color: borderColor, width: borderWidth) }
  set { decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class Bordered
