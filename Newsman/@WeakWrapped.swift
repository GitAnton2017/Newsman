//
//  @WeakWrapped.swift
//  Newsman
//
//  Created by Anton2016 on 20.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

@propertyWrapper final class WeakWrapped<T: UIView>:  Decoratable
{
 var decoratedView: UIView? { wrapped?.decoratedView }
 
 private final weak var wrapped: T?
 {
  didSet
  {
   guard let newView = wrapped else { return }
   NotificationCenter.default.post(name: .decoratedViewDidChange, object: newView)
  }
 }
 
 final var wrappedValue: T?
 {
  get { wrapped }
  set { wrapped = newValue }
 }
 
 init (wrappedValue: T?) { wrapped = wrappedValue }
 
 init () { wrapped = nil }
 
 
}//@propertyWrapper class Weak...


