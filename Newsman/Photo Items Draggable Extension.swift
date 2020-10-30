//
//  Photo Items Draggable Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

//import UIKit
//
//extension PhotoItemsDraggable
//{
// 
// var itemsInRow: Int { photoSnippetVC.photosInRow }
// 
// var deviceType: UIUserInterfaceIdiom
// {
//  return photoSnippetVC.traitCollection.userInterfaceIdiom
// }
// 
// var vsc: UIUserInterfaceSizeClass
// {
//  return photoSnippetVC.traitCollection.verticalSizeClass
// }
// 
// var hsc: UIUserInterfaceSizeClass
// {
//  return photoSnippetVC.traitCollection.horizontalSizeClass
// }
// 
// 
// 
// var allPhotoItems: [PhotoItemProtocol]
// {
//  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoItemProtocol}
// }
//
// var allPhotos: [PhotoItem]
// {
//  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoItem}
// }
//
// var allFolders: [PhotoFolderItem]
// {
//  return AppDelegate.globalDragItems.compactMap{$0 as? PhotoFolderItem}
// }
//
// var localPhotos: [PhotoItem]
// {
//  allPhotos.filter{$0.photoSnippet?.objectID == photoSnippet.objectID && $0.photo.folder == nil}
// }
//
// var localFolders: [PhotoFolderItem] { allFolders.filter{$0.photoSnippet?.objectID == photoSnippet.objectID} }
//
// var localItems: [PhotoItemProtocol] { localPhotos as [PhotoItemProtocol] + localFolders as [PhotoItemProtocol]}
//
// var localFoldered: [PhotoItem]
// {
//  allPhotos.filter{$0.photoSnippet?.objectID == photoSnippet.objectID && $0.photo.folder != nil}
// }
//
// var outerFoldered: [PhotoItem]
// {
//  allPhotos.filter{$0.photoSnippet?.objectID != photoSnippet.objectID && $0.photo.folder != nil}
// }
//
// var outerSnippets: [PhotoSnippet]
// {
//  allPhotoItems.filter{$0.photoSnippet?.objectID != photoSnippet.objectID}.compactMap{$0.photoSnippet}
// }
//
// var localFolderedFolders: [PhotoFolderItem]
// {
//  Set(localFoldered.compactMap{$0.photo.folder}).compactMap{PhotoFolderItem(folder: $0)}
// }
//
//
// var outerFolderedFolders: [PhotoFolderItem]
// {
//  Set(outerFoldered.compactMap{$0.photo.folder}).compactMap{PhotoFolderItem(folder: $0)}
// }
//
// var removedLocalFolders: [PhotoFolderItem]
// {
//  return localFolderedFolders.lazy.filter
//  {folder in
//   let items = folder.singlePhotoItems
//   let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
//   return items.count - drags == 0
//
//  }
// }
//
// var singleLocalFolders: [PhotoFolderItem]
// {
//  return localFolderedFolders.lazy.filter
//   {folder in
//    let items = folder.singlePhotoItems
//    let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
//    return items.count - drags == 1
//
//  }
// }
//
// var updatedLocalFolders: [PhotoFolderItem]
// {
//  return localFolderedFolders.lazy.filter
//  {folder in
//   let items = folder.singlePhotoItems
//   let drags = items.filter {x in self.localFoldered.contains{$0.id == x.id}}.count
//   return items.count - drags > 1
//
//  }
// }
//
//}//extension PhotoItemsDraggable...

