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
  
  set {self.type = newValue.rawValue}
  
 }
 
 @NSManaged private (set) var priority: String?
 @NSManaged  var priorityIndex: String?
 
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
 final var snippetLocation: String?
 {
  get
  {
   guard let location  = self.location else {return Localized.undefinedLocationSection}
   return location.isEmpty ? Localized.undefinedLocationSection : location
  }
  set
  {
   self.location = newValue ?? ""
  }
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

