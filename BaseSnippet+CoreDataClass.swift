//
//  BaseSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit
import CoreLocation


protocol SnippetImagesPreviewProvidable: class
{
 var imageProvider: SnippetPreviewImagesProvider {get}
}

@objc(BaseSnippet) public class BaseSnippet: NSManagedObject
{
 
 final func isHiddenSection(groupType: GroupSnippets, for newValue: String) -> Bool
 {
  let frq: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  let selfTypePred = NSPredicate(format: "SELF.type == %@.type", self)
  let notSelfPred  = NSPredicate(format: "SELF <> %@",           self)
 
  
  if let keyPath = GroupSnippets.groupingKeyPath[groupType]
  {
   let keyPathPred = NSPredicate(format: "%K == %@", keyPath, newValue)
   frq.predicate = NSCompoundPredicate(type: .and, subpredicates: [keyPathPred, selfTypePred, notSelfPred])
  }
  else
  {
   frq.predicate = NSCompoundPredicate(type: .and, subpredicates: [selfTypePred, notSelfPred])
  }
  
  let fetch = (try? managedObjectContext?.fetch(frq) ?? []) ?? []
 
  return fetch.isEmpty ? false : fetch.allSatisfy{ $0[groupType] }
 }
 
 final func isHiddenSection(groupType: GroupSnippets, predicate: (BaseSnippet) -> Bool ) -> Bool
 {
  guard let allObjects = self.managedObjectContext?.registeredObjects else { return false }
  return allObjects.compactMap{$0 as? BaseSnippet}.filter{$0 !== self && predicate($0)}.allSatisfy{$0[groupType]}
 }
 
 weak var currentFRC: SnippetsFetchController?
 //the weak ref to current FRC wrapper that fetched and manages this Snippet

 func initStorage(){} //Polymorphic method to intialize virtual type of storage for concrete snippet type.
 
 static var snippetDates = SnippetDates()

 @NSManaged private (set) var date: NSDate?
 @NSManaged var dateIndex: String?
 
 final var snippetDate: Date
 {
  get {return self.date! as Date}
  set
  {
   self.date = newValue as NSDate
   self.dateIndex = BaseSnippet.snippetDates.datePredicates.first{$0.predicate(self)}?.title
   //self[.byDateCreated] = isHiddenSection(groupType: .byDateCreated){ $0.dateIndex == self.dateIndex }
   self[.byDateCreated] = isHiddenSection(groupType: .byDateCreated, for: self.dateIndex!)
  }
 }
 
 final var snippetDateTag: String {return SnippetsViewDataSource.dateFormatter.string(from: self.snippetDate)}
 
 @NSManaged private (set) var tag: String?
 @NSManaged var  alphaIndex: String?
 
 final var snippetName: String
 {
  get
  {
   guard let tag = self.tag else {return Localized.unnamedSnippet}
   return tag.isEmpty ? Localized.unnamedSnippet : tag
  }
  set
  {
   self.tag = newValue
   self.alphaIndex = newValue.isEmpty ? newValue : String(newValue.first!)
   //self[.alphabetically] = isHiddenSection(groupType: .alphabetically){ $0.alphaIndex == self.alphaIndex }
   self[.alphabetically] = isHiddenSection(groupType: .alphabetically, for: self.alphaIndex!)
  }
 }
 
 @NSManaged private (set) var status: String?
 
 final var snippetStatus: SnippetStatus
 {
  get
  {
   guard let snippetStatus = self.status else
   {
    print("WARNING! Snippet ID: \(self.id?.uuidString ?? "NIL") with undefined (NIL) status is encountered in store!")
    return .new
   }
   
   return SnippetStatus(rawValue: snippetStatus)!
  }
  
  set {self.status = newValue.rawValue}
  
 }
 
 @NSManaged private (set) var type: String?
 
 final var snippetType: SnippetType
 {
  get
  {
   guard let snippetType = self.type else
   {
    print("WARNING! Snippet ID: \(self.id?.uuidString ?? "NIL") with undefined (NIL) type is encountered in store!")
    return .undefined
   }
   
   return SnippetType(rawValue: snippetType)!
  }
  
  set
  {
   self.type = newValue.rawValue
   //self[.bySnippetType] = isHiddenSection(groupType: .bySnippetType){ $0.snippetType == newValue }
   self[.bySnippetType] = isHiddenSection(groupType: .bySnippetType, for: newValue.rawValue)
  }
  
 }
 
 @NSManaged private (set) var priority: String?
 @NSManaged var priorityIndex: String?
 
 final var snippetPriority: SnippetPriority
 {
  get
  {
   guard let snippetPriority = self.priority else
   {
    print("WARNING! Snippet ID: \(self.id?.uuidString ?? "NIL") with undefined (NIL) priority is encountered in store!")
    return .normal
   }
   return SnippetPriority(rawValue: snippetPriority)!
  }
  
  set
  {
   self.priority = newValue.rawValue
   self.priorityIndex = String(snippetPriorityIndex) + "_" + newValue.rawValue
   //self[.byPriority] = isHiddenSection(groupType: .byPriority) { $0.snippetPriority ==  newValue }
   self[.byPriority] = isHiddenSection(groupType: .byPriority, for: newValue.rawValue)
  }

 }
 
// final func setPriority(to newPriority: SnippetPriority)
// {
//  guard let frc = self.currentFRC else { return }
//  guard frc.groupType == .byPriority else
//  {
//   frc.moc.persist{ self.snippetPriority = newPriority }
//   return
//  }
//
//  frc.deactivateDelegate()
//  frc.moc.persistAndWait(block: { self.snippetPriority = newPriority })
//  {flag in
//
//   guard flag else
//   {
//    frc.activateDelegate()
//    return
//   }
//
//   frc.refetch()
//   frc.updateSectionCounters()
//   frc.tableView.reloadData()
//   frc.activateDelegate()
//  }
// }
 
 final var snippetPriorityIndex: Int {return SnippetPriority.prioritySectionsMap[snippetPriority]!}
 
 @NSManaged private (set) var latitude: Double
 @NSManaged private (set) var logitude: Double
 
 final var snippetCoordinates: CLLocation?
 {
  get {return CLLocation(latitude: self.latitude, longitude: self.logitude)}
  set
  {
   self.latitude = newValue?.coordinate.latitude  ?? 0.0
   self.logitude = newValue?.coordinate.longitude ?? 0.0
  }
 }
 
 @NSManaged private(set) var location: String?
 final var snippetLocation: String?
 {
  get
  {
   guard let location  = self.location else { return Localized.undefinedLocationSection }
   return location.isEmpty ? Localized.undefinedLocationSection : location
  }
  set
  {
   self.location = newValue ?? ""
   //self[.byLocation] = isHiddenSection(groupType: .byLocation){ $0.location == self.location }
   self[.byLocation] = isHiddenSection(groupType: .byLocation, for: self.location!)
  }

 }
 
 @NSManaged private(set) var hiddenSet: Int16
 
 final subscript(groupedBy: GroupSnippets) -> Bool
 {
  get {return groupedBy.checkMask(for: hiddenSet)}
  set
  {
   let mask = GroupSnippets.groupingBitsMap[groupedBy]!
   if newValue
   {
    self.hiddenSet |= mask
   }
   else
   {
    self.hiddenSet &= ~mask
   }
   
  }
 }
 
 private var docFolder: URL
 {
  return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 }
 
 
 final var url: URL
 {
  return docFolder.appendingPathComponent(self.id!.uuidString)
 }
 
 

// @NSManaged fileprivate var primitivePriorityIndex: NSNumber
//
// static let priorityIndexKey = "priorityIndex"
//
// @objc public var priorityIndex: Int
// {
//  get
//  {
//   willAccessValue(forKey: BaseSnippet.priorityIndexKey)
//   let index = SnippetPriority(rawValue: priority!)!.section
//   didAccessValue(forKey:  BaseSnippet.priorityIndexKey)
//   return index
//  }
//
//  set
//  {
//   willChangeValue(forKey: BaseSnippet.priorityIndexKey)
//   primitivePriorityIndex = NSNumber(value: newValue)
//   didChangeValue(forKey:  BaseSnippet.priorityIndexKey)
//  }
// }
//
 
}

