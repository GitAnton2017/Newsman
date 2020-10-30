//
//  Menu Base View.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift
import class Combine.AnyCancellable
import func simd.sign


final class MenuBaseView: UIView, UIGestureRecognizerDelegate
{
 
 deinit { print (" <<<<< ---- MenuBaseView is Destroyed ---- >>>>>") }
 
 let disposeBag = DisposeBag()
 var cancellables = Set<AnyCancellable>()

 private enum DeltaType { case min, max }
 private enum DeltaAxis { case X, Y     }
 
 private func delta(_ type: DeltaType, _ axis: DeltaAxis) -> CGFloat?
 {
  guard let bounder = self.boundingSuperView else { return nil }
  guard let menuView = self.superview as? PointedMenuView else { return nil }
  
  let menuRect = bounder.convert(menuView.bounds, from: menuView)
  
  switch (type, axis)
  {
   case (.min, .X): return menuRect.minX - bounder.bounds.minX
   case (.min, .Y): return menuRect.minY - bounder.bounds.minY
   case (.max, .X): return menuRect.maxX - bounder.bounds.maxX
   case (.max, .Y): return menuRect.maxY - bounder.bounds.maxY
  }
 }
 
 private func deltaBase(_ type: DeltaType, _ axis: DeltaAxis) -> CGFloat?
 {
  guard let bounder = self.boundingSuperView else { return nil }
  
  let base = bounder.convert(bounds, from: self)
  
  switch (type, axis)
  {
   case (.min, .X): return base.minX - bounder.bounds.minX
   case (.min, .Y): return base.minY - bounder.bounds.minY
   case (.max, .X): return base.maxX - bounder.bounds.maxX
   case (.max, .Y): return base.maxY - bounder.bounds.maxY
  }
 }
 
 private var shiftBase: CGPoint
 {
  guard let deltaMaxX = deltaBase(.max, .X) else { return .zero }
  guard let deltaMaxY = deltaBase(.max, .Y) else { return .zero }
  guard let deltaMinX = deltaBase(.min, .X) else { return .zero }
  guard let deltaMinY = deltaBase(.min, .Y) else { return .zero }
  
  //bounding rect 4 corner cases....
  if deltaMinY < 0 && deltaMaxX > 0 { return CGPoint(x: -deltaMaxX, y: -deltaMinY) } // case #1: right top corner
  if deltaMaxX > 0 && deltaMaxY > 0 { return CGPoint(x: -deltaMaxX, y: -deltaMaxY) } // case #2: right bottom corner
  if deltaMinX < 0 && deltaMaxY > 0 { return CGPoint(x: -deltaMinX, y: -deltaMaxY) } // case #3: left bottom corner
  if deltaMinY < 0 && deltaMinX < 0 { return CGPoint(x: -deltaMinX, y: -deltaMinY) } // case #4: left top corner
  
  //bounding rect 4 side cases....
  if deltaMinY < 0 && deltaMinX >= 0 && deltaMaxX <= 0 { return CGPoint(x: 0, y: -deltaMinY) } //case #5: top
  if deltaMaxX > 0 && deltaMinY >= 0 && deltaMaxY <= 0 { return CGPoint(x: -deltaMaxX, y: 0) } //case #6: trailing
  if deltaMinX < 0 && deltaMinY >= 0 && deltaMaxY <= 0 { return CGPoint(x: -deltaMinX, y: 0) } //case #7: leading
  if deltaMaxY > 0 && deltaMinX >= 0 && deltaMaxX <= 0 { return CGPoint(x: 0, y: -deltaMaxY) } //case #8: bottom
  
  return .zero
  
 }
 
 private var menuViewCase: Int?
 {
  guard let deltaMaxX = delta(.max, .X) else { return nil }
  guard let deltaMaxY = delta(.max, .Y) else { return nil }
  guard let deltaMinX = delta(.min, .X) else { return nil }
  guard let deltaMinY = delta(.min, .Y) else { return nil }
  
  //bounding rect 4 corner cases....
  if deltaMinY < 0 && deltaMaxX > 0 { return 0 } // case #1: right top corner
  if deltaMaxX > 0 && deltaMaxY > 0 { return 1 } // case #2: right bottom corner
  if deltaMinX < 0 && deltaMaxY > 0 { return 2 } // case #3: left bottom corner
  if deltaMinY < 0 && deltaMinX < 0 { return 3 } // case #4: left top corner
  
  //bounding rect 4 side cases....
  if deltaMinY < 0 && deltaMinX >= 0 && deltaMaxX <= 0 { return 4 } //case #5: top
  if deltaMaxX > 0 && deltaMinY >= 0 && deltaMaxY <= 0 { return 5 } //case #6: trailing
  if deltaMinX < 0 && deltaMinY >= 0 && deltaMaxY <= 0 { return 6 } //case #7: leading
  if deltaMaxY > 0 && deltaMinX >= 0 && deltaMaxX <= 0 { return 7 } //case #8: bottom
  
  return nil
 }
 
 private var baseViewCase: Int?
 {
  guard let menuView = self.superview as? PointedMenuView else { return nil }
  
  // base view center orientation inside 4 quaters of menuView cases
  if center.x <= menuView.bounds.midX && center.y <= menuView.bounds.midY { return 0 } // case #1 left top
  if center.x >= menuView.bounds.midX && center.y <= menuView.bounds.midY { return 1 } // case #2 right top
  if center.x <= menuView.bounds.midX && center.y >= menuView.bounds.midY { return 2 } // case #3 left bottom
  if center.x >= menuView.bounds.midX && center.y >= menuView.bounds.midY { return 3 } // case #4 right bottom
  
  return nil
 }
 
 private lazy var baseCase1: [CGFloat] = [ -.pi/2,      0,  .pi/2,  .pi,  -.pi/2,      0,  .pi/2,     0  ]
 private lazy var baseCase2: [CGFloat] = [  .pi  ,  -.pi/2,     0,  .pi/2, .pi/2, -.pi/2,      0,     0  ]
 private lazy var baseCase3: [CGFloat] = [      0,   .pi/2, .pi  , -.pi/2,     0,      0, -.pi/2,  .pi/2 ]
 private lazy var baseCase4: [CGFloat] = [  .pi/2,   .pi,  -.pi/2,      0,     0,  .pi/2,      0, -.pi/2 ]
 
 private lazy var rotationTable = [ baseCase1, baseCase2, baseCase3, baseCase4 ]

 private var rotationAngle: CGFloat
 {
  guard let menuCase = self.menuViewCase else { return 0 }
  guard let baseCase = self.baseViewCase else { return 0 }
  
  return rotationTable[baseCase][menuCase]
  
 }
 
 @objc dynamic var isMenuPanning = false
 @objc dynamic var isMenuScaling = false
 
 private let padding: CGFloat = 10
 
 func shiftIfNeeded()
 {
  guard let menuView = self.superview as? PointedMenuView else { return }
  
  let angle = self.rotationAngle
  
  menuView.transform = CGAffineTransform(rotationAngle:  angle)
           transform = CGAffineTransform(rotationAngle: -angle)
  
  let shift = shiftBase.applying(transform)
  
  center.x += shift.x + CGFloat(sign(Double(shift.x))) * padding
  center.y += shift.y + CGFloat(sign(Double(shift.y))) * padding
  
  menuView.arrowView.setNeedsDisplay()
 }
 
 override func layoutSubviews()
 {
  //print (#function, self)
  super.layoutSubviews()
  
  if isMenuPanning || isMenuScaling { return }

  shiftIfNeeded()
  
 }
 
 
 override func updateConstraints()
 {
  super.updateConstraints()
 }
 
 
 
 override func didMoveToSuperview()
 {
  super.didMoveToSuperview()
  
 }

 
 override func willMove(toSuperview newSuperview: UIView?)
 {
  super.willMove(toSuperview: newSuperview)
 }

 weak var boundingSuperView: UIView?
 
 let buttonInset: CGFloat = 0.5
 let buttonsCVInset: CGFloat = 5
 
 var buttonsInRow: Int
 var fillColor: UIColor
 var cornerRadius: CGFloat
 var margin: CGFloat
 
 var buttons: [MenuItemButton]
 {
  didSet
  {
   buttonsTapToken?.dispose()
   configueMenuButtonEvents()
   buttonsCollectionView.reloadData()
  }
 }
 
 lazy var buttonsCollectionView: UICollectionView =
 {
  let lo = UICollectionViewFlowLayout()
  lo.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
  lo.minimumInteritemSpacing = margin
  lo.minimumLineSpacing = margin
 
  let cv = UICollectionView(frame: .zero, collectionViewLayout: lo)
 
  cv.delegate = self
  cv.dataSource = self
 // cv.allowsMultipleSelection = false //<didDeselect> will be called automaticaly if implemented in delegate!
  cv.backgroundColor = .clear
//  cv.dragInteractionEnabled = true
  
//   cv.dropDelegate = self
//   cv.dragDelegate = self
  
  //cv.contentInsetAdjustmentBehavior = .never //!!!
 // Constants indicating how safe area insets are added to the adjusted content inset.
 // .automatic - Automatically adjust the scroll view insets.
 // .scrollableAxes - Adjust the insets only in the scrollable directions.
 // .never - Do not adjust the scroll view insets.
 // .always -Always include the safe area insets in the content adjustment.
 
 
 
  cv.register(MenuButtonCell.self, forCellWithReuseIdentifier: MenuButtonCell.reuseID)
  
  return cv
  
 }()
 
 init(frame: CGRect = .zero,
      bounder: UIView?,
      fillColor: UIColor,
      cornerRadius: CGFloat,
      margin: CGFloat = 2,
      buttonsInRow: Int = 3,
      buttons: [MenuItemButton])
 {
  self.margin = margin
  self.fillColor = fillColor
  self.cornerRadius = cornerRadius
  self.buttonsInRow = buttonsInRow
  self.buttons = buttons
  self.boundingSuperView = bounder
  
  super.init(frame: frame)
  
  setupBaseView()
  
 }
 
 private func setupBaseView()
 {
  backgroundColor = .clear
  configueButtonsCollectionView()
  configueMenuPanning()
  configueMenuScaling()
  configueMenuButtonEvents()
 }
 
 private var buttonsTapToken: Disposable?
 
 private func configueMenuButtonEvents()
 {
  let buttonsSubscriber = Observable.from(buttons.map
   {button in
    button.rx.controlEvent(.touchUpInside)
     .do(onNext:
      {[unowned self] in
       (self.superview as? PointedMenuView)?.activitySubject.onNext(())
      })
     .map{ _ in button }
   })
   .merge()
   .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
   //.debug("<<<< **** BUTTONS TAPS **** >>>> ")
   .subscribe(onNext: { $0.tap()})
   
   self.buttonsTapToken = buttonsSubscriber
   buttonsSubscriber.disposed(by: disposeBag)
  
 //Combibe Solution...
 //  buttons.publisher.flatMap
 //  {button in
 //   button.publisher(for: \.isHighlighted, options: []).map{_ in button }
 //  }.debounce(for: .seconds(2), scheduler: DispatchQueue.main)
 //   .sink(receiveValue: {$0.tap($0)})
 //  .store(in: &cancellables)
  
 }
 
 
 private func configueButtonsCollectionView()
 {
  buttonsCollectionView.translatesAutoresizingMaskIntoConstraints = false
  self.addSubview(buttonsCollectionView)
  
  NSLayoutConstraint.activate([
   buttonsCollectionView.bottomAnchor.constraint   (equalTo: bottomAnchor,    constant: -buttonsCVInset),
   buttonsCollectionView.topAnchor.constraint      (equalTo: topAnchor,       constant:  buttonsCVInset),
   buttonsCollectionView.leadingAnchor.constraint  (equalTo: leadingAnchor,   constant:  buttonsCVInset),
   buttonsCollectionView.trailingAnchor.constraint (equalTo: trailingAnchor,  constant: -buttonsCVInset)
  ])
 }
 
 
 private func menuPan(_ panner: UIPanGestureRecognizer)
 {
  guard let menuView = self.superview as? PointedMenuView else { return }
  guard bounds.contains(panner.location(in: self)) else
  {
   panner.state = .failed
   return
   
  }
  
  switch panner.state
  {
   case .began: isMenuPanning = true
   
   case .changed:
    menuView.activitySubject.onNext(())
    let tr = panner.translation(in: menuView)
    menuView.move(dx: tr.x, dy: tr.y)
    panner.setTranslation(.zero, in: menuView)
   
    menuView.menuShift = CGPoint(x: tr.x / menuView.bounds.width, y: tr.y / menuView.bounds.height)
    
   case .ended:
    menuView.menuPosition = CGPoint(x: center.x / menuView.bounds.width ,
                                    y: center.y / menuView.bounds.height)
   default: break
  }
  
 
  
 }
 
 
 
 private weak var panner: UIPanGestureRecognizer?
 
 private func configueMenuPanning()
 {
  boundingSuperView?.rx.panGesture
  {[unowned self] panner, delegate in
   self.panner = panner
   delegate.simultaneousRecognitionPolicy = .never
   
   delegate.beginPolicy = .custom
   { [unowned self] in
      self.bounds.contains($0.location(in: self)) &&
      self.pincher?.state != .began &&
      self.pincher?.state != .changed &&
      self.pincher?.state != .recognized
   }
  }
  .skip(1)
  .subscribe(onNext: { [unowned self] in self.menuPan($0) })
  .disposed(by: disposeBag)
 }
 
 
 private var scaleFactor: CGFloat = 1.0
 
 private func menuScale(_ pincher: UIPinchGestureRecognizer)
 {
  guard let menuView = self.superview as? PointedMenuView else { return }
  
  guard pincher.numberOfTouches == 2 else { return }
  
  let tp1 = pincher.location(ofTouch: 0, in: self)
  let tp2 = pincher.location(ofTouch: 1, in: self)

  guard bounds.contains(tp1) && bounds.contains(tp2) else
  {
   pincher.state = .failed
   return
  }
  
  switch pincher.state
  {
   
   case .began: isMenuScaling = true
  
   case .changed:
    menuView.activitySubject.onNext(())
    let scale = pincher.scale
    
    scaleFactor *= scale
    if (scaleFactor >= 0.5 && scaleFactor <= 2)
    {
     transform = transform.scaledBy(x: scale, y: scale)
     menuView.menuScale = scale
    }
    pincher.scale = 1
   
   case .ended:  break
   
   default: break
  }
  
  
 }
 
 private weak var pincher: UIPinchGestureRecognizer?
 
 private func configueMenuScaling()
 {
  rx.pinchGesture
   { [unowned self] pincher , delegate in
     self.pincher = pincher
     delegate.simultaneousRecognitionPolicy = .never    
     delegate.beginPolicy = .custom
     { [unowned self] _ in
        self.panner?.state != .began &&
        self.panner?.state != .changed &&
        self.panner?.state != .recognized
     }
  }
  .skip(1)
  .subscribe(onNext: {[unowned self] in self.menuScale($0) })
  .disposed(by: disposeBag)
 }
 
 override func draw(_ rect: CGRect)
 {
  let rectPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
  fillColor.setFill()
  rectPath.fill()
  
 }
 
 required init?(coder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
 
}
