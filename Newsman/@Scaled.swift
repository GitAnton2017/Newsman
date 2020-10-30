//
//  @Scaled.swift
//  Newsman
//
//  Created by Anton2016 on 22.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Scaled<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var scaleX: CGFloat
 private final var scaleY: CGFloat
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.setScale(scaleX, scaleY) }
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

 init (wrappedValue: T, scaleX: CGFloat = 1.0, scaleY: CGFloat = 1.0)
 {
  defer { decoratedView?.setScale(scaleX, scaleY) }
  
  self.scaleX = scaleX
  self.scaleY = scaleY
  
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.setScale(scaleX, scaleY) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .scaled(x: scaleX, y: scaleY) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class

