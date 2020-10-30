//
//  App MOC Saver.swift
//  Newsman
//
//  Created by Anton2016 on 31.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import CoreData

extension NotificationCenter
{
 static func contextDidChangeObservable(for context: NSManagedObjectContext) -> Observable<Notification>
 {
  Observable<Notification>.create {observer in
   let token = Self.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: nil)
   {
    observer.onNext($0)
   }
   return Disposables.create { Self.default.removeObserver(token) }
  }
 }
}

extension AppDelegate
{
//**************************************************************************************
 final func contextChangePublisher(for context: NSManagedObjectContext) -> AnyPublisher<AppCloudData.UserInfoType, Never>
//**************************************************************************************
 {
  NotificationCenter.default
   .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
   .compactMap{ $0.userInfo }
   .filter{ userInfo in
     let inserted = Array(userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? [])
     let updated =  Array(userInfo[NSUpdatedObjectsKey]  as? Set<NSManagedObject> ?? [])
                    .filter{!$0.changedValuesForCurrentEvent().isEmpty}
     let deleted =  Array(userInfo[NSDeletedObjectsKey]  as? Set<NSManagedObject> ?? [])
     return !(inserted + updated + deleted).isEmpty
    }
   .share()
   .eraseToAnyPublisher()
 }
//******************** final var contextChangePublisher *******************************
 

//**************************************************************************************
 final func contextSavePublisher(for context: NSManagedObjectContext) -> AnyPublisher<Never, Error>
//**************************************************************************************
 {
  contextChangePublisher(for: context)
   .debounce(for: .seconds(10.0), scheduler: DispatchQueue.main) //.print(#function)
   .setFailureType(to: Error.self)
   .flatMap{ [unowned context] _ in context.saveContextPublisher }
   .ignoreOutput()
   .eraseToAnyPublisher()
 }
 
 
 final func subscribeSaveContextPublisher(for context: NSManagedObjectContext)
 {
  contextSavePublisher(for: context)
   .sink(receiveCompletion: {_ in}, receiveValue: {_ in})
   .store(in: &cancellables)
 }
 
//**************************************************************************************
 final func contextSaveUpdatesObservable(for context: NSManagedObjectContext) -> Observable<Never>
//**************************************************************************************
 {
  NotificationCenter
   .contextDidChangeObservable(for: viewContext)
   .debounce(.seconds(10), scheduler: MainScheduler.instance)
   .flatMap{_ in context.persistAllChanges() }
 }
  
 final func subscribeSaveContextObservable(for context: NSManagedObjectContext)
 {
  contextSaveUpdatesObservable(for: context).subscribe().disposed(by: disposeBag)
 }
 
 
 final func configueSaveContextObservation()
 {
  subscribeSaveContextPublisher(for: viewContext)
 }
 
//**************************************************************************************
 final var backgroundContextSaveUpdatesPublisher: AnyPublisher<Void, Error>
//**************************************************************************************
 {
  contextChangePublisher(for: viewContext)
   .compactMap{ ($0[NSUpdatedObjectsKey] as? NSSet)?.allObjects as? [NSManagedObject] }
   .flatMap { $0.publisher.filter{ $0.hasPersistentChangedValues } }
   .collect(.byTimeOrCount(DispatchQueue.main, .seconds(6), 50))
   .map { Set($0) }
   .setFailureType(to: Error.self)
   .flatMap{ [unowned self] objects -> AnyPublisher<Void, Error> in
     let objectsIDs = objects.map{ $0.objectID }
     let changes = objects.map{$0.changedValues()}
     return self.backgroundContext.persist
     {
      zip(objectsIDs, changes).forEach
      {objectID, dict in
       let object = self.backgroundContext.object(with: objectID)
       dict.forEach
       {key, value in
        object.setValue(value, forKey: key)
       }
      }
     }
   }
   .eraseToAnyPublisher()
 }
//**************** final var backgroundContextSaveUpdatesPublisher ********************
 
 
  
//**************************************************************************************
 final var backgroundContextsSaveMergePublisher: AnyPublisher<Never, Never>
//**************************************************************************************
 {
  NotificationCenter.default
   .publisher(for: .NSManagedObjectContextDidSave)
   .filter{ ($0.object as? NSManagedObjectContext)?.concurrencyType == .privateQueueConcurrencyType }
   .handleEvents(receiveOutput:
    { notification in
     let mainContext = self.persistentContainer.viewContext
     mainContext.perform {
      mainContext.mergeChanges(fromContextDidSave: notification)
     }
    })
   .ignoreOutput()
   .eraseToAnyPublisher()
 } //********************* final var backgroundContextsSaveMergePublisher **************
 
}
