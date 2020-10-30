//
//  @Constrained.swift
//  Newsman
//
//  Created by Anton2016 on 20.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

@propertyWrapper final class Constrained<V: Decoratable>: Decoratable
{
 final var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var disposer = Set<AnyCancellable>()
 
 private final var wrapped: V
 {
  didSet
  {
   defer
   {
    Anchors.constrain(view: decoratedView, with: anchors)
    configueSuperViewObservation()
    configueDecoratedViewObservation()
   }
   
   guard let newView = wrapped as? UIView else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: newView)
  }
 }

 private final var anchors: Set<Anchors>
 {
  didSet { Anchors.constrain(view: decoratedView, with: anchors) }
 }
 
 private final func configueDecoratedViewObservation()
 {
  if wrapped is UIView { return }
  
  NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView } //.print("<<< Publisher.Decorated View Did Change >>>")
   .sink { [ weak self ] _ in
     guard let self = self else { return }
     Anchors.constrain(view: self.decoratedView, with: self.anchors)
    }.store(in: &disposer)
   
 }
 
 private final func configueSuperViewObservation()
 {
  guard decoratedView?.superview == nil else { return }

  UIView.observeSuperview()

  decoratedView?.publisher(for: \.superview, options: [])
   .compactMap{ $0 }
   .filter { !($0 is UIWindow) } //.print ("<<< Publisher.Decorated * SUPER * View Did Change >>>")
   .sink { [ weak self ] _ in
     guard let self = self else { return }
     Anchors.constrain(view: self.decoratedView, with: self.anchors)
   }.store(in: &disposer)
 }
 
 var wrappedValue: V
 {
  get { wrapped }
  set { wrapped = newValue }
 }
 
 final func addToSuperview(_ superview: UIView)
 {
  guard let decoratedView = self.decoratedView else { return }
  superview.addSubview(decoratedView)
  Anchors.constrain(view: decoratedView, with: anchors)
 }
 
 init(wrappedValue: V, anchors: Anchors...)
 {
  wrapped = wrappedValue
  self.anchors = Set(anchors)
  
  Anchors.constrain(view: decoratedView, with: anchors)
  
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 init(wrappedValue: V)
 {
  wrapped = wrappedValue
  anchors = UIEdgeInsets.zero.anchors
  
  Anchors.edgeConstrained(view: decoratedView, with: .zero)
 
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 
 init(wrappedValue: V, insets: UIEdgeInsets)
 {
  wrapped = wrappedValue
  anchors = insets.anchors
  
  Anchors.edgeConstrained(view: decoratedView, with: insets)
  
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 init(wrappedValue: V, inset: CGFloat)
 {
  wrapped = wrappedValue
  anchors = UIEdgeInsets.equallyAnchored(by: inset)
  
  Anchors.equallyEdgeConstrained(view: decoratedView, with: inset)
  
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 init(wrappedValue: V, top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat)
 {
  wrapped = wrappedValue
  anchors = [ .top(top), .bottom(bottom), .trailing(trailing), .leading(leading)]
  
  Anchors.constrain(view: decoratedView, with: anchors)
 
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 init(wrappedValue: V, top: CGFloat = 0, shiftX: CGFloat = 0, wR: CGFloat, hR: CGFloat)
 {
  wrapped = wrappedValue
  anchors = [ .top(top), .centerX(shiftX), .widthR(wR), .heightR(hR)]
  
  Anchors.topCenterXConstrained(view: decoratedView, shiftX: shiftX, top: top, widthRatio: wR, heightRatio: hR)
 
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 init(wrappedValue: V, centerShift: CGPoint = .zero, wR: CGFloat, hR: CGFloat)
 {
  wrapped = wrappedValue
  anchors = [ .centerX(centerShift.x), .centerY(centerShift.y), .widthR(wR), .heightR(hR)]
  
  Anchors.centerXYConstrained(view: decoratedView, shift: centerShift, widthRatio: wR, heightRatio: hR)
 
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 
 init(wrappedValue: V, centerToTopTrailingShift: CGPoint = .zero, wR: CGFloat, hR: CGFloat)
 {
  wrapped = wrappedValue
  anchors = [ .centerX(centerToTopTrailingShift.x, .trailing()),
              .centerY(centerToTopTrailingShift.y, .top()), .widthR(wR), .heightR(hR)]
  
  Anchors.CenterToTopTrailingConstrained(view: decoratedView, shift: centerToTopTrailingShift,
                                         widthRatio: wR, heightRatio: hR)
 
  configueSuperViewObservation()
  configueDecoratedViewObservation()
 }
 
 
 
 
 
 var projectedValue: Decoration
 {
  get { .constraints(anchors: Array(anchors))}
  set { decoratedView?.decorate(newValue)    }
 }
 

}
