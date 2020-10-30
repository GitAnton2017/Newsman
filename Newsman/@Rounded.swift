//
//  @Rounded.swift
//  Newsman
//
//  Created by Anton2016 on 19.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Rounded<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var cornerRadius: CGFloat
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.roundCorners(cornerRadius) }
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

 init (wrappedValue: T, cornerRadius: CGFloat )
 {
  defer { decoratedView?.roundCorners(cornerRadius) }
  self.cornerRadius = cornerRadius
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.roundCorners(cornerRadius) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .rounded(radius: cornerRadius) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class Rounded
