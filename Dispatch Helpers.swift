//
//  Dispatch Helpers.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation

enum BatchError<K, E>: Error where K: Hashable, E: Error
{
 case batchFailures([K: E])
}

extension DispatchGroup
{
 func performBatchTask<T: Sequence>(batch: T,
                                    completionQueue: DispatchQueue = .main,
                                    asyncTask: (T.Element, @escaping () -> ()) -> (),
                                    completion: (() -> ())? = nil )
 {
  defer { self.notify(queue: completionQueue, execute: { completion?() })}
  batch.forEach
  {item in
   self.enter()
   asyncTask(item) { self.leave() }
  }
 }
 
 func performBatchTask<T: Sequence>(batch: T,
                                    queue: DispatchQueue = .global(),
                                    completionQueue: DispatchQueue = .main,
                                    syncTask: @escaping (T.Element) -> (),
                                    completion:(() -> ())? = nil )
 {
  let group = DispatchGroup()
  defer { self.notify(queue: completionQueue, execute: { completion?() })}
  batch.forEach
  {item in
   queue.async(group: group) { syncTask(item) }
  }
 }
 

 
 func performBatchTask<T: Sequence, S, E: Error>(batch: T,
                                    queue: DispatchQueue = .global(),
                                    completionQueue: DispatchQueue = .main,
                                    syncTask: @escaping (T.Element) -> Result<S, E>,
                                    completion: @escaping ([T.Element: E]) -> ())
                                    where T.Element: Hashable
 {
  var results: [T.Element : E] = [:]
  let group = DispatchGroup()
  defer
  {
   notify(queue: completionQueue) { completion(results) }
  }
  
  batch.forEach
  {item in
   queue.async(group: group)
   {
    let result = syncTask(item)
    DispatchQueue.main.async
    {
     if case let .failure(e) = result {results[item] = e}
    }
   }
  }
 }
 
 
 
 func performBatchTask<T: Sequence>(batch: T,
                                    completionQueue: DispatchQueue = .main,
                                    asyncTask: (T.Element, Int, @escaping () -> ()) -> (),
                                    completion: @escaping () -> ())
 {
  defer { self.notify(queue: completionQueue, execute: completion)}
  batch.enumerated().forEach
  {item in
   self.enter()
   asyncTask(item.element, item.offset) { self.leave() }
  }
 }
 
 
 
}




