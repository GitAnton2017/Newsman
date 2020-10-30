//
//  @Framed.swift
//  Newsman
//
//  Created by Anton2016 on 22.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Framed<T: Decoratable>: Decoratable
{
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private var frameWidth: CGFloat
 private var frameColor: UIColor
 private var frameDashPattern: [NSNumber]
 private var frameMargin: CGFloat
 private var isAnimated: Bool
 private var isOverlayed: Bool
 
 private var wrapped: T
 {
  didSet
  {
   defer { configueDecoratedView() }
  
   guard let newView = wrapped as? UIView else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: newView)
  }
 }
 
 private final var decorationViewChange: AnyCancellable?
 private final var decorationViewLayerBoundsChange: AnyCancellable?
 
 private final func configueDecoratedView()
 {
  guard let dv = decoratedView else { return }
  dv.drawDashFrame(frameColor, frameWidth, frameMargin,frameDashPattern, isAnimated, isOverlayed)
 
 }

 var wrappedValue: T
 {
  get { wrapped }
  set { wrapped = newValue }
 }
 

 init (wrappedValue: T,
       frameWidth: CGFloat,
       frameColor: UIColor,
       frameDashPattern: [NSNumber] = [10, 4],
       frameMargin: CGFloat = 0,
       isAnimated: Bool = true,
       isOverlayed: Bool = true)
 {
  defer { configueDecoratedView() }
  
  self.frameWidth = frameWidth
  self.frameColor = frameColor
  self.frameDashPattern = frameDashPattern
  self.frameMargin = frameMargin
  self.isAnimated = isAnimated
  self.isOverlayed = isOverlayed
  
  self.wrapped = wrappedValue
 
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{ $0.object as? UIView }
   .filter { [ weak self ]  in $0 === self?.decoratedView    }
   .sink   { [ weak self ]_ in self?.configueDecoratedView() }
  

 }
 
 var projectedValue: Decoration
 {
  get { .framed(color: frameColor, width: frameWidth, margin: frameMargin,
                pattern: frameDashPattern, animated: isAnimated, overlayed: isOverlayed) }
  
  set { decoratedView?.decorate(newValue) }
 }
 
}//@propertyWrapper class Bordered
