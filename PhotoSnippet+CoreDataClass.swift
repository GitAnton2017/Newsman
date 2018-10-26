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

