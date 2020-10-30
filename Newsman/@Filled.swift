//
//  @Filled.swift
//  Newsman
//
//  Created by Anton2016 on 19.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Filled<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var fillColor: UIColor
 private final var alpha: CGFloat
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.setBackColor(fillColor, alpha) }
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

 init (wrappedValue: T, fillColor: UIColor, alpha: CGFloat = 1)
 {
  defer { decoratedView?.setBackColor(fillColor, alpha) }
  
  self.fillColor = fillColor
  self.alpha = alpha
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.setBackColor(fillColor, alpha) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .filled(color: fillColor, alpha: alpha) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class Rounded
