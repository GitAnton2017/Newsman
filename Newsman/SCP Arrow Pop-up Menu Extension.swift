//
//  SCP Arrow Pop-up Menu Extension.swift
//  Newsman
//
//  Created by Anton2016 on 09.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift
import Combine

 
extension PhotoSnippetCellProtocol 
{
 
 func configueCenterChangeObservation()
 {
  publisher(for: \.center, options: []).sink {[unowned self] _ in
   self.arrowMenuView?.baseView?.shiftIfNeeded()
  }.store(in: &cancellables)
 }
 


 
 func configueArrowMenu()
 {
  let name = PhotoSnippetCell.menuLongPressName
  if gestureRecognizers?.contains(where: {$0.name == name}) ?? false { return }
  
  configueCenterChangeObservation()
  
  rx.longPressGesture
  { longPresser, delegate in
    longPresser.minimumPressDuration = 1.0
    longPresser.name = name
   
    delegate.beginPolicy = .custom { [unowned self] in
     
      let tp = $0.location(in: self)
      switch self
      {
       case let folderCell as PhotoFolderCell:
        guard let nestedIndexPath = folderCell.photoCollectionView?.indexPathForItem(at: tp) else { break }
        guard let nestedCell = folderCell.photoCollectionView?.cellForItem(at: nestedIndexPath) as? PhotoFolderCollectionViewCell else { break }
        //guard let longPresser = (nestedCell.gestureRecognizers?.first{$0.name == name}) else { break }
        
        if /*longPresser.state == .recognized &&*/ nestedCell.isMenuVisible
        {
         return false
        }
       
       case let nestedCell as PhotoFolderCollectionViewCell:
         guard let folderCell = nestedCell.owner else { break }
        //guard let longPresser = (folderCell.gestureRecognizers?.first{$0.name == name}) else { break }
        if /*longPresser.state == .recognized &&*/ nestedCell.isMenuVisible == false
        {
         nestedCell.hostedItem?.terminate()

         let ftp = nestedCell.convert(tp, to: folderCell)
         let ntp = CGPoint(x: ftp.x / folderCell.bounds.width, y: ftp.y / folderCell.bounds.height)
         folderCell.hostedItem?.arrowMenuTouchPoint = ntp
         return false
        }
       
       default: break
      }
     
      let touched = self.hitTest(tp, with: nil)
      return !(touched is MenuItemButton) && self.bounds.contains(tp) 
    }
   
   }.when(.began)
   .asLocation(in: .view) //.debug()
   .subscribe(onNext: {[unowned self] in
    
    let tp = CGPoint(x: $0.x / self.bounds.width, y: $0.y / self.bounds.height)
    self.hostedItem?.arrowMenuTouchPoint = tp
    
   }).disposed(by: disposeBag)
  
          
 }
 
 func recoverCellOverlapping()
 {
  guard let cv = superview as? PhotoSnippetCollectionView else { return }
  
  switch self
  {
   case let folderCell as PhotoFolderCell:
    guard let photosInRow = folderCell.photoSnippetVC?.photosInRow else { break }
    guard let indexPath = cv.indexPath(for: folderCell) else { break }
    var belowIndexPath = IndexPath(row: indexPath.row + photosInRow, section: indexPath.section)
    
    while let belowFolderCell = cv.cellForItem(at: belowIndexPath) as? PhotoFolderCell
    {
     cv.bringSubviewToFront(belowFolderCell)
     belowIndexPath = IndexPath(row: belowIndexPath.row + photosInRow, section: belowIndexPath.section)
    }
   
    guard let menuCell = (cv.visibleCells.compactMap{ $0 as? PhotoSnippetCellProtocol }
                                              .first{ $0 !== self && $0.arrowMenuView != nil }) else { break }
    
    cv.bringSubviewToFront(menuCell)
   
   case let singleCell as PhotoSnippetCell: cv.sendSubviewToBack(singleCell)
   default: break
  }
 }
 
 func dismissArrowMenu(animated: Bool = true)
 {
  guard let arrowMenuView = arrowMenuView else { return }

  recoverCellOverlapping()
  contentView.alpha = 1.0
  
  guard animated else
  {
   arrowMenuView.removeFromSuperview()
   
   
   if ( arrowMenuSearchTag != nil )
   {
    photoSnippetVC?.dismiss(animated: false) { [weak self] in self?.arrowMenuSearchTag = nil }
   }
   self.arrowMenuView = nil
   return
  }
  
  UIView.animate(withDuration: 0.25,  delay: 0.0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: {[ weak arrowMenuView ] in
                 arrowMenuView?.transform = CGAffineTransform(scaleX: 1e-04, y: 1e-04)
                }, completion: { [ weak self, weak arrowMenuView ] _ in
                  arrowMenuView?.removeFromSuperview()
             
                  self?.arrowMenuView = nil
                  if ( self?.arrowMenuSearchTag != nil )
                  {
                   self?.photoSnippetVC?.dismiss(animated: true) { self?.arrowMenuSearchTag = nil }
                  }
                })
 }
 
 var minMenuSquareAreaSize: CGFloat { 200 }
 private var maxMenuSquareAreaSize: CGFloat { 600 }
 
 private var menuSize: CGFloat
 {
  guard let boundRect = superview?.bounds else { return maxMenuSquareAreaSize }
  let size = min(boundRect.width, boundRect.height)
  return min(max(size, minMenuSquareAreaSize), maxMenuSquareAreaSize)
 }
 
 private var menuInsetRatio: CGFloat { 1/5 }
 
 private var menuInset: UIEdgeInsets
 {
  let inset = menuInsetRatio * menuSize / 4
  return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
 }
 
 private var menuCornerRadiusRatio: CGFloat { 1/12 }
 private var menuCornerRadius: CGFloat { menuCornerRadiusRatio * menuSize / 4 }
 
 private var menuInterButtonMarginRatio: CGFloat { 1/15 }
 private var menuInterButtonMargin: CGFloat { menuInterButtonMarginRatio * menuSize / 4 }
 
 
 private var isMenuVisible: Bool
 {
  guard let boundRect = superview?.bounds else { return false }
  let size = min(boundRect.width, boundRect.height)
  return size >= minMenuSquareAreaSize
 }
 
 
 private var menuCenterShift: CGPoint
 {
  guard let tp = hostedItem?.arrowMenuTouchPoint else { return .zero }
  print (tp)
  let w = bounds.width
  let h = bounds.height
  let dx = w * (tp.x - 1/2)
  let dy = h * (tp.y - 1/2)
  return CGPoint(x: dx, y: dy)
 }
 
 private var menuShift: CGPoint
 {
  guard let shift = hostedItem?.arrowMenuPosition else { return .zero }
  let l = menuSize
  let dx = l * (shift.x - 0.75)
  let dy = l * (shift.y - 0.75)
  return CGPoint(x: dx, y: dy)
 }
 
 
 func showArrowMenu(animated: Bool = true)
 {
  guard arrowMenuView == nil else { return }
  guard isMenuVisible else { return }
  
  hostedItem?.terminate()
 
  let buttons = [
   ImageMenuButton(systemName: "flag")
   { [weak self] in
    guard let menu = self?.arrowMenuView else { return }
    menu.activitySubject.onNext(())
    
    let oldButtons = menu.buttons
    menu.buttons = UIColor.priorityColorMap.keys.map
    {color in
     DrawFlagMenuButton(fillColor: color)
     {[weak menu] in
      menu?.activitySubject.onNext(())
      self?.hostedItem?.priorityFlagColor = color
     }
    } +
    [
     ImageMenuButton(systemName: "return")
     { [weak menu] in
      menu?.activitySubject.onNext(())
      menu?.buttons = oldButtons
      
     },
     
     ImageMenuButton(systemName: "flag.slash.fill", imageTintColor: #colorLiteral(red: 0.877603054, green: 0.877603054, blue: 0.877603054, alpha: 1))
     { [weak self, weak menu] in
      menu?.activitySubject.onNext(())
      self?.hostedItem?.priorityFlagColor = nil
     },
    
     ImageMenuButton(systemName: "xmark") { [weak self] in self?.hostedItem?.isArrowMenuShowing = false }
    ]
    
 
   },
   
   
   ImageMenuButton(systemName: "flag.slash")
   { [weak self] in
    self?.arrowMenuView?.activitySubject.onNext(())
    self?.hostedItem?.priorityFlagColor = nil
   },
   
   ImageMenuButton(systemName: "tag")
   { [weak self] in
    guard let hostedItem = self?.hostedItem else { return }
    guard let menu = self?.arrowMenuView else { return }
    menu.activitySubject.onNext(())
    let menuBag = menu.disposeBag
    
    let ac = UIAlertController(title: Localized.tagPhotoItem, message: nil, preferredStyle: .alert)
    
    var textFieldDisposable: Disposable?
    var okDisposable:        Disposable?
    
    let ok = UIAlertAction(title: Localized.changeAction, style: .destructive)
    { [weak menu] _ in
     menu?.activitySubject.onNext(())
     hostedItem.searchTag = ac.textFields?.first?.text
     textFieldDisposable?.dispose()
     okDisposable?.dispose()
    }
    
    //ok.isEnabled = false
  
    ac.addTextField
    {textField in
     textField.borderStyle = .none
     textField.font = UIFont.boldSystemFont(ofSize: 12)
     textField.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
     textField.clearButtonMode = .whileEditing
     textField.text = hostedItem.searchTag
     
     okDisposable = textField.rx.text
      .orEmpty
      .map{!$0.isEmpty}
      .startWith(false)
      .debug()
      .bind(to: ok.rx.isEnabled)
     
     okDisposable?.disposed(by: menuBag)
     
     textFieldDisposable = textField.rx
      .controlEvent(.editingChanged)
      .debug()
      .bind(to: menu.activitySubject)
     
     textFieldDisposable?.disposed(by: menuBag)
    }
    
    ac.addAction(ok)
    
    let cancel = UIAlertAction(title: Localized.cancelAction, style: .cancel)
    {[weak menu] _ in
     menu?.activitySubject.onNext(())
     textFieldDisposable?.dispose()
     okDisposable?.dispose()
    }
    
    ac.addAction(cancel)
    
    self?.arrowMenuSearchTag = ac
    self?.photoSnippetVC?.present(ac, animated: true, completion: nil)
    
   },
   
   ImageMenuButton(systemName: "arrowshape.turn.up.left") {},
   ImageMenuButton(systemName: "arrowshape.turn.up.left.2") {},
   ImageMenuButton(systemName: "arrowshape.turn.up.left.2", mirrowed: true) {},
   ImageMenuButton(systemName: "arrowshape.turn.up.right") {},
   
   ImageMenuButton(systemName: "trash") { [weak self] in self?.hostedItem?.deleteFromContext()        },
   ImageMenuButton(systemName: "xmark") { [weak self] in self?.hostedItem?.isArrowMenuShowing = false }
  
  ]
  
  
  superview?.bringSubviewToFront(self)
  contentView.alpha = 0.5
 
  let menu = PointedMenuView(bounder: superview,
                             menuInset: menuInset,
                             shift: menuShift,
                             menuCornerRadius: menuCornerRadius,
                             interButtonMargin: menuInterButtonMargin,
                             buttons: buttons,
                             activityTimeout: .seconds(5))
                             {[weak self] in
                              self?.hostedItem?.searchTag = self?.arrowMenuSearchTag?.textFields?.first?.text
                              self?.hostedItem?.isArrowMenuShowing = false
           
                             }
                      
  
  menu.$menuPosition.filter{ $0 != .zero }.sink
  { [unowned self] in
    self.hostedItem?.arrowMenuPosition = $0
  }.store(in: &menu.cancellables)
  
  addSubview(menu)
  
  menu.translatesAutoresizingMaskIntoConstraints = false
  
//  let xc = menu.centerXAnchor.constraint(equalTo: centerXAnchor, constant: menuCenterShift.x)
//  let yc = menu.centerYAnchor.constraint(equalTo: centerYAnchor, constant: menuCenterShift.y)
  
  let shiftX = hostedItem?.arrowMenuTouchPoint.x ?? 0.5
  let xc = NSLayoutConstraint(item: menu,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: self,
                              attribute: .centerX,
                              multiplier: 2 * shiftX,
                              constant: 0)
  
  let shiftY = hostedItem?.arrowMenuTouchPoint.y ?? 0.5
  let yc = NSLayoutConstraint(item: menu,
                              attribute: .centerY,
                              relatedBy: .equal,
                              toItem: self,
                              attribute: .centerY,
                              multiplier: 2 * shiftY,
                              constant: 0)
  
  let wc = menu.widthAnchor.constraint (equalToConstant: menuSize)
  let hc = menu.heightAnchor.constraint(equalToConstant: menuSize)
  
  NSLayoutConstraint.activate([xc, yc, wc, hc])
 
  //print(menu.frame)
  
  if animated
  {
   menu.transform = CGAffineTransform(scaleX: 0, y: 0)
   
   UIView.animate(withDuration: 0.5, delay: 0.0,
                  usingSpringWithDamping: 0.5,
                  initialSpringVelocity: 0.5,
                  options: [.curveEaseInOut],
                  animations: { menu.transform = .identity},
                  completion: {_ in })
  }
  
  self.arrowMenuView = menu
  

 }
 

 
 
 
 
}
