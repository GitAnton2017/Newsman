//
//  Transformed.swift
//  Newsman
//
//  Created by Anton2016 on 22.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

extension CGAffineTransform: Hashable
{
 public func hash(into hasher: inout Hasher)
 {
  hasher.combine(a); hasher.combine(b); hasher.combine(c); hasher.combine(d)
  hasher.combine(tx); hasher.combine(ty)
 }
}

@propertyWrapper final class Transformed<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var transforms: [CGAffineTransform]
 
 private final var wrapped: T
 {
  didSet
  {
   defer { decoratedView?.setTransforms(transforms) }
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

 init (wrappedValue: T, transforms: CGAffineTransform...)
 {
  defer { decoratedView?.setTransforms(transforms) }
  
  self.transforms = transforms
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { $0.setTransforms(transforms) }
   
 }
 
 var projectedValue: Decoration
 {
  get { .transformed(with: transforms) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class

