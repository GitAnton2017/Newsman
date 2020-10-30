//
//  Collection Wrappers.swift
//  Newsman
//
//  Created by Anton2016 on 12.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import class Combine.AnyCancellable

protocol WeakCollection: Collection
{
 init(weakArray: [() -> Self.Element?])
}


extension Array: WeakCollection
{
 init(weakArray: [() -> Element?])
 {
  self.init(weakArray.compactMap{$0()})
 }
}

extension Set: WeakCollection
{
 init(weakArray: [() -> Element?])
 {
  self.init(weakArray.compactMap{$0()})
 }
}


@propertyWrapper class Weak<T: WeakCollection> where T.Element: AnyObject
{
 
 private final var cnxx = Set<AnyCancellable>()
 
 private final var weakArray: [() -> T.Element?]

 
 final var projectedValue: [() -> T.Element?] { weakArray }
 
 final var wrappedValue: T
 {
  get { T(weakArray: weakArray) }
  set { weakArray = newValue.map{ (element: T.Element) in {[weak element] in element} }
  }
 }
 
 private final func compact()
 {
  weakArray = weakArray.filter{ $0() != nil }
 }
 
 private final func sheduleCompact(_ cleanInterval: TimeInterval = 10.0)
 {
  guard cleanInterval > 0 else { return }
  Timer.publish(every: cleanInterval, on: RunLoop.main, in: .common)
   .autoconnect()
   .sink{[unowned self] _ in self.compact()}
   .store(in: &cnxx)
 }
 
 init(cleanInterval: TimeInterval)
 {
  self.weakArray = []
  self.sheduleCompact(cleanInterval)
 }
 
 init (wrappedValue: T, cleanInterval: TimeInterval = 10.0)
 {
  self.weakArray = wrappedValue.map{ (element: T.Element) in {[weak element] in element} }
  self.sheduleCompact(cleanInterval)
 }
}
