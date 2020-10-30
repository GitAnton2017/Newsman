//
//  Photo+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.


import Foundation
import CoreData
import UIKit

import struct RxSwift.Completable
import class RxSwift.DisposeBag
import protocol RxSwift.Disposable
import class RxSwift.PublishSubject
import class RxSwift.MainScheduler
import class Combine.AnyCancellable

@objc(Photo)
public final class Photo: NSManagedObject,
                          PhotoItemManagedObjectProtocol,
                          DragAndDropStatesRepresentable,
                          MultipleTargetUndoable,
                          UndoTargetRepresentable

{
 
 
 var recordName: String!
 
 @Weak(cleanInterval: 600) var removedChildenRecords = Set<NSManagedObject>()
 
 var changedFieldsInCurrentBatchModifyOperation = Set<String>()
 
 deinit
 {
//  print ("<<<< PHOTO MO DESTROYED! >>>> \(String(describing: self.id))")
  undoOperationsTokens.forEach{ NotificationCenter.default.removeObserver($0) }
  undoOperationsTokens.removeAll()
  
 }
 
 var name: String { "Photo: [\(id?.uuidString ?? "")]"}
 
 var undoOperationsTokens = Set<NSObject>()
 
 var target: NSObject? { self }
 
 var undoer: DistributedUndoManager { photoSnippet!.undoer }
 
 lazy var undoQueue = subscribeForUndo()
 
 let disposeBag  = DisposeBag()
 


 struct kp
 {
  static let isSelected =           #keyPath(Photo.isSelected)
  static let isDragAnimating =      #keyPath(Photo.isDragAnimating)
  static let positions =            #keyPath(Photo.positions)
  static let priorityFlag =         #keyPath(Photo.priorityFlag)
  static let isArrowMenuShowing =   #keyPath(Photo.isArrowMenuShowing)
 }
 
 final var url: URL?  //form underlying file URL based on PhotoFolder ID and Photo ID.
 {
  guard let fileName = self.fileName else { return nil }
  guard let folderID = self.folderID else
  {
   return snippetURL?.appendingPathComponent(fileName) // Photo is not foldered yet!
  }
  
  return snippetURL?.appendingPathComponent(folderID).appendingPathComponent(fileName) //Photo is foldred!
 }
 
 //Photo MO unmanaged instance properties...
 static let videoFormatFile = ".mov" //Video data files require file extention specifier (*.MOV) in final URL
 
 final var folderID: String?             { folder?.id?.uuidString                        }
 private var fileName: String?           { ID?.appending((type == .video ? Photo.videoFormatFile : "")) }
 final var folderedPhotos: [Photo]       { folder?.folderedPhotos ?? []                       }
 
 final var otherFolderedPhotos : [Photo] { folderedPhotos.filter { $0 !== self }              }

 final var owner: PhotoSnippet? { photoSnippet }
 final var otherFolderedPositions: [Int]
 {
  return otherFolderedPhotos.compactMap{ $0.groupTypePosition(for: .manually)}
 }
 
 
 
 final func otherFolderedAfter(using comparator: (Int, Int) -> Bool) -> [Photo]
 {
  let position = self.getRowPosition(for: .manually)
  return otherFolderedPhotos.filter { comparator ($0.getRowPosition(for: .manually),  position) }
 }//final func otherFolderedAfter...
 
 
 final func shiftFolderedLeft()
 {
  otherFolderedAfter(using: > ).forEach
  {
   let position = $0.getRowPosition(for: .manually)
   $0.setGroupTypePosition(newPosition: position - 1, for: .manually)
  }
  
 }//final func shiftFolderedLeft...
 
 
 final func shiftFolderedRight()
 {
  otherFolderedAfter(using: >= ).forEach
  {
   let position = $0.getRowPosition(for: .manually)
   $0.setGroupTypePosition(newPosition: position + 1, for: .manually)
  }
  
 }//final func shiftFolderedRight...
 
 
 
 final var maxRowPosition: Int { maxRowPosition(for: self.groupType) }
 
 final func maxRowPosition(for groupType: GroupPhotos?) -> Int
 {
  return (isFoldered ? otherFolderedPositions: otherUnfolderedPositions(for: groupType)).max() ?? -1
 }
 

 final var groupTypeStr: String? { isFoldered ? GroupPhotos.manually.rawValue : groupType?.rawValue }

 final var isFoldered: Bool   { folder != nil }
 
 final var isUnfoldered: Bool { folder == nil }
 
 
 final func setSinglePhotoRowPositions()
 {
  guard isFoldered else { return } //single photo to be unfoldred must be foldered!
  
  clearAllRowPositions()
  // 1 - invalidate all previously set foldered positions (namely .manually)
  // 2 - set positions for each positioned group type as max position of all unfoldered objects in section.
  // except for the case when single photo title is the same as the one of deleted folder...
  
  GroupPhotos.rowPositioned.forEach
  {
   let deletedTitle = self.folder!.sectionTitle(for: $0) ?? ""
   let singleTitle = self.sectionTitle(for: $0) ?? ""
   
   if ( deletedTitle == singleTitle )
   // if single photo is in the same section for current ($0) group type...
   {
    let folderPosition = self.folder!.getRowPosition(for: $0)
    self.setGroupTypePosition(newPosition: folderPosition, for: $0)
   }
   else
   {
    let newPosition = photoSnippet!.numberOfphotoObjects(with: singleTitle, for: $0)
    self.setGroupTypePosition(newPosition: newPosition, for: $0)
    self.folder!.shiftRowPositionsLeft(for: $0)
   }
  }
 }//final func setSinglePhotoRowPositions....
 
 
 
 final func setUnfolderingPhotoRowPositions()
 {
  guard isFoldered else { return } //photos to be unfoldered must be foldered!
  shiftFolderedLeft()
  clearAllRowPositions()
  setMovedPhotoRowPositions()
 
 }//final func setUnfolderedPhotoRowPositions...
 
 
 var dragStateSubscription: Disposable?
 var dragProceedSubscription: Disposable?
 
 var rowPositionStateSubscription: AnyCancellable?
 
 
 public override func willTurnIntoFault()
 {
  //rowPositionStateSubscription?.cancel()
  super.willTurnIntoFault()
 }
 
 var movedInCurrentEvent: Bool = false
 
 var movedURL: URL?
 
 
 @objc dynamic final var isDragProceeding  = false
 @objc dynamic final var dragProceedLocation: CGPoint = .zero
 @objc dynamic final var isDropProceeding  = false
 @objc dynamic final var isJustCreated = false
 
 final var isDragMoved: Bool = false
 
 final var zoomedPhotoItemState: Bool = false
 //Photo MO internal not persisted current state if its PhotoItem wrapper is currently presented in ZoomView
 
 
 

}


