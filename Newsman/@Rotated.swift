//
//  @Rotated.swift
//  Newsman
//
//  Created by Anton2016 on 21.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Rotated<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var angle: CGFloat
 private final var anchorPoint: CGPoint?
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.setRotation(angle, anchorPoint) }
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

 init (wrappedValue: T, angle: CGFloat, anchorPoint: CGPoint? = nil)
 {
  defer { decoratedView?.setRotation(angle, anchorPoint) }
  
  self.angle = angle
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.setRotation(angle) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .rotated(angle: angle, anchorPoint: anchorPoint) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class
