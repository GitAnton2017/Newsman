//
//  @Capsulated.swift
//  Newsman
//
//  Created by Anton2016 on 15.06.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Capsulated<T: Decoratable>: Decoratable
{
 
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var orientation: Orientaion
 
 private final var cornerRadius: CGFloat
 {
  guard let view = decoratedView else { return 0 }
  
  switch orientation
  {
   case .horizontal
    where view.bounds.width >= view.bounds.height: return 0.5 * view.bounds.height
   
   case .vertical
    where view.bounds.width <= view.bounds.height: return 0.5 * view.bounds.width
   
   default: return 0
  }
 }
 
 private final var wrapped: T
 {
  didSet
  {
   defer {
    decoratedView?.roundCorners(cornerRadius)
    configueBoundsChangeObservation()
   }
   guard let newView = wrapped as? UIView else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: newView)
  }
 }
 
 private final var decorationViewChange: AnyCancellable?
 private final var decorationViewBoundsChange: AnyCancellable?
 
 private final func configueBoundsChangeObservation()
 {
  decorationViewBoundsChange = decoratedView?
   .publisher(for: \.bounds, options: [.prior])
   .collect(2)
   .filter{ $0[0] != $0[1] }
   .sink {[ weak self ] _ in
     guard let self = self else { return }
     self.decoratedView?.roundCorners(self.cornerRadius)
   }
 }
 
 var wrappedValue: T
 {
  get { wrapped }
  set { wrapped = newValue }
 }

 init (wrappedValue: T, orientation: Orientaion = .horizontal)
 {
  defer {
   decoratedView?.roundCorners(cornerRadius)
   configueBoundsChangeObservation()
  }
  
  self.orientation = orientation
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { [ weak self ] view in
     guard let self = self else { return }
     view.roundCorners(self.cornerRadius)
    
   }
  
   
 }
 
 var projectedValue: Decoration
 {
  get { .capsulated(orientation: orientation) }
  set {  decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper 

