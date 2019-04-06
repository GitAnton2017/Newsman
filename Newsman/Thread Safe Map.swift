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
 //let isq = DispatchQueue.global(qos: .userInitiated)// Isolation Dispatch Queue
 // barriers are not appllied for global queues!
 
 let isq = DispatchQueue(label: "SafeMap.isolation.queue", attributes: .concurrent)
 // the isolation dispatch queue must be by all means private concurrent queue otherwise
 // dispatching any task with barrier flag has no effect.
 
 /* Calls to Q.async(flags: .barrier){...} always return immediately after the block has been submitted and never wait for the block to be invoked. When the barrier block reaches the front of a private concurrent queue, it is not executed immediately. Instead, the queue waits until its currently executing blocks finish executing. At that point, the barrier block executes by itself. Any blocks submitted after the barrier block are not executed until the barrier block completes.
 
 The queue you specify should be a <<<<concurrent queue that you create yourself>>> using the dispatch_queue_create function. If the queue you pass to this function is a serial queue or one of the global concurrent queues, this function behaves like the dispatch_async function == Q.async {...} with no barrier execution!!! */
 
 private var map: [H : T] = [ : ] //internal map
 
 subscript (key: H) -> T?
 {
  get
  {
   return isq.sync { return map[key] }
  }
  
  set
  {
   isq.async(flags: .barrier)
   {
    self.map[key] = newValue
   }
  }
 }
 
 func filter (predicate: ((key: H, value: T)) -> Bool) -> [H : T]
 {
  return isq.sync {return map.filter(predicate)}
 }
 
 func forEach(body: @escaping ((key: H, value: T)) -> ())
 {
  isq.async(flags: .barrier)
  {
   self.map.forEach(body)
  }
 }
 
 var values: Dictionary<H, T>.Values
 {
  return isq.sync {return map.values}
 }
 
 
 var pairs:  Dictionary<H, T>
 {
  return isq.sync {return map}
 }
 
 
}
