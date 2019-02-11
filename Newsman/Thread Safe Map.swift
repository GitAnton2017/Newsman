//
//  Thread Safe Map.swift
//  Newsman
//
//  Created by Anton2016 on 09/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

class SafeMap<H: Hashable, T>
{
 let isq = DispatchQueue.global(qos: .userInitiated)// Isolation Dispatch Queue
 
 private var map: [H : T] = [:] //internal map
 
 subscript (key: H) -> T?
 {
  get {return isq.sync {return map[key]}}
  set {isq.async(flags: .barrier) {self.map[key] = newValue}
  }
 }
 
 func filter (predicate: ((key: H, value: T)) -> Bool) -> [H : T]
 {
  return isq.sync {return map.filter(predicate)}
 }
 
 func forEach(body: @escaping ((key: H, value: T)) -> ())
 {
  isq.async(flags: .barrier) {self.map.forEach(body)}
 }
 
 var values: Dictionary<H, T>.Values {return isq.sync {return map.values}}
 var pairs:  Dictionary<H, T>        {return isq.sync {return map}}
 
 
}
