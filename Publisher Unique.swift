//
//  Publisher Extensions.swift
//  Newsman
//
//  Created by Anton2016 on 04.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Combine

extension Publisher where Self.Output: Hashable
{
 typealias UniqueCollectedByTime<S: Scheduler> = Publishers.Map<Publishers.CollectByTime<Self, S>, [Self.Output]>
 typealias UniqueCollectedByCount = Publishers.Map<Publishers.CollectByCount<Self>, [Self.Output]>
 typealias UniqueCollected = Publishers.Map<Publishers.Collect<Self>, [Self.Output]>
 
 
 var unique: Publishers.Filter<Self>
 {
  var buffer = Set<Self.Output>()
  return filter{ buffer.insert($0).inserted }
 }
 
 func collect<S>(_ strategy: Publishers.TimeGroupingStrategy<S>, unique: Bool) -> UniqueCollectedByTime<S>
 {
  collect(strategy).map{unique ? Array(Set($0)) : $0}
 }
 
 func collect(_ count: Int, unique: Bool) -> UniqueCollectedByCount
 {
  collect(count).map{unique ? Array(Set($0)) : $0}
 }

 func collect(unique: Bool) -> UniqueCollected
 {
  collect().map{unique ? Array(Set($0)) : $0}
 }

}

extension Publisher
{
 typealias TComparator = (Self.Output, Self.Output) throws -> Bool
 typealias TryUniqueCollectedByTime<S: Scheduler> = Publishers.TryMap<Publishers.CollectByTime<Self, S>, [Self.Output]>
 typealias TryUniqueCollectedByCount = Publishers.TryMap<Publishers.CollectByCount<Self>, [Self.Output]>
 typealias TryUniqueCollected = Publishers.TryMap<Publishers.Collect<Self>, [Self.Output]>
 
 func uniqueBy(_ comparator: @escaping TComparator) -> Publishers.TryFilter<Self>
 {
  var buffer = [Self.Output]()
  return tryFilter
  {element in
   if (try buffer.contains{ try comparator($0, element)}) { return false }
   buffer.append(element)
   return true
  }
 }
 
 
 func collect<S>(_ strategy: Publishers.TimeGroupingStrategy<S>,
                 uniqueBy: @escaping TComparator) -> TryUniqueCollectedByTime<S>
 {
  collect(strategy).tryMap {collection in
   var buffer = [Self.Output]()
   for element in collection
   {
    if (try buffer.contains{ try uniqueBy($0, element)}) { continue }
    buffer.append(element)
   }
   return buffer
  }
 }
 
 func collect(_ count : Int, uniqueBy: @escaping TComparator) -> TryUniqueCollectedByCount
 {
  collect(count).tryMap {collection in
   var buffer = [Self.Output]()
   for element in collection
   {
    if (try buffer.contains{ try uniqueBy($0, element)}) { continue }
    buffer.append(element)
   }
   return buffer
  }
 }
 
 func collect(uniqueBy: @escaping TComparator) -> TryUniqueCollected
 {
  collect().tryMap {collection in
   var buffer = [Self.Output]()
   for element in collection
   {
    if (try buffer.contains{ try uniqueBy($0, element)}) { continue }
    buffer.append(element)
   }
   return buffer
  }
 }
}



