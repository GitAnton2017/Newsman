//
//  @Translated.swift
//  Newsman
//
//  Created by Anton2016 on 22.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Translated<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var shiftX: CGFloat
 private final var shiftY: CGFloat
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.setTranslation(shiftX, shiftY) }
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

 init (wrappedValue: T, shiftX: CGFloat, shiftY: CGFloat)
 {
  defer { decoratedView?.setTranslation(shiftX, shiftY) }
  
  self.shiftX = shiftX
  self.shiftY = shiftY
  
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.setTranslation(shiftX, shiftY) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .translated(x: shiftX, y: shiftY) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class
