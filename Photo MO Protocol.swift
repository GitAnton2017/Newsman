//
//  Photo MO Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 25/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData
import Combine

@objc protocol PhotoItemManagedObjectBaseProtocol where Self: NSManagedObject
{
 var photoSnippet: PhotoSnippet?   { get set } //managed
 var positions: NSObject?          { get set } //managed
 var id: UUID?                     { get set } //managed
 var priorityFlag: String?         { get set } //managed
 var tag: String?                  { get set } //managed
 var isSelected: Bool              { get set } //managed
 
 var isArrowMenuShowing: Bool      { get set } //managed
 var arrowMenuTouchPoint: NSValue? { get set } //managed
 var arrowMenuPosition: NSValue?   { get set } //managed
}

extension PhotoItemManagedObjectBaseProtocol
{
 
 var priorityFlagColorPublisher: AnyPublisher<UIColor, Never>
 {
  publisher(for: \.priorityFlag, options: [.initial])
   .map{ $0 == nil || $0 == "" ? .clear : (PhotoPriorityFlags(rawValue: $0!)?.color ?? .clear) }
   .eraseToAnyPublisher()

 }
 
 var rowPositionsPublisher: AnyPublisher<[ String : Int ], Never>
 {
  publisher(for: \.positions, options: [.initial])
   .compactMap{ $0 as? [ String : Int ] }
   .eraseToAnyPublisher()
 }
 
 var groupTypePublisher: AnyPublisher<String, Never>
 {
  guard let photoSnippet = photoSnippet else {
   return Empty<String, Never>(completeImmediately: false).eraseToAnyPublisher()
  }

  return photoSnippet.publisher(for: \.grouping, options: [.initial])
      .compactMap{ $0 }
      .eraseToAnyPublisher()
  
 

 }
 
}



protocol PhotoItemManagedObjectProtocol: PhotoItemManagedObjectBaseProtocol
{
 var isDragProceeding: Bool        { get set } //not managed
 var dragProceedLocation: CGPoint  { get set } //not managed
 
 var isDragMoved: Bool             { get set } //not managed
 
 var isDropProceeding: Bool        { get set } //not managed
 var isJustCreated: Bool           { get set } //not managed
 
 var url: URL?                    { get     }
 var groupTypeStr: String?        { get     }
 var maxRowPosition: Int          { get     }
 var groupType: GroupPhotos?      { get     }
 var sectionIndex: Int            { get     }
 var sectionTitle: String?        { get     }
 var isSectioned: Bool            { get     }
 var type: SnippetType?           { get     }
 var snippetID: String?           { get     }
 var snippetURL: URL?             { get     }
 var rowPosition: Int             { get set }
 
 var groupTypePosition: Int?      { get     }
 var priorityFlagColor: UIColor?  { get set }
 
 func delete()
 
 func maxRowPosition( for groupType: GroupPhotos? ) -> Int
 
 var backgroundObject: NSManagedObject?     { get }
 

}

extension PhotoItemManagedObjectProtocol
{

 
 
 
 
}//extension PhotoItemManagedObjectProtocol...


extension PhotoItemManagedObjectProtocol where Self: Photo
{
 var photoFolderedStatePublisher: AnyPublisher<Bool, Never>
 {
  publisher(for: \.folder, options: [.initial]).map{ $0 != nil }.eraseToAnyPublisher()
 }
 
}//extension PhotoItemManagedObjectProtocol where Self: Photo...


extension PhotoItemManagedObjectProtocol
{
 
 var docFolder: URL
 {
  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 }
 
 var snippetID: String?       { photoSnippet?.id?.uuidString                }
 
 var snippetURL: URL?
 {
  guard let snippetID = self.snippetID else { return nil }
  return docFolder.appendingPathComponent(snippetID)
 }
 
 var type: SnippetType?       { photoSnippet?.snippetType                   }
 var ID: String?              { id?.uuidString                              }
 var groupType: GroupPhotos?  { photoSnippet?.photoGroupType                }
 var isSectioned: Bool        { photoSnippet?.isSectioned ?? false          }
 var isMirrowPositioned: Bool { photoSnippet?.isMirrowPositioned ?? false   }
 

 var priority: String?
 {
  get { priorityFlag }
  set
  {
   guard (priorityFlag ?? "") != (newValue ?? "") else { return }
  
   if let photo = self as? Photo, photo.isFoldered { priorityFlag = newValue } else
   {
    shiftRowPositionsLeft(for: .makeGroups)
  
    let newPosition = photoSnippet?.numberOfphotoObjects(with: newValue, for: .makeGroups) ?? 0
    setGroupTypePosition(newPosition: newPosition, for: .makeGroups)
    
    priorityFlag = newValue
    
   }
 
  }//set
 }//var priority: String?
 
 
 
 var searchTag: String?
 {
  get { tag ?? "" }
  set
  {
   managedObjectContext?.perform
   {
    self.isSelected = false
    self.tag = newValue
   }
  }
 }
 
 var priorityFlagColor: UIColor?
 {
  get { PhotoPriorityFlags(rawValue: priorityFlag ?? "")?.color ?? UIColor.clear }
  set
  {
   managedObjectContext?.perform
   {
    self.isSelected = false
    self.priority = newValue?.priorityFlag
   }
  }
  
 }//var priorityFlagColor: UIColor?
 
 
 func sectionTitle(for groupType: GroupPhotos?) -> String?
 {
  if ( groupType == .typeGroups )
  {
   return self is PhotoFolder ? PhotoItemsTypes.allFolders.rawValue : PhotoItemsTypes.allPhotos.rawValue
  }
  guard let keyPath = groupType?.sectionKeyPath else { return nil }
  return self.value(forKey: keyPath) as? String
  
 }//func sectionTitle(for groupType...
 
 
 var sectionTitle: String? { return sectionTitle(for: self.groupType) }
 
 func sectionIndex(for groupType: GroupPhotos?) -> Int
 {
  let title = self.sectionTitle(for: groupType) ?? ""
  return groupType?.sectionType?.init(rawValue: title)?.rateIndex ?? -1
 }//func sectionIndex(for groupType...
 
 
 var sectionIndex: Int { sectionIndex(for: self.groupType) }
 
 
 func otherUnfoldered(for groupType: GroupPhotos?) -> [PhotoItemManagedObjectProtocol]
 {
  guard let other = photoSnippet?.unfoldered.filter({ $0 !== self }) else { return [] }
  guard groupType?.isSectioned ?? false else { return other }
  let title = self.sectionTitle(for: groupType) ?? ""
  return other.filter { $0.sectionTitle(for: groupType) ?? "" == title }
 }//func otherUnfoldered(for groupType...
 
 
 var otherUnfoldered: [PhotoItemManagedObjectProtocol] { otherUnfoldered(for: self.groupType) }
 
 var otherAllUnfoldered: [PhotoItemManagedObjectProtocol]
 {
  photoSnippet?.unfoldered.filter({ $0 !== self }) ?? []
 }
 
 
 func otherUnfolderedAfter(for groupType: GroupPhotos?,
                           using comparator: (Int, Int) -> Bool) -> [PhotoItemManagedObjectProtocol]
 {
  let position = self.getRowPosition(for: groupType)
  return otherUnfoldered(for: groupType).filter{ comparator($0.getRowPosition(for: groupType), position) }
 }//func otherUnfolderedAfter(for groupType...
 
 
 
 func shiftRowPositionsLeft(for groupType: GroupPhotos?)
 {
  guard groupType?.isRowPositioned ?? false else { return }
  
  otherUnfolderedAfter(for: groupType, using: > ).forEach
  {
   let position = $0.getRowPosition(for: groupType)
   $0.setGroupTypePosition(newPosition: position - 1, for: groupType)
  }
  
  
 }//func shiftRowPositionsLeft(for groupType...
 
 
 
 func shiftRowPositionsLeft()
 //shift other object row positions (-1) that has row positions >= this for current snippet group type!
 {
  if let photo = self as? Photo, photo.isFoldered
  {
   photo.shiftFolderedLeft() // if photo in folder...
  }
  else
  {
   shiftRowPositionsLeft(for: self.groupType) // unfoldered photo object
  }
 }//func shiftRowPositionsLeft()...
 
 
 func shiftRowPositionsRight(for groupType: GroupPhotos?)
 {
  guard groupType?.isRowPositioned ?? false else { return }
  
  otherUnfolderedAfter(for: groupType, using: >= ).forEach
  {
   let position = $0.getRowPosition(for: groupType)
   $0.setGroupTypePosition(newPosition: position + 1, for: groupType)
  }
  
  
 }//func shiftRowPositionsRight(for groupType...
 
 
 func shiftRowPositionsRight()
 //shift other object row positions (+1) that has row positions >= this for current snippet group type!
 {
  if let photo = self as? Photo, photo.isFoldered
  {
   photo.shiftFolderedRight() // if photo in folder...
  }
  else
  {
   shiftRowPositionsRight(for: self.groupType) // unfoldered photo object
  }
 }//func shiftRowPositionsRight()....
 
 
 
 func shiftRowPositionsBeforeDelete()
 {
  defer { clearAllRowPositions() }
  //finally clear up positions when photo leaves folder, goes to folder or is deleted!
  
  if let photo = self as? Photo, photo.isFoldered
  {
   photo.shiftFolderedLeft()  // if in folder shift positions inside folder
  }
  else
  {
   GroupPhotos.rowPositioned.forEach { shiftRowPositionsLeft(for: $0) }
  }
 }//func shiftRowPositionsBeforeDelete()...
 
 
 
 func otherUnfolderedPositions(for groupType: GroupPhotos?) -> [Int]
 {
  otherUnfoldered(for: groupType).compactMap{ $0.groupTypePosition(for: groupType) }
 }//func otherUnfolderedPositions(...
 
 
 
 var otherUnfolderedPositions: [Int] { otherUnfoldered.compactMap{ $0.groupTypePosition } }
 //var otherUnfolderedPositions getter...
 
 func groupTypePosition(for groupTypeStr: String) -> Int? { (positions as? [String : Int])?[groupTypeStr]}
 //func groupTypePosition(for groupTypeStr:...
 
 
 func getPhotoItemPosition(for groupType: GroupPhotos?) -> PhotoItemPosition
 {
  let name = self.sectionTitle(for: groupType)
  let row = self.getRowPosition(for: groupType)
  let path = groupType?.sectionKeyPath
  return PhotoItemPosition(sectionName: name, row: row, for: path)
  
 }//func getPhotoItemPosition(...
 
 
 func setPhotoItemPosition(newPosition: PhotoItemPosition, for groupType: GroupPhotos?)
 {
  guard groupType?.isRowPositioned ?? false else { return }
  setGroupTypePosition(newPosition: newPosition.row, for: groupType)
  
  guard let path = newPosition.sectionKeyPath else { return }
  setValue(newPosition.sectionName, forKey: path)
  
 }//func setPhotoItemPosition(newPosition: PhotoItemPosition...
 
 
 var photoItemPosition: PhotoItemPosition
 {
  get
  {
   if let photo = self as? Photo, photo.isFoldered
   {
    let row = photo.getRowPosition(for: .manually)
    return PhotoItemPosition(row)
   }
   
   return getPhotoItemPosition(for: self.groupType)
  
   
  }//getter...
  
  set
  {
  
   if let photo = self as? Photo, photo.isFoldered
   {
    photo.setGroupTypePosition(newPosition: newValue.row, for: .manually)
   }
   else
   {
    var value = newValue
    if isMirrowPositioned { value.row = otherUnfoldered.count - value.row }
    
    self.setPhotoItemPosition(newPosition: value, for: self.groupType)
    
   }
  }//setter...
 }//var photoItemPosition: PhotoItemPosition...
 
 
 func groupTypePosition(for groupType: GroupPhotos?) -> Int?
 {
  guard let groupType = groupType else { return nil }
  let gt = groupType.isRowPositioned ? groupType : .manually
  return groupTypePosition(for: gt.rawValue)
 }//func groupTypePosition(for groupType...
 
 
 var groupTypePosition: Int?
 {
  guard let groupTypeStr = self.groupTypeStr else { return nil }
  return groupTypePosition(for: groupTypeStr)
 }//var groupTypePosition getter...
 
 
 private func setPosition (_ newPosition: Int, _ groupType: GroupPhotos?)
 {
  guard let groupType = groupType else { return }
  
  if var positions = self.positions as? [String: Int]
  {
   positions[groupType.rawValue] = newPosition
   self.positions = NSMutableDictionary(dictionary: positions)
  }
  else
  {
   positions = NSMutableDictionary(dictionary: [groupType.rawValue : newPosition])
  }
 }//private func setPosition ...
 
 func setGroupTypePosition (newPosition: Int, for groupType: GroupPhotos?)
 {
  guard let groupType = groupType else { return }
  setPosition(newPosition, groupType) // set new row position
  
 }//func setGroupTypePosition (newPosition:...

 
 
 func getRowPosition(for groupType: GroupPhotos?) -> Int
 {
  guard let groupType = groupType else { return 0 }
  guard let position = self.groupTypePosition(for: groupType) else
  {
   let position = maxRowPosition(for: groupType) + 1
   
   self.rowPosition = position
   return position
  }
  
  return position
  
 } //func getRowPosition(for groupType...
 
 
 
 var rowPosition: Int
 {
  get
  {
   
   if isDeleted  { return 0 }
   guard  photoSnippet != nil else { return 0 }
   guard  managedObjectContext != nil else { return 0 }
   //if MO currently deleted from MOC but still retained by box objects (PhotoItem & PhotoFolderItem
   
   
   if let photo = self as? Photo, photo.isFoldered { return getRowPosition(for: .manually) }
   return getRowPosition(for: groupType)
  }
  
  set
  {
   //guard self.managedObjectContext != nil else { return }
   //ignore MO currently deleted from MOC but still retained by box objects (PhotoItem & PhotoFolderItem)!
   
   if let photo = self as? Photo, photo.isFoldered
   {
    setGroupTypePosition(newPosition: newValue, for: .manually)
   }
   else
   {
    setGroupTypePosition(newPosition: newValue, for: groupType)
   }
  }
 
 }//var rowPosition: Int...
 
 
 
 
 func initAllRowPositions()
 {
  let kvp = GroupPhotos.rowPositioned.map{(key: $0.rawValue, value: otherUnfoldered(for: $0).count)}
  let dict = Dictionary(uniqueKeysWithValues: kvp)
  positions = NSMutableDictionary(dictionary: dict)
 }
 
 
 
 func clearAllRowPositions()
 {
  self.positions = nil

 }//func clearAllRowPositions
 
 
 
 func setAllRowPositions(to newPosition: Int)
 {
  GroupPhotos.rowPositioned.forEach { setGroupTypePosition(newPosition: newPosition, for: $0) }
 }//func setAllRowPositions(...
 
 
 
 func setMovedPhotoRowPositions()
 {
  guard let groupType = self.groupType else { return }
  
  GroupPhotos.rowPositioned.filter { $0 != groupType }.forEach
  {
   let newPosition = otherUnfoldered(for: $0).count
   self.setGroupTypePosition(newPosition: newPosition, for: $0)
  }
  
 }//final func setUnfolderedPhotoRowPositions...
 
 
 var photoItem: PhotoItemProtocol?
 {
  switch self
  {
   case let photo as Photo:        return PhotoItem(photo: photo)
   case let folder as PhotoFolder: return PhotoFolderItem(folder: folder)
   default: return nil
  }
 }

}//extension PhotoItemManagedObjectProtocol...

