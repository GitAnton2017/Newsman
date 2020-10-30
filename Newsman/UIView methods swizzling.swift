//
//  UIView methods swizzling.swift
//  Newsman
//
//  Created by Anton2016 on 20.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

extension UIView
{
 static func observeSuperview() { let _ = didMoveToSuperviewSwizzling }
 
 private static let didMoveToSuperviewSwizzling: Void = {

   guard
    let originalMethod = class_getInstanceMethod(UIView.self, #selector(didMoveToSuperview)),
    let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_didMoveToSuperview))
   else { return }
   
   method_exchangeImplementations(originalMethod, swizzledMethod)
  
 }()
 
 @objc private final func swizzled_didMoveToSuperview()
 {
  guard self.superview != nil else { return }
  willChangeValue(for: \.superview)
  didChangeValue(for: \.superview)

 }
}
