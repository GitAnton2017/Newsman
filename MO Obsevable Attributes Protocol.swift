//
//  MO Osevable Attributes Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 27.11.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectContext

import class RxSwift.Observable

import struct Combine.Just
import struct Combine.Fail
import struct Combine.AnyPublisher


enum ManagedObjectError: Error
{
 case noContext (for: NSManagedObject)
 case noObjectID (for: NSManagedObject)
 case noObjectURL (for: NSManagedObject)
 case noDateTimeStamp (for: NSManagedObject)
 case noSnippet (for: NSManagedObject)
 case deleteFailure(at: URL, description: String)
 case moveFailure(from: URL, to: URL, description: String)
 case contextSaveFailure(description: String)
 case notSingleItemFolder
 case emptyFolder
 case unknown
}

// ************************ SNIPPET  *******************************

protocol OptionallySnippetRepsentable
{
 associatedtype SnippetType
 var owner: SnippetType? { get }
 
}//protocol OptionallySnippetRepsentable...


extension OptionallySnippetRepsentable where Self: NSManagedObject
{
 private var get_owner: SnippetType?
 {
  var owner: SnippetType?
  managedObjectContext?.performAndWait { owner = self.owner }
  return owner
 }//private var get_date: SnippetType?...
 
 var SNIPPET$: Observable<SnippetType> //RxSwift DateTimeStamp observable...
 {
  Observable.just(get_owner).map {owner -> SnippetType in
   guard let owner = owner else { throw ManagedObjectError.noSnippet(for: self) }
   return owner
  }
 }//var DATE$: Observable<SnippetType>...
 
 var SNIPPET$$: AnyPublisher<SnippetType, ManagedObjectError> //Combine DateTimeStamp publisher...
 {
  Just(get_owner).tryMap { owner -> SnippetType in
   guard let owner = owner else { throw ManagedObjectError.noSnippet(for: self) }
   return owner
  }
  .mapError{ ($0 as? ManagedObjectError) ?? .unknown }
  .eraseToAnyPublisher()
 }//var DATE$$: AnyPublisher<SnippetType, ManagedObjectError>...
 
}//extension OptionallySnippetRepsentable...

// ************************ SNIPPET  *******************************




// ************************ DATE TIME STAMP ************************

protocol OptionallyDateTimeRepsentable
{
 associatedtype DateTimeType
 var date: DateTimeType? { get set }
 
}//protocol OptionallyDateTimeRepsentable...


extension OptionallyDateTimeRepsentable where Self: NSManagedObject
{
 private var get_date: DateTimeType?
 {
  var date: DateTimeType?
  managedObjectContext?.performAndWait { date = self.date }
  return date
 }//private var get_date: DateTimeType?...
 
 var DATE$: Observable<DateTimeType> //RxSwift DateTimeStamp observable...
 {
  Observable.just(get_date).map {date -> DateTimeType in
   guard let date = date else { throw ManagedObjectError.noDateTimeStamp(for: self) }
   return date
  }
 }//var DATE$: Observable<DateTimeType>...
 
 var DATE$$: AnyPublisher<DateTimeType, ManagedObjectError> //Combine DateTimeStamp publisher...
 {
  Just(get_date).tryMap { id -> DateTimeType in
   guard let id = id else { throw ManagedObjectError.noDateTimeStamp(for: self) }
   return id
  }
  .mapError{ ($0 as? ManagedObjectError) ?? .unknown }
  .eraseToAnyPublisher()
 }//var DATE$$: AnyPublisher<DateTimeType, ManagedObjectError>...
 
}//extension OptionallyDateTimeRepsentable...
// ************************ DATE TIME STAMP ************************



// ************************ ID *************************************
protocol OptionallyIdentifiable
{
 
 associatedtype IdentityType
 var id: IdentityType? { get set }
 
}//protocol OptionallyIdentifiable

extension OptionallyIdentifiable where Self: NSManagedObject
{
 private var get_id: IdentityType?
 {
  var id: IdentityType?
  managedObjectContext?.performAndWait { id = self.id }
  return id
 }
 
 var ID$: Observable<IdentityType> //RxSwift ID observable...
 {
  Observable.just(get_id).map {id -> IdentityType in
   guard let id = id else { throw ManagedObjectError.noObjectID(for: self) }
   return id
  }
 }
 
 var ID$$: AnyPublisher<IdentityType, ManagedObjectError> //Combine ID publisher...
 {
  Just(get_id).tryMap { id -> IdentityType in
   guard let id = id else { throw ManagedObjectError.noObjectID(for: self) }
   return id
  }
  .mapError{ ($0 as? ManagedObjectError) ?? .unknown }
  .eraseToAnyPublisher()
 }
}//extension OptionallyIdentifiable where...

// ************************ ID *************************************



// ************************ URL ************************************
protocol InternalDataManageable
{
 var url: URL? { get }
 
}//protocol InternalDataManageable...

extension InternalDataManageable where Self: NSManagedObject & OptionallyIdentifiable
{
 private var get_url: URL?
 {
  var url: URL?
  managedObjectContext?.performAndWait { url = self.url }
  return url
 }
 
 var URL$: Observable<URL> //RxSwift URL observable...
 {
  guard let url = get_url else { return .error(ManagedObjectError.noObjectURL(for: self)) }
  return .just(url)
 }
 
 
 var URL$$: AnyPublisher<URL, ManagedObjectError> //Combine URL publisher...
 {
  guard let url = get_url else
  {
   return Fail<URL, ManagedObjectError>(error: .noObjectURL(for: self)).eraseToAnyPublisher()
  }
  return Just(url).setFailureType(to: ManagedObjectError.self).eraseToAnyPublisher()
 }
 
}//extension InternalDataManageable...

// ************************ URL ************************************



// ************************ FOLDER *********************************
protocol AnyFolderEntity
{
 
 associatedtype ItemType: Folderable
 var folderedItems: [ItemType] { get }
 
}//protocol AnyFolderEntity...

extension AnyFolderEntity where Self: NSManagedObject
{
 var SINGLE$: Observable<ItemType> //RxSwift single item observable...
 {
  if ( folderedItems.count > 1 ) { return .error(ManagedObjectError.notSingleItemFolder) }
  
  return Observable.just(folderedItems.first).map{ singleItem -> ItemType in
   guard let singleItem = singleItem else { throw ManagedObjectError.emptyFolder }
   return singleItem
  }
 }
 
 var SINGLE$$: AnyPublisher<ItemType, ManagedObjectError> //Combine single item publisher...
 {
  if ( folderedItems.count > 1 ) { return Fail(error: .notSingleItemFolder).eraseToAnyPublisher() }
  
  return Just(folderedItems.first).tryMap{ singleItem -> ItemType in
   guard let singleItem = singleItem else { throw ManagedObjectError.emptyFolder }
   return singleItem
  }
  .mapError{ ($0 as? ManagedObjectError) ?? .unknown }
  .eraseToAnyPublisher()
 }
}//extension AnyFolderEntity...

// ************************ FOLDER *********************************




// ************************ FOLDERED *******************************
protocol Folderable
{
 
 associatedtype FolderType: AnyFolderEntity
 var folder: FolderType? { get set }
 
}//protocol Folderable...


extension Folderable where Self: NSManagedObject
{
 private var get_folder: FolderType?
 {
  var folder: FolderType?
  managedObjectContext?.performAndWait { folder = self.folder }
  return folder
 }
 
 var FOLDER$: Observable<FolderType?> { .just(get_folder) } //RsSwift folder observable...
 
 var FOLDER$$: AnyPublisher<FolderType?, ManagedObjectError> //Combine folder publisher...
 {
  Just(get_folder).mapError{_ in .unknown}.eraseToAnyPublisher()
 }
}//extension Folderable where...

// ************************ FOLDERED *******************************




// ***************************** MOC *******************************

protocol ManagedObjectContextObservable {}

extension ManagedObjectContextObservable where Self:  NSManagedObject
{
 var MOC$: Observable<NSManagedObjectContext> //RxSwift MOC observable
 {
  Observable.just(self.managedObjectContext).map {context -> NSManagedObjectContext in
   guard let context = context else { throw ManagedObjectError.noContext(for: self) }
   return context
  }
 }
 

 
 var MOC$$:  AnyPublisher<NSManagedObjectContext, ManagedObjectError> //Combine MOC Publisher...
 {
  Just(self.managedObjectContext).tryMap {[unowned self] context -> NSManagedObjectContext in
   guard let context = context else { throw ManagedObjectError.noContext(for: self) }
   return context
  }
  .mapError{ ($0 as? ManagedObjectError) ?? .unknown }
  .eraseToAnyPublisher()
 }//extension ManagedObjectContextObservable....
 
}

// ***************************** MOC *******************************






