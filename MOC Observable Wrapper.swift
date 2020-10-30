//
//  MOC Observable.swift
//  Newsman
//
//  Created by Anton2016 on 26.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import RxSwift
import Combine
import CoreData

@propertyWrapper struct ContextObservable<T: NSManagedObject>
{
 private weak var object: T?
 
 var wrappedValue: T? { get { object } set { object = newValue } }
 
 init (wrappedValue: T? = nil) { object = wrappedValue }
 
 var projectedValue: Observable<NSManagedObjectContext>
 {
  guard let object = self.object else { return .empty() }
  return Observable.just(object.managedObjectContext).map
  {context -> NSManagedObjectContext in
   guard let context = context else { throw MOCError.noContext(for: object) }
   return context
  }
 }
 
}

enum MOCError<T: NSManagedObject>: Error
{
 case noContext(for: T)
 case contextSaveFailure
 case unknown
}




