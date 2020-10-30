//
//  Pop-up Menu Main.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable
import class RxSwift.PublishSubject
import class RxSwift.DisposeBag
import class RxSwift.MainScheduler

class PointedMenuView: UIView
{
 static let defaultFillColor = #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1)
 static let boundsTouchColor = #colorLiteral(red: 0.9498608733, green: 0.6073416096, blue: 0.4789334289, alpha: 1)
 
 let disposeBag = DisposeBag()
 
 deinit { print("<<<<< ------ Pointed Menu View is DESTROYED! ----- >>>>>>") }
 
 @Published var menuPosition: CGPoint = .zero
 @Published var menuShift:    CGPoint = .zero
 @Published var menuScale:    CGFloat = .zero
 
 private var activityTimeout: DispatchTimeInterval
 
 private var timeoutHanldler: (() -> ())?

 var activitySubject = PublishSubject<Void>()
 
 var cancellables = Set<AnyCancellable>()
 
 weak var boundingSuperView: UIView?
 
 unowned var arrowView: MenuArrowView!
 
 @objc unowned var baseView:  MenuBaseView!
 
 unowned var arrowViewXconst: NSLayoutConstraint!
 unowned var arrowViewYconst: NSLayoutConstraint!
 
 unowned var arrowViewWconst: NSLayoutConstraint!
 unowned var arrowViewHconst: NSLayoutConstraint!
 
 unowned var baseViewXconst: NSLayoutConstraint!
 unowned var baseViewYconst: NSLayoutConstraint!
 
 unowned var baseViewWconst: NSLayoutConstraint!
 unowned var baseViewHconst: NSLayoutConstraint!
 

 func move(dx: CGFloat, dy: CGFloat)
 {
  let cx = baseView.center.x
  let cy = baseView.center.y
  
  let w = arrowView.bounds.width
  let h = arrowView.bounds.height
  
  let adx = (cx + dx < 0) ? -cx : ( cx + dx > w ? w - cx: dx )
  let ady = (cy + dy < 0) ? -cy : ( cy + dy > h ? h - cy: dy )
  
  baseViewXconst.constant += adx
  baseViewYconst.constant += ady
  
  baseViewHconst.constant += ady
  baseViewWconst.constant += adx
  
  arrowView.setNeedsDisplay()
  baseView.setNeedsLayout()
  
 }
 
 var buttons: [MenuItemButton]
 {
  didSet
  {
   baseView.buttons = self.buttons
  }
 }
 
 var buttonsInRow:   Int
 var fillColor:      UIColor
 
 var menuInset:      UIEdgeInsets
 var shift:          CGPoint
 var cornerRadius:   CGFloat
 

 
 var interButtonMargin:   CGFloat
 
 
 init(frame:               CGRect = .zero,
      bounder:             UIView? = nil,
      menuInset:           UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
      shift:               CGPoint = .zero,
      menuCornerRadius:    CGFloat,
      interButtonMargin:   CGFloat,
      buttonsInRow:        Int = 3,
      fillColor:           UIColor = PointedMenuView.defaultFillColor,
      buttons: [MenuItemButton],
      activityTimeout: DispatchTimeInterval = .seconds(10),
      timeoutHanldler: (() -> ())? = nil)
 {
  
  self.fillColor = fillColor
  self.menuInset = menuInset
  self.cornerRadius = menuCornerRadius
  self.shift = shift
  self.interButtonMargin = interButtonMargin
  self.buttonsInRow = buttonsInRow
  self.buttons = buttons
  self.boundingSuperView = bounder
  self.activityTimeout = activityTimeout
  self.timeoutHanldler = timeoutHanldler
  
  super.init(frame: frame)
  
  activitySubject
  .timeout(activityTimeout, scheduler: MainScheduler.instance) //.debug()
  .subscribe(onError: { [unowned self] _ in self.timeoutHanldler?() })
  .disposed(by: disposeBag)
  
  backgroundColor = .clear
  
  let arrowView = MenuArrowView(bounder: bounder, fillColor: fillColor)

  arrowView.translatesAutoresizingMaskIntoConstraints = false

  self.addSubview(arrowView)
  self.arrowView =  arrowView

  let baseView = MenuBaseView(bounder: bounder,
                              fillColor: fillColor,
                              cornerRadius: menuCornerRadius,
                              margin: interButtonMargin,
                              buttons: buttons)

  baseView.translatesAutoresizingMaskIntoConstraints = false

  self.addSubview(baseView)
  self.baseView = baseView
  
  arrowView.baseView = baseView

  
  let arrowViewXconst = arrowView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0.0)
  self.arrowViewXconst = arrowViewXconst

  let arrowViewYconst = arrowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0)
  self.arrowViewYconst = arrowViewYconst

  let arrowViewWconst = arrowView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1, constant: 0.0)
  self.arrowViewWconst = arrowViewWconst

  let arrowViewHconst = arrowView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1, constant: 0.0)
  self.arrowViewHconst = arrowViewHconst
  
 
  let baseViewXconst = baseView.leadingAnchor.constraint(equalTo: centerXAnchor,
                                                         constant: menuInset.left + shift.x)
  self.baseViewXconst = baseViewXconst
  
  let baseViewYconst = baseView.topAnchor.constraint(equalTo: centerYAnchor,
                                                     constant: menuInset.top + shift.y)
  self.baseViewYconst = baseViewYconst
  
  
  let baseViewHconst = baseView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                        constant:  -menuInset.bottom + shift.y)
  self.baseViewHconst = baseViewHconst
  
  let baseViewWconst = baseView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                          constant: -menuInset.right + shift.x)
  self.baseViewWconst = baseViewWconst
  
  
  NSLayoutConstraint.activate(
  [
   arrowViewXconst, arrowViewYconst, arrowViewWconst, arrowViewHconst,
   baseViewYconst,  baseViewXconst,  baseViewHconst,  baseViewWconst,
  ])
  

  publisher(for: \.baseView.center, options: []).sink
  { center in
    defer
    {
     arrowView.setNeedsDisplay()
     baseView.setNeedsDisplay()
    }
    
    if (center.x.rounded() == arrowView.bounds.width.rounded() ||
        center.y.rounded() == arrowView.bounds.height.rounded() ||
        center.x.rounded() == 0.0 ||
        center.y.rounded() == 0.0 )
    {
     arrowView.fillColor = PointedMenuView.boundsTouchColor
     baseView.fillColor =  PointedMenuView.boundsTouchColor
    }
    else
    {
     arrowView.fillColor = fillColor
     baseView.fillColor = fillColor
    }
  }.store(in: &cancellables)
 
 }
 
 override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
 {
  
  if let target = super.hitTest(point, with: event) as? MenuItemButton { return target }
  
  if let folderCV = (superview as? PhotoFolderCell)?.photoCollectionView
  {
   let tp = convert(point, to: folderCV)
   if let nestedIndexPath = folderCV.indexPathForItem(at: tp),
      let nestedCell = folderCV.cellForItem(at: nestedIndexPath)
   {
    return nestedCell
   }
  }
  
 
  for subview in subviews.reversed()
  {
   let tp = convert(point, to: subview)
   if let menuItemButton = subview.hitTest(tp, with: event) as? MenuItemButton
   {
    return menuItemButton
   }
  }
 
  
  return nil
 }
 
 required init?(coder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
 
 override func draw(_ rect: CGRect)
 {
  self.isOpaque = false
  layer.shadowOpacity = 1
  layer.shadowColor = UIColor.black.cgColor
  layer.shadowRadius = 10
  layer.shadowOffset = CGSize(width: -2, height: 2)
 }
 
}

