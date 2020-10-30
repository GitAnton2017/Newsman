//
//  Photo Snippet CV DS Helpers.swift
//  Newsman
//
//  Created by Anton2016 on 21/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoSnippetViewController
{
 
 func photoItemPosition(for destinationIndexPath: IndexPath) -> PhotoItemPosition
 {
  let title = sectionTitles?[destinationIndexPath.section]
  let row = destinationIndexPath.row
  let skp = photoSnippet.photoGroupType?.sectionKeyPath
  return PhotoItemPosition(sectionName: title, row: row, for: skp)
  
 }//func photoItemPosition(for...
 
 
 var photoItemsSections: [PhotoItemsSectionsRepresentable]?
 {
  sectionTitles?.compactMap { photoCollectionView.photoGroupType?.sectionType?.init(rawValue: $0) }
 }//var photoItemsSections:...
 
 
 func cellSection(with position: PhotoItemPosition) -> Int
 {
  guard let sectionName = position.sectionName else { return 0 }
  guard let titles = self.sectionTitles else { return 0 }
  return titles.firstIndex(of: sectionName)!
  //every section name in PhotoItemPosition must be present in section titles!!!
  //so force unwarpped here!
 }
 
 func targetIndexPath(of photoItem: PhotoItemProtocol, in section: Int) -> IndexPath
 {
  if photoItems2D.isEmpty { return .zero } // return default IndexPath(0,0)...
  // if we move first item, between snippets and destination snippet is empty!
  
  let sortPred = self.photoCollectionView.photoGroupType?.sortPredicate ?? GroupPhotos.SortPred.manually
  let asc = self.photoSnippet.isSectioned ? true : self.photoSnippet.ascendingPlain
  
  var sa = self.photoItems2D[section]
  sa += (sa.contains{$0.hostedManagedObject.objectID == photoItem.hostedManagedObject.objectID } ? [] : [photoItem])
  
  let rowIndex = sa.sorted{sortPred($0, $1, asc)}.firstIndex
  {
   $0.hostedManagedObject.objectID == photoItem.hostedManagedObject.objectID
  }
  
  return IndexPath(row: rowIndex!, section: section)

 }
 
 
 func repositionItemsIfNeeded(after delay: Int = 1, with completion: (() -> ())? = nil)
 {
  guard photoSnippet.isRowPositioned else
  {
   completion?()
   return
  }
  
  guard let sortPred = photoCollectionView.photoGroupType?.sortPredicate else
  {
   completion?()
   return
  }
  
  let asc = photoSnippet.isSectioned ? true : photoSnippet.ascendingPlain
  
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay))
  {[weak self] in
   self?.photoCollectionView.performAnimatedBatchUpdates(BatchAnimationOptions.withSmallJump(1),
   {[weak self] in
    self?.photoItems2D.enumerated().flatMap
    {s -> [(from: IndexPath, to: IndexPath)] in
     let s_cnt = s.1.count
     let sorted = s.1.enumerated().sorted{sortPred($0.1, $1.1, asc)}
     self?.photoItems2D[s.0].sort{sortPred($0, $1, asc)}
     return sorted.map
     {
      (from: IndexPath(row: $0.0                                                 , section: s.0),
       to:   IndexPath(row: asc ? $0.1.rowPosition : s_cnt - 1 - $0.1.rowPosition, section: s.0))
     }//map result
    }.forEach { self?.photoCollectionView.moveItem(at: $0.from, to: $0.to) }
   })
   {_ in
    completion?()
   }
  }
 }//func repositionItemsIfNeeded(after delay: Int = 1)...
 
 
 func repositionItemsIfNeeded(with delay: DispatchTimeInterval = .seconds(1))
 {
  guard photoSnippet.isRowPositioned else { return }
  let asc = photoSnippet.isSectioned ? true : photoSnippet.ascendingPlain
  
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay)
  {
   for i in 0..<self.photoItems2D.count
   {
    let cnt = self.photoItems2D[i].count
    while let item = self.photoItems2D[i].enumerated().first(where: {(asc ? $0.element.rowPosition : cnt - 1 - $0.element.rowPosition) != $0.offset})
    {
     let row = asc ? item.element.rowPosition : cnt - 1 - item.element.rowPosition
     let moved = self.photoItems2D[i].remove(at: item.offset)
     self.photoItems2D[i].insert(moved, at: row)
     let fromIndexPath = IndexPath(row: item.offset, section: i)
     let toIndexPath = IndexPath(row: row, section: i)
     self.photoCollectionView.moveItem(at: fromIndexPath, to: toIndexPath)
    }
   }
  }
 }//func repositionItemsIfNeeded(with delay: DispatchTimeInterval = .seconds(2))...
 
 func cellIndexPath(with position: PhotoItemPosition) -> IndexPath
 {
  if photoItems2D.isEmpty { return .zero }// return default IndexPath(0,0)...
  // if we move first item, between snippets and destination snippet is empty!
  let section = cellSection(with: position)
  let sectionCount = photoItems2D[section].count
  let row = min(position.row, sectionCount)
  return IndexPath(row: row, section: section)
 }
 
 
 func cellWithHosted(object: NSManagedObject) -> PhotoSnippetCellProtocol?
 {
  photoItems2D.joined().first{ $0.hostedManagedObject.objectID == object.objectID }?.hostingCollectionViewCell
 }
 
 
 func cellSection(with object: PhotoItemManagedObjectProtocol, for groupType: GroupPhotos?) -> Int?
 {
  sectionTitles?.firstIndex(of: object.sectionTitle(for: groupType) ?? "")
 }
 
 func cellSection(with object: PhotoItemManagedObjectProtocol) -> Int?
 {
  cellSection(with: object, for: photoSnippet.photoGroupType)
 }
 
 
 func photoItemIndexPath(with hostedManagedObject: NSManagedObject) -> IndexPath?
 {
  return photoItems2D.enumerated().flatMap
   {s in
    s.1.enumerated().map{(indexPath: IndexPath(row: $0.0, section: s.0), element: $0.1)}
  }.first{ $0.1.hostedManagedObject.objectID == hostedManagedObject.objectID }?.indexPath
 }
 
 
 func photoItemIndexPath(photoItem: PhotoItemProtocol) -> IndexPath?
 {
  guard photoItem.photoManagedObject.id != nil else { return nil }
  
  let path = photoItems2D.enumerated().lazy.map
  {
   (section: $0.offset, item: $0.element.enumerated().lazy.first{$0.element.id == photoItem.id})
   }.first{$0.item != nil}
  
  return path != nil ? IndexPath(row: path!.item!.offset, section: path!.section) : nil
  
 }
 
 
}
