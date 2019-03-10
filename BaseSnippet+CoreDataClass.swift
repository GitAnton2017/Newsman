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
 
 struct HiddenSectionKey: Hashable
 {
  let snippetType: SnippetType
  let groupType: GroupSnippets
  let sectionName: String
 }
 

 static var hiddenSections:  [HiddenSectionKey : Bool] = [ : ]
 
 final func isHiddenSection(groupType: GroupSnippets, for newValue: String? = nil) -> Bool
 {
  
  let key = HiddenSectionKey(snippetType: snippetType, groupType: groupType, sectionName: newValue ?? "")
  
  if let hidden = BaseSnippet.hiddenSections[key] { return hidden }
  
  let frq: NSFetchRequest<BaseSnippet> = BaseSnippet.fetchRequest()
  
  let selfTypePred = NSPredicate(format: "SELF.type == %@.type", self)
  let notSelfPred  = NSPredicate(format: "SELF <> %@",           self)
 
  if let keyPath = GroupSnippets.groupingKeyPath[groupType], newValue != nil
  {
   let keyPathPred = NSPredicate(format: "%K == %@", keyPath, newValue!)
   frq.predicate = NSCompoundPredicate(type: .and, subpredicates: [keyPathPred, selfTypePred, notSelfPred])
  }
  else
  {
   frq.predicate = NSCompoundPredicate(type: .and, subpredicates: [selfTypePred, notSelfPred])
  }
  
  let fetch = (try? managedObjectContext?.fetch(frq) ?? []) ?? []
  let hidden = fetch.isEmpty ? false : fetch.allSatisfy{ $0[groupType] }
  
  BaseSnippet.hiddenSections[key] = hidden
 
  return hidden
  
 }
 
 
 
 final func isHiddenSection(groupType: GroupSnippets, predicate: (BaseSnippet) -> Bool ) -> Bool
 {
  guard let allObjects = self.managedObjectContext?.registeredObjects else { return false }
  return allObjects.compactMap{$0 as? BaseSnippet}.filter{$0 !== self && predicate($0)}.allSatisfy{$0[groupType]}
 }
 
 weak var currentFRC: SnippetsFetchController?
 //the weak ref to current FRC wrapper that fetched and manages this Snippet

 func initStorage(){ } //Polymorphic method to intialize virtual type of storage for concrete snippet type.
 
 static var snippetDates = SnippetDates()

 @NSManaged private (set) var date: NSDate?
 @NSManaged var dateIndex: String?
 @NSManaged var dateFormatIndex: String?
 
 final var snippetDate: Date
 {
  get {return self.date! as Date}
  set
  {
   self.date = newValue as NSDate
   self.dateIndex = BaseSnippet.snippetDates.datePredicates.first{$0.predicate(self)}?.title
   self.dateFormatIndex = DateFormatters.localizedSearchString(for: newValue)
   self[.byDateCreated] = isHiddenSection(groupType: .byDateCreated, for: self.dateIndex)
  }
 }
 
 final var snippetDateTag: String
 {
  return DateFormatters.medium.string(from: self.snippetDate)
 }
 
 @objc final var dateSearchIndex: String
 {
  return DateFormatters.localizedSearchString(for: snippetDate)
 }
 
 
 
 @NSManaged private (set) var tag: String?
 @NSManaged var  alphaIndex: String?
 
 @objc final var snippetName: String // calculated property for snippet search by Name!
 {
  get
  {
   guard let tag = self.tag else {return Localized.unnamedSnippet}
   return tag.isEmpty ? Localized.unnamedSnippet : tag
  }
  set
  {
   self.tag = (newValue != Localized.unnamedSnippet) ? newValue : ""
   self.alphaIndex = newValue.isEmpty ? newValue : String(newValue.first!)
   self[.alphabetically] = isHiddenSection(groupType: .alphabetically, for: self.alphaIndex)
  }
 }
 
 @NSManaged private (set) var status: String?
 
 final var snippetStatus: SnippetStatus
 {
  get
  {
   guard let snippetStatus = self.status else
   {
    print("WARNING! Snippet ID: \(self.id?.uuidString ?? "NIL") with NIL status is encountered in store!")
    return .new
   }
   
   return SnippetStatus(rawValue: snippetStatus)!
  }
  
  set { self.status = newValue.rawValue }
  
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
   self[.bySnippetType] = isHiddenSection(groupType: .bySnippetType, for: self.type)
   self[.plainList] = isHiddenSection(groupType: .plainList)
  }
  
 }
 
 @NSManaged private (set) var priority: String?
 @NSManaged var priorityIndex: String?
 
 
 @objc final var localizedPriority: String  // calculated property for snippet search by Priority!
 {
  return NSLocalizedString(priority ?? "", comment: priority ?? "")
 }
 
 final var snippetPriority: SnippetPriority
 {
  get
  {
   guard let snippetPriority = self.priority else
   {
    print("WARNING! Snippet ID: \(self.id?.uuidString ?? "NIL") with NIL priority is encountered in store!")
    return .normal
   }
   
   return SnippetPriority(rawValue: snippetPriority)!
  }
  
  set
  {
   self.priority = newValue.rawValue
   self.priorityIndex = String(snippetPriorityIndex) + "_" + newValue.rawValue
   self[.byPriority] = isHiddenSection(groupType: .byPriority, for: self.priorityIndex)
  }

 }
 
 
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
 
 @objc final var snippetLocation: String? // calculated property for snippet search by GPS Location!
 {
  get
  {
   guard let location  = self.location else { return Localized.undefinedLocationSection }
   return location.isEmpty ? Localized.undefinedLocationSection : location
  }
  set
  {
   self.location = newValue ?? ""
   self[.byLocation] = isHiddenSection(groupType: .byLocation, for: self.location)
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

