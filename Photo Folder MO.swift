//
//  PhotoFolder+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 09.02.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import UIKit
import CoreData

import struct RxSwift.Completable
import class RxSwift.DisposeBag
import protocol RxSwift.Disposable
import class RxSwift.PublishSubject
import class Combine.AnyCancellable

@objc(PhotoFolder)
public final class PhotoFolder: NSManagedObject,
                                PhotoItemManagedObjectProtocol,
                                DragAndDropStatesRepresentable,
                                MultipleTargetUndoable,
                                UndoTargetRepresentable
 
{

 var recordName: String!
 
 @Weak(cleanInterval: 600) var removedChildenRecords = Set<NSManagedObject>()
 
 var changedFieldsInCurrentBatchModifyOperation = Set<String>()
 
 // deinit { print ("<<<<  PHOTO *** FOLDER *** MO DESTROYED! >>>> \(self)") }
 
 struct kp
 {
  static let isSelected =           #keyPath(PhotoFolder.isSelected)
  static let isDragAnimating =      #keyPath(PhotoFolder.isDragAnimating)
  static let positions =            #keyPath(PhotoFolder.positions)
  static let priorityFlag =         #keyPath(PhotoFolder.priorityFlag)
  static let isArrowMenuShowing =   #keyPath(PhotoFolder.isArrowMenuShowing)
 }
 
 var name: String { "Photo Folder: [\(id?.uuidString ?? "")]"}
 
 var target: NSObject? { self }
 
 var undoer: DistributedUndoManager { photoSnippet!.undoer }
 
 lazy var undoQueue = subscribeForUndo()
 
 let disposeBag  = DisposeBag()
 
 final var isSingleElementFolder = false 
 
 final var url: URL?                   { ID != nil ? snippetURL?.appendingPathComponent(ID!) : nil  }
 final var selectedPhotos: [Photo]     { folderedPhotos.filter{ $0.isSelected }    }
 final var unselectedPhotos: [Photo]   { folderedPhotos.filter{ !$0.isSelected }   }
 final var areAllPhotosSelected: Bool  { unselectedPhotos.isEmpty                  }
 final var folderedPhotos: [Photo]     { photos?.allObjects as? [Photo] ?? []      }
 final var folderedSet: Set<Photo>     { Set(folderedPhotos)                       }
 final var count: Int                  { folderedPhotos.count                      }
 final var isEmpty: Bool               { folderedPhotos.isEmpty                    }
 final var groupTypeStr: String?       { groupType?.rawValue                       }
 final var folderedItems: [Photo]      { folderedPhotos }
 
 final var maxRowPosition: Int         { maxRowPosition(for: self.groupType)       }
 
 final var owner: PhotoSnippet? { photoSnippet }
 
 final func maxRowPosition(for groupType: GroupPhotos?) -> Int
 {
  otherUnfolderedPositions(for: groupType).max() ?? -1
 }
 
 var dragStateSubscription: Disposable?
 var dragProceedSubscription: Disposable?


 
 @objc dynamic final var isDragProceeding = false
 @objc dynamic final var isDropProceeding = false
 @objc dynamic final var dragProceedLocation: CGPoint = .zero
 @objc dynamic final var isJustCreated = false
 
 final var zoomedPhotoItemState = false
 
 final var isDragMoved: Bool = false
 
 //PhotoFolder MO internal not persisted current state if its PhotoFolderItem wrapper is currently presented in ZoomView
 
} //@objc(PhotoFolder) public class PhotoFolder: NSManagedObject...


