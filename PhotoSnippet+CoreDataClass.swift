//
//  PhotoSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoSnippet) public class PhotoSnippet: BaseSnippet, SnippetImagesPreviewProvidable
{

 var allFolders:       [PhotoFolder] {return folders?.allObjects as? [PhotoFolder] ?? []}
 var allPhotos:        [Photo]       {return photos?.allObjects  as? [Photo]       ?? []}
 var emptyFolders:     [PhotoFolder] {return allFolders.filter{($0.photos?.count ?? 0) == 0}}
 var selectedPhotos:   [Photo]       {return allPhotos.filter{$0.isSelected}}
 var unfolderedPhotos: [Photo]       {return allPhotos.filter{$0.folder == nil}}
 
 
 private weak var _provider: SnippetPreviewImagesProvider?
 private var makeProvider: SnippetPreviewImagesProvider
 {
  let provider = SnippetImagesProvider(photoSnippet: self, number: 30)
  _provider = provider
  return _provider!
 }
 
 var imageProvider: SnippetPreviewImagesProvider
 {
  return _provider ?? makeProvider
 }
// lazy var imageProvider: SnippetPreviewImagesProvider =
// {
//  let provider = SnippetImagesProvider(photoSnippet: self, number: 30)
//  return provider
//
// }()
}

enum GroupPhotos: String
{
    case byPriorityFlag    =  "By Priority Flag"
    case byTimeCreated     =  "By Time Created"
    case manually          =  "Manually"
    case makeGroups        =  "Make Groups by Priority Flag"
    
    static let sortDecritorsMap: [GroupPhotos : NSSortDescriptor] =
    [
     .byPriorityFlag: NSSortDescriptor(key: #keyPath(Photo.priorityFlag), ascending: true),
     .byTimeCreated : NSSortDescriptor(key: #keyPath(Photo.date),         ascending: true),
     .manually      : NSSortDescriptor(key: #keyPath(Photo.position),     ascending: true)
    ]
    
    static var ascending: Bool = true
    
    typealias SortPredicate = (PhotoItemProtocol, PhotoItemProtocol) -> Bool
    static let sortPredMap: [GroupPhotos : SortPredicate] =
    [
     .byPriorityFlag: {GroupPhotos.ascending ? $0.priority <= $1.priority : $0.priority >= $1.priority },
     .byTimeCreated:  {GroupPhotos.ascending ? $0.date     <= $1.date     : $0.date     >= $1.date     },
     .manually:       {GroupPhotos.ascending ? $0.position <= $1.position : $0.position >= $1.position }
    ]
    
    static let groupingTypes : [GroupPhotos] = [.byPriorityFlag, .byTimeCreated, .manually, .makeGroups]
    
    var sortDescriptor: NSSortDescriptor
    {
     return GroupPhotos.sortDecritorsMap[self]!
    }
    
    var sortPredicate: SortPredicate?
    {
     return GroupPhotos.sortPredMap[self]
    }
}
