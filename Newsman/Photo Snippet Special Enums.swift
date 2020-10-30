//
//  Photo Snippet Special Enums.swift
//  Newsman
//
//  Created by Anton2016 on 26.10.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension Dictionary where Value: Hashable
{
 func transposed() -> Dictionary <Value, Key>
 {
  return Dictionary<Value,Key>(uniqueKeysWithValues: map{($0.value, $0.key)})
 }
}

enum GroupPhotos: String, AllCasesSelectorRepresentable
{
 static private var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
 
 var isCaseEnabled: Bool
 {
  get { return GroupPhotos.enabled[self]! }
  set { GroupPhotos.enabled[self] = newValue }
 }
 
 static let sectionsEnumTypes : [GroupPhotos : PhotoItemsSectionsRepresentable.Type] =
 [
  .makeGroups : PhotoPriorityFlags.self,
  .typeGroups : PhotoItemsTypes.self
 ]
 
 static let rowPositioned: [GroupPhotos] = [.manually, .makeGroups, .typeGroups]
 
 static let fixedPositioned: [GroupPhotos] = [.typeGroups]
 
 var isRowPositioned: Bool { return GroupPhotos.rowPositioned.contains(self) }
 
 var isFixedPositioned: Bool { return GroupPhotos.fixedPositioned.contains(self) }
 
 var isFreePositioned: Bool { return !isFixedPositioned }
 
 var localizedString: String { return §§rawValue }
 
 var isSectioned: Bool { return GroupPhotos.sectionsEnumTypes.keys.contains(self) }
 
 var isUnsectioned: Bool { return !isSectioned }
 
 var sectionKeyPath: String? { return GroupPhotos.sectionedTypesKeyPaths[self] }
 
 var sectionType: PhotoItemsSectionsRepresentable.Type?
 {
  return GroupPhotos.sectionsEnumTypes[self]
 }
 
 func sectionOrderPredicate(ascending: Bool) -> ( (String, String) -> Bool )?
 {
  return sectionType?.sectionsOrderPredicate(ascending: ascending)
 }
 
 func sectionTitle(with rateIndex: Int) -> String?
 {
  return GroupPhotos.sectionsEnumTypes[self]?.sectionTitle(with: rateIndex)
 }
 
 var defaultSectionTitle: String?
 {
  return GroupPhotos.sectionsEnumTypes[self]?.defaultSectionTitle
 }
 
 case byPriorityFlag    =  "By Priority Flag"
 case byTimeCreated     =  "By Time Created"
 case manually          =  "Manually"
 //**************************** GROUPED **************************************
 case makeGroups        =  "Make Groups by Priority Flag"
 case typeGroups        =  "Make Groups by Photo Item type"
// case tagsGroups        =  "Make Groups by Photo Item tag"
// case timeGroups        =  "Make Groups by Photo Item date & time created"
// case locationGroups    =  "Make Groups by Photo Item GPS Location"
 
 static let sortDecritorsMap: [GroupPhotos : NSSortDescriptor] =
 [
   .byPriorityFlag: NSSortDescriptor(key: #keyPath(Photo.priorityFlag), ascending: true),
   .byTimeCreated : NSSortDescriptor(key: #keyPath(Photo.date),         ascending: true),
   .manually      : NSSortDescriptor(key: #keyPath(Photo.position),     ascending: true)
 ]
 
 typealias TSortPredicate = (PhotoItemProtocol, PhotoItemProtocol, Bool) -> Bool
 
 struct SortPred
 {
  static let byTime: TSortPredicate = { $2 ? $0.date <= $1.date : $0.date >= $1.date }
  
  static let byFlag: TSortPredicate = { $2 ? $0.priorityFlagIndex <= $1.priorityFlagIndex :
                                             $0.priorityFlagIndex >= $1.priorityFlagIndex }
  
  static let manually: TSortPredicate = { $2 ? $0.rowPosition <= $1.rowPosition :
                                               $0.rowPosition >= $1.rowPosition }
 }
 
 static let sortPredMap: [GroupPhotos : TSortPredicate] =
 [
  .byPriorityFlag: SortPred.byFlag,
  .byTimeCreated:  SortPred.byTime,
  .manually:       SortPred.manually,
  .makeGroups:     SortPred.manually,
  .typeGroups:     SortPred.manually
 ]
 
 static let groupingTypes : [GroupPhotos] = [.byPriorityFlag, .byTimeCreated, .manually, .makeGroups]
 
 static let sectionedTypesKeyPaths: [GroupPhotos: String] =
 [
  .makeGroups:     #keyPath(Photo.priorityFlag),
//  .tagsGroups:     #keyPath(Photo.priorityFlag),
//  .timeGroups:     #keyPath(Photo.priorityFlag),
//  .locationGroups: #keyPath(Photo.priorityFlag)
 ]
 
 var sortDescriptor: NSSortDescriptor { GroupPhotos.sortDecritorsMap[self]! }
 
 var sortPredicate: TSortPredicate? { GroupPhotos.sortPredMap[self] }
}


protocol PhotoItemsSectionsRepresentable
{
 init?(rawValue: String)
 var localizedString: String { get }
 var color: UIColor { get }
 var rateIndex: Int { get }
 static func sectionTitle(with rateIndex: Int) -> String?
 static var defaultSectionTitle: String { get }
}

extension PhotoItemsSectionsRepresentable
{
 static func sectionsOrderPredicate(ascending: Bool) -> (String, String) -> Bool
 {
  return {
   let x0 = Self.init(rawValue: $0)?.rateIndex ?? -1
   let x1 = Self.init(rawValue: $1)?.rateIndex ?? -1
   return ascending ? x0 < x1 : x0 > x1
  }
 }
}


extension UIColor
{

 static let priorityColorMap : [UIColor: PhotoPriorityFlags] =
 [
  UIColor.red        : .hottest,
  UIColor.orange     : .hot,
  UIColor.yellow     : .high,
  UIColor.brown      : .normal,
  UIColor.blue       : .medium,
  UIColor.green      : .low
 ]
 
 
 var priorityFlag: String? { UIColor.priorityColorMap[self]?.rawValue }
 
}

enum PhotoPriorityFlags: String, PhotoItemsSectionsRepresentable
{
 static let defaultSectionTitle = PhotoPriorityFlags.unflagged.rawValue
 
 static func sectionTitle(with rateIndex: Int) -> String?
 {
  let r = prioritySectionsMap.count - 1 - rateIndex
  return prioritySectionsMap.transposed()[r]?.rawValue
 }
 

 var localizedString: String { self == .unflagged ? Localized.unflagged : §§rawValue }
 
 static let priorityColorMap : [PhotoPriorityFlags: UIColor] =
 [
   .hottest   : UIColor.red,
   .hot       : UIColor.orange,
   .high      : UIColor.yellow,
   .normal    : UIColor.brown,
   .medium    : UIColor.blue,
   .low       : UIColor.green,
   .unflagged : UIColor.lightGray
 ]
 
 
 
 static let prioritySectionsMap: [ PhotoPriorityFlags : Int ] =
 [
  .hottest : 0, .hot : 1, .high : 2, .normal : 3, .medium : 4, .low : 5, .unflagged : 6
 ]
 
 static let priorities: [ PhotoPriorityFlags ] =
 [
  .hottest , .hot, .high, .normal, .medium, .low, .unflagged
 ]
 
 var color: UIColor  { PhotoPriorityFlags.priorityColorMap[self]! }
 var section: Int    { PhotoPriorityFlags.prioritySectionsMap[self]!}
 var rateIndex: Int  { PhotoPriorityFlags.prioritySectionsMap.count - 1 - section }
 
 
 case hottest =  "Hottest"
 case hot     =  "Hot"
 case high    =  "High"
 case normal  =  "Normal"
 case medium  =  "Medium"
 case low     =  "Low"
 case unflagged = ""
 
}


enum PhotoItemsTypes: String, PhotoItemsSectionsRepresentable
{
 static let defaultSectionTitle = PhotoItemsTypes.allPhotos.rawValue
 
 static func sectionTitle(with rateIndex: Int) -> String?
 {
  sectionsMap.transposed()[rateIndex]?.rawValue
 }
 
 
 var localizedString: String { §§rawValue }
 
 static let typesColorMap : [ PhotoItemsTypes : UIColor ] =
 [
   .allPhotos  : UIColor.red,
   .allFolders : UIColor.blue
 ]
 
 
 static let sectionsMap: [PhotoItemsTypes: Int] = [ .allPhotos : 0, .allFolders : 1 ]
 static let itemsTypes: [PhotoItemsTypes] = [ .allPhotos , .allFolders ]
 
 var color: UIColor  { PhotoItemsTypes.typesColorMap[self]! }
 var rateIndex: Int  { PhotoItemsTypes.sectionsMap[self]!   }
 
 case allPhotos =  "All Photos"
 case allFolders = "All Folders"
 
}
