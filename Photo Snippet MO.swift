//
//  PhotoSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import UIKit
import CoreData

import class RxSwift.PublishSubject
import struct RxSwift.Completable
import class RxSwift.DisposeBag
import class Combine.AnyCancellable

@objc(PhotoSnippet)
public final class PhotoSnippet: BaseSnippet, SnippetImagesPreviewProvidable, MultipleTargetUndoable
{
 lazy var imageProvider: SnippetPreviewImagesProvider = SnippetImagesProvider(photoSnippet: self, number: 30)
 
 let target: NSObject? = nil
 
 let undoer = DistributedUndoManager()
 
 lazy var undoQueue = subscribeForUndo()
 
 let disposeBag  = DisposeBag()
 
 var deletedPhotoItems = Set<AnyCancellable>()
 
 var relations: [String] { [ #keyPath(PhotoSnippet.photos), #keyPath(PhotoSnippet.folders) ] }
 
 override var fields: [String] { super.fields + relations }
 
 override var isValidForChanges: Bool
 {
  let pairs = self.changedValuesForCurrentEvent()
  let keys = pairs.keys
  
  let hasPhotos  = keys.contains(#keyPath(PhotoSnippet.photos ))
  let hasFolders = keys.contains(#keyPath(PhotoSnippet.folders))
  
  switch (hasPhotos, hasFolders)
  {
   case (true,  true ):   fallthrough
   case (true,  false):   return true
   case (false, true ):   return false
   case (false, false):   return super.isValidForChanges
  }
 
 }
 
 final var photoGroupType: GroupPhotos?
 {
  get
  {
   guard let grouping = self.grouping else { return nil }
   return GroupPhotos(rawValue: grouping)
  }
  set { grouping = newValue?.rawValue }
 }
 
 final var isSectioned: Bool { photoGroupType?.isSectioned ?? false }
 
 final var isUnsectioned: Bool { !isSectioned }
 
 final var isRowPositioned: Bool { photoGroupType?.isRowPositioned ?? false }
 
 final var isMirrowPositioned: Bool { isUnsectioned && isRowPositioned && !ascendingPlain }
 
 final var allFolders:           [PhotoFolder]       { folders?.allObjects as? [PhotoFolder] ?? [] }
 final var allFolderItems:       [PhotoFolderItem]   { allFolders.map{PhotoFolderItem(folder: $0)} }
 
 final var allPhotos:            [Photo]             { photos?.allObjects as? [Photo] ?? [] }
 final var allPhotoItems:        [PhotoItem]         { allPhotos.map{PhotoItem(photo: $0)}         }
 
 final var emptyFolders:         [PhotoFolder]  { allFolders.filter{($0.photos?.count ?? 0) == 0} }
 
 final var selectedFolders:      [PhotoFolder]  { allFolders.filter{$0.isSelected} }
 final var unselectedFolders:    [PhotoFolder]  { allFolders.filter{!$0.isSelected} }
 
 final var selectedPhotos:             [Photo]  { allPhotos.filter{$0.isSelected} }
 final var unselectedPhotos:           [Photo]  { allPhotos.filter{!$0.isSelected} }
 
 final var folderedPhotos:             [Photo]  { allPhotos.filter{$0.folder != nil} }
 final var unfolderedPhotos:           [Photo]  { allPhotos.filter{$0.folder == nil} }
 final var unfolderedItems:        [PhotoItem]  { unfolderedPhotos.map{PhotoItem(photo: $0)} }
 
 
 final var allItems: [PhotoItemProtocol]
 {
  (allFolderItems as [PhotoItemProtocol]) + (unfolderedItems as [PhotoItemProtocol])
 }
 
 final var unfoldered: [PhotoItemManagedObjectProtocol] { unfolderedPhotos + allFolders }
 
 final var allPhotoObjects: [PhotoItemManagedObjectProtocol] { allPhotos + allFolders }
 
 final var sectionTitles: Set<String> { Set(allItems.map{ $0.sectionTitle ?? "" }) }
 
 final var sortedSectionTitles: [String]
 {
  guard let pred = photoGroupType?.sectionType?.sectionsOrderPredicate(ascending: ascending) else { return [] }
  return sectionTitles.sorted(by: pred)
 }
 
 final var sectionedPhotoItems: [[PhotoItemProtocol]]
 {
  sortedSectionTitles.map{ photoItems(with: $0).sorted{$0.rowPosition <= $1.rowPosition} }
 }
 

 final var sortedAllItems: [PhotoItemProtocol]
 {
  guard let sortPredicate = photoGroupType?.sortPredicate else { return allItems }
  return allItems.sorted { sortPredicate($0, $1, ascendingPlain) }
 }
 
 
 final var photoItems2D : [[PhotoItemProtocol]] { isSectioned ? sectionedPhotoItems : [sortedAllItems] }


 final func unfolderedPhotos(with sectionTitle: String?, for groupType: GroupPhotos?) -> [Photo]
 {
  unfolderedPhotos.filter{ $0.sectionTitle(for: groupType) ?? "" == sectionTitle ?? "" }
 }
 
 final func unfolderedPhotos(with sectionTitle: String?) -> [Photo]
 {
  unfolderedPhotos(with: sectionTitle, for: self.photoGroupType)
 }
 
 
 
 final func unfoldered(with sectionTitle: String?,
                       for groupType: GroupPhotos?) -> [PhotoItemManagedObjectProtocol]
 {
  return unfoldered.filter{ $0.sectionTitle(for: groupType) ?? "" == sectionTitle ?? "" }
 }
 
 final func unfoldered(with sectionTitle: String?) -> [PhotoItemManagedObjectProtocol]
 {
  return unfoldered(with: sectionTitle, for: self.photoGroupType)
 }
 
 final func numberOfphotoObjects(with sectionTitle: String?, for groupType: GroupPhotos) -> Int
 {
  return unfoldered(with: sectionTitle, for: groupType).count
 }
 
 
 final func numberOfphotoObjects(with sectionTitle: String?) -> Int
 {
  return unfoldered(with: sectionTitle).count
 }

 
 
 final func folders(with sectionTitle: String?, for groupType: GroupPhotos?) -> [PhotoFolder]
 {
  return allFolders.filter{ $0.sectionTitle(for: groupType) ?? "" == sectionTitle ?? "" }
 }
 
 final func folders(with sectionTitle: String?) -> [PhotoFolder]
 {
  return folders(with: sectionTitle, for: self.photoGroupType)
 }
 
 
 
 final func photoItems(with sectionTitle: String) -> [PhotoItemProtocol]
 {
  return unfolderedPhotos(with: sectionTitle).map{ PhotoItem(photo: $0)} +
                  folders(with: sectionTitle).map{ PhotoFolderItem(folder: $0) }
 }
 
 
 
 final var unfolderedSelected: [Photo]
 {
  return allPhotos.filter{ $0.folder == nil && $0.isSelected }
 }
 
 final var unfolderedUnselected:[Photo]
 {
  return allPhotos.filter{ $0.folder == nil && !$0.isSelected }
 }
 
 final var folderedSelected: [Photo]
 {
  return allPhotos.filter{ $0.folder != nil && $0.isSelected }
 }
 
 final var folderedUnselected: [Photo]
 {
  return allPhotos.filter{ $0.folder != nil && !$0.isSelected }
 }
 
 final var selectedInUnselectedFolders: [Photo] { folderedSelected.filter{ !$0.folder!.isSelected } }
 
 final var singlePhotoFolders: [PhotoFolder] { allFolders.filter{ $0.folderedPhotos.count == 1} }
 
 final var selectedObjects: [PhotoItemManagedObjectProtocol]
 {
  return unfolderedSelected + selectedFolders + selectedInUnselectedFolders
 }
 
 final var selectedPhotoIDs:  [NSString] { selectedPhotos.compactMap  { $0.ID as NSString? } }
 final var selectedFolderIDs: [NSString] { selectedFolders.compactMap { $0.ID as NSString? } }
 
 
 final var folderedSelectedPhotos:     [Photo]  { allPhotos.filter{$0.folder != nil && $0.isSelected} }
 final var unfolderedSelectedPhotos:   [Photo]  { allPhotos.filter{$0.folder == nil && $0.isSelected} }
 
 final var folderedUnselectedPhotos:   [Photo]  { allPhotos.filter{$0.folder != nil && !$0.isSelected} }
 final var unfolderedUnselectedPhotos: [Photo]  { allPhotos.filter{$0.folder == nil && !$0.isSelected} }

 final func flagSelectedObjects(with flagColor: UIColor?)
 {
  managedObjectContext?.perform
  {
   self.selectedObjects.forEach
   {
    $0.isSelected = false
    $0.priority = flagColor?.priorityFlag
   }
  }
 }
 
 var allPhotosSelected: Bool
 {
  get { allPhotoObjects.allSatisfy { $0.isSelected } }
  
  set //NO SAVE CONTEXT!
  {
   managedObjectContext?.perform {
    self.allPhotoObjects.forEach { $0.isSelected = newValue }
   }
  }
 }
 


 override func initStorage()
 {
  guard let SID = self.id?.uuidString, let stype = self.type else
  {
   print ("INIT STORAGE ERROR Snippet_ID = NIL! Snippet Type = NIL")
   return
  }

  let fileManager = FileManager.default
  let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
  let newSnippetURL = docFolder.appendingPathComponent(SID)
  
  do
  {
   try fileManager.createDirectory(at: newSnippetURL, withIntermediateDirectories: false, attributes: nil)
   print ("\(stype) DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newSnippetURL.path)")
  }
  catch
  {
   print ("ERROR OCCURED WHEN CREATING \(stype) DIRECTORY: \(error.localizedDescription)")
  }
  
 }
 
 
 
 
 

}

