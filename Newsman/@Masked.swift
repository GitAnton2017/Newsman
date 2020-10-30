//
//  @Masked.swift
//  Newsman
//
//  Created by Anton2016 on 17.06.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

enum MaskShape
{
 case ellipse
 case rectangle
 case roundedRectangle(cornerRadius: CGFloat = 5.0)
 case path(normalized: [CGPoint])
 case star(points: Int, innerRatio: CGFloat = 0.5)
 case none
 func maskPath(of rect: CGRect) -> UIBezierPath
 {

  switch self
  {
   case .ellipse: return UIBezierPath(ovalIn: rect)
   case .rectangle: return UIBezierPath(rect: rect)
   case let .roundedRectangle(cornerRadius: cornerRadius):
    return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    
   case let .path(normalized: points):
    let pathPoints = points.map{CGPoint(x: rect.width * $0.x, y: rect.height * $0.y)}
    return UIBezierPath(points: pathPoints)
    
   case let .star(points: N, innerRatio: k):
 
    let a: CGFloat = rect.width / 2
    let b: CGFloat = rect.height / 2
     
    let ai = a * k, bi = b * k
    
    let tr_x = a * ( 1 - k ), tr_y = b * ( 1 - k )
    
    let rad = (.pi * 2) / CGFloat(N)
    
    let points = (0..<N * 2).map { i -> CGPoint in

     if i % 2 == 0
     {
      let x = a * ( 1 + sin(rad * (CGFloat(i / 2))))
      let y = b * ( 1 - cos(rad * (CGFloat(i / 2))))
      return CGPoint(x: x, y: y)
     }
     else
     {
      let x = ai * ( 1 + sin(rad * (CGFloat(i / 2) + 0.5)))
      let y = bi * ( 1 - cos(rad * (CGFloat(i / 2) + 0.5)))
      return CGPoint(x: x, y: y).applying(.init(translationX: tr_x, y: tr_y))
     }
    }
    
    return  UIBezierPath(points: points)
   
   case .none: return UIBezierPath()
  }
 }
}

@propertyWrapper final class Masked<T: Decoratable>: Decoratable
{
 private final class MaskView: UIView
 {
  private let maskPath: UIBezierPath
  
  init(frame: CGRect, maskShape: MaskShape)
  {
   maskPath = maskShape.maskPath(of: frame)
   super.init(frame: frame)
   backgroundColor = .clear
  }
  
  override func draw(_ rect: CGRect)
  {
   UIColor(white: 0, alpha: 1).setFill()
   maskPath.fill()
  }
  
  required init?(coder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
  }
 }
 
 var decoratedView: UIView? { wrapped.decoratedView }
 
 private final var maskShape: MaskShape
 private final var maskInsets: UIEdgeInsets
 private final var maskTransform: CGAffineTransform
 private final var maskImage: UIImage?

 private final var wrapped: T
 {
  didSet
  {
   guard let dv = wrapped as? UIView else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: dv)
   
   if case .none = self.maskShape, let maskImage = self.maskImage
   {
    let mask = UIImageView(frame: dv.bounds.inset(by: self.maskInsets))
    mask.image = maskImage
    mask.contentMode = .scaleToFill
    mask.transform = self.maskTransform
    dv.mask = mask
   }
   else
   {
    let mask = MaskView(frame: dv.bounds.inset(by: maskInsets), maskShape: maskShape)
    mask.transform = maskTransform
    dv.mask = mask
   }
   
   configueBoundsChangeObservation()
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
    guard let dv = self.decoratedView else { return }
    if case .none = self.maskShape, let maskImage = self.maskImage
    {
     let mask = UIImageView(frame: dv.bounds.inset(by: self.maskInsets))
     mask.image = maskImage
     mask.contentMode = .scaleToFill
     mask.transform = self.maskTransform
     dv.mask = mask
     return
    }
    
    let mask = MaskView(frame: dv.bounds.inset(by: self.maskInsets), maskShape: self.maskShape)
    mask.transform = self.maskTransform
    dv.mask = mask
   }
 }
 
 var wrappedValue: T
 {
  get { wrapped }
  set { wrapped = newValue }
 }

 init (wrappedValue: T,
       maskImage: UIImage?,
       maskInsets: UIEdgeInsets = .zero,
       maskTransform: CGAffineTransform = .identity)
 {
  
  defer {
   if let dv = decoratedView
   {
    let mask = UIImageView(frame: dv.bounds.inset(by: maskInsets))
    mask.image = maskImage
    mask.contentMode = .scaleToFill
    mask.transform = maskTransform
    dv.mask = mask
   }
   configueBoundsChangeObservation()
  }
  
  self.maskImage = maskImage
  self.maskShape = .none
  self.maskInsets = maskInsets
  self.maskTransform = maskTransform
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
  .publisher(for: .decoratedViewDidChange)
  .compactMap{$0.object as? UIView}
  .filter { [ weak self ] in $0 === self?.decoratedView }
  .sink { [ weak self ] view in
    guard let self = self else { return }
    guard let dv = self.decoratedView else { return }
    let mask = UIImageView(frame: dv.bounds.inset(by: maskInsets))
    mask.image = maskImage
    mask.contentMode = .scaleAspectFit
    mask.transform = maskTransform
    dv.mask = mask
   
  }
  
 }
 init (wrappedValue: T,
       maskShape: MaskShape,
       maskInsets: UIEdgeInsets = .zero,
       maskTransform: CGAffineTransform = .identity)
 {
  defer {
   if let dv = decoratedView
   {
    let mask = MaskView(frame: dv.bounds.inset(by: maskInsets), maskShape: maskShape)
    mask.transform = maskTransform
    dv.mask = mask
   }
   configueBoundsChangeObservation()
  }
  
  self.maskShape = maskShape
  self.maskInsets = maskInsets
  self.maskTransform = maskTransform
  self.wrapped = wrappedValue
  
  if wrappedValue is UIView { return }
  
  decorationViewChange = NotificationCenter.default
   .publisher(for: .decoratedViewDidChange)
   .compactMap{$0.object as? UIView}
   .filter { [ weak self ] in $0 === self?.decoratedView }
   .sink { [ weak self ] view in
     guard let self = self else { return }
     guard let dv = self.decoratedView else { return }
     let mask = MaskView(frame: dv.bounds.inset(by: maskInsets), maskShape: maskShape)
     mask.transform = maskTransform
     dv.mask = mask
    
   }
  
   
 }

 
 var projectedValue: Decoration
 {
  get { .masked(with: maskShape, insets: maskInsets, transform: maskTransform) }
  set {
   
   if let dv = decoratedView,
    case let .masked(with: maskShape, insets: maskInsets, transform: maskTransform) = newValue
   {
    let mask = MaskView(frame: dv.bounds.inset(by: maskInsets), maskShape: maskShape)
    mask.transform = maskTransform
    dv.mask = mask

   }
   else
   {
    decoratedView?.decorate(newValue)
   }
   
  }
 }
 
}//@propertyWrapper
