//
//  Photo Snippet CV DS Grouping.swift
//  Newsman
//
//  Created by Anton2016 on 20/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetViewController
{
 
 func updateSnippet()
 {
  let pairs = photoSnippet.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  pairs.forEach
  {pair in
   switch pair
   {
    case let (#keyPath(PhotoSnippet.grouping), oldValue as String)
     where GroupPhotos(rawValue: oldValue)!.isUnsectioned && photoSnippet.isSectioned:
      moveToSectionedItems()
     
    case let (#keyPath(PhotoSnippet.grouping), oldValue as String)
     where GroupPhotos(rawValue: oldValue)!.isSectioned && photoSnippet.isUnsectioned:
      moveToUnsectionedItems()
     
    case let (#keyPath(PhotoSnippet.grouping), oldValue as String)
     where GroupPhotos(rawValue: oldValue)!.isUnsectioned && photoSnippet.isUnsectioned:
      moveUnsectionedItems()
     
    case let (#keyPath(PhotoSnippet.grouping), oldValue as String)
     where GroupPhotos(rawValue: oldValue)!.isSectioned && photoSnippet.isSectioned:
      moveSectionedItems()
     
    case (#keyPath(PhotoSnippet.ascending), _ ) : moveSections()
     
    case (#keyPath(PhotoSnippet.ascendingPlain), _ ) : moveUnsectionedItems()
    
    default: break
   }
  }
 } //func updateSnippet()...
 
 
 
 func reloadCellsIfNeeded(at updateIndexPaths: [IndexPath], with completion: ( () -> () )? = nil)
 {
  let updated = updateIndexPaths.filter
  {
   let cell = photoCollectionView.cellForItem(at: $0)
   let hostingCell = photoItems2D[$0.section][$0.row].hostingCollectionViewCell
   return cell !== hostingCell
   
  }
  photoCollectionView.performBatchUpdates({ photoCollectionView.reloadItems(at: updated) })
  {_ in
   updateIndexPaths.compactMap
   {self.photoCollectionView.cellForItem(at: $0) as? PhotoSnippetCellProtocol}.forEach
   {cell in
    cell.refreshRowPositionMarker()
   }
   completion?()
  }
  
 }// func reloadCellsIfNeeded...
 
 
 
 func reloadCellsIfNeeded(for sections: [Int], with completion: ( () -> () )? = nil)
 {
  photoCollectionView.performBatchUpdates(
  {
   sections.forEach
   {section in
    photoItems2D[section].enumerated().forEach
    {(row, item) in
     let indexPath = IndexPath(row: row, section: section)
     let cell = photoCollectionView.cellForItem(at: indexPath)
     let hostingCell = photoItems2D[section][row].hostingCollectionViewCell
     if (cell !== hostingCell) { photoCollectionView.reloadItems(at: [indexPath]) }
     (cell as? PhotoSnippetCellProtocol)?.refreshRowPositionMarker()
    }  //photoItems2D[section].enumerated().forEach...
   }  //sections.forEach...
  })
  {_ in
   completion?()
  }
  
  //photoCollectionView.performBatchUpdates...
 }  //func reloadCellsIfNeeded...
 
 
 
 func moveUnsectionedItems()
 {
  if photoItems2D.isEmpty { return }
  
  guard let pred = photoSnippet.photoGroupType?.sortPredicate else { return }
  
  let sortedPairs = photoItems2D[0].enumerated().sorted { pred($0.1, $1.1, photoSnippet.ascendingPlain) }
  
  let movePairs = sortedPairs.map{ $0.offset }.enumerated()
  
  var updateIndexPaths = [IndexPath]()
  
  UIView.animate(withDuration: 0.85, delay: 0,
                 usingSpringWithDamping: 0.9, initialSpringVelocity: 10,
                 options: [.curveEaseInOut],
                 animations:
   {
    self.photoCollectionView.performBatchUpdates(
    {
     self.photoItems2D[0] = sortedPairs.map{$0.element}
     movePairs.forEach
     {item in
      let fromIndexPath = IndexPath(row: item.element, section: 0)
      let toIndexPath   = IndexPath(row: item.offset,  section: 0)
      self.photoCollectionView.moveItem(at: fromIndexPath, to: toIndexPath )
      updateIndexPaths.append(toIndexPath)
     }
    })
    {_ in
     self.reloadCellsIfNeeded(at: updateIndexPaths)
     //self.saveContext()
    }
  }) //UIView.animate...
  
 } //func moveUnsectionedItems()...
 
 
 
 
 func moveSections()
 {
  if photoItems2D.isEmpty { return }
  guard let pred = photoSnippet.photoGroupType?.sectionOrderPredicate(ascending: photoSnippet.ascending) else
  { return }
  
  let sortedPairs = photoItems2D.enumerated().sorted
  {
   let t1 = $0.element.first?.sectionTitle ?? ""
   let t2 = $1.element.first?.sectionTitle ?? ""
   return pred(t1, t2)
  }
  
  var sections: [Int] = []
  
  UIView.animate(withDuration: 0.85, delay: 0,
                 usingSpringWithDamping: 0.95,
                 initialSpringVelocity: 5,
                 options: [.curveEaseInOut], animations:
  {
   self.photoCollectionView.performBatchUpdates(
   {
    self.photoItems2D = sortedPairs.map{$0.element}
    self.sectionTitles?.sort(by: pred)
    
    sortedPairs.map{$0.offset}.enumerated().forEach
    {
     self.photoCollectionView.moveSection($0.element, toSection: $0.offset)
     sections.append($0.offset)
    }
   })
   {_ in
    self.reloadCellsIfNeeded(for: sections)
   }
  })
  
 } //func moveSections()...
 

 func moveToSectionedItems()
 {
  if photoItems2D.isEmpty { return }
  
  let unsectioned = photoItems2D[0].enumerated()
  let titles = photoSnippet.sortedSectionTitles
  
  photoCollectionView.performBatchUpdates(
  {
   sectionTitles = titles.contains("") ? titles : (photoSnippet.ascending ? [""] + titles :  titles + [""])
   
   let emptySections = Array<[PhotoItemProtocol]>(repeating: [], count: sectionTitles!.count - 1)
   self.photoItems2D.insert(contentsOf: emptySections, at: photoSnippet.ascending ? 1 : 0)
   let indexes = sectionTitles!.enumerated().filter{!$0.element.isEmpty}.map{$0.offset}
   photoCollectionView.insertSections(IndexSet(indexes))
  })
  {_ in
   self.photoItems2D = self.photoSnippet.photoItems2D
   let fromSection = self.sectionTitles!.firstIndex(of: "")!
   if self.sectionTitles!.count > self.photoItems2D.count
   {
    self.photoItems2D.insert([], at: fromSection)
   }
   
   let indexPathPairs = unsectioned.map
   {
    (atIndexPath: IndexPath(row: $0.offset, section: fromSection),
     toIndexPath: self.photoItemIndexPath(with: $0.element.hostedManagedObject)!)
   }
   
   UIView.animate(withDuration: 0.85, delay: 0,
                  usingSpringWithDamping: 0.9,
                  initialSpringVelocity: 15,
                  options: [.curveEaseInOut],
                  animations:
    {
     self.photoCollectionView.performBatchUpdates(
     {
      indexPathPairs.forEach
      {
        self.photoCollectionView.moveItem(at: $0.atIndexPath, to: $0.toIndexPath)
        self.updateSectionFooter(for: $0.toIndexPath.section)
      }
     })
     {_ in
      self.reloadCellsIfNeeded(at: indexPathPairs.map{$0.toIndexPath})
      
      if self.photoItems2D[fromSection].isEmpty
      {
       self.photoItems2D.remove(at: fromSection)
       self.sectionTitles?.remove(at: fromSection)
       self.photoCollectionView.deleteSections([fromSection])
      }
      
      //self.saveContext()
     }
   })
  }
 }//func moveToSectionedItems()...
 
 
 
 
 func moveToUnsectionedItems()
 {
  if photoItems2D.isEmpty
  {
   sectionTitles = nil
   return
  }
  
  self.photoCollectionView.performBatchUpdates(
  {
    if ( !self.sectionTitles!.contains("") )
    {
     let pos = self.photoSnippet.ascending ? 0 : self.sectionTitles!.count
     self.sectionTitles!.insert("", at:  pos)
     self.photoItems2D.insert([], at: pos)
     self.photoCollectionView.insertSections([pos])
    }
    
  })
  { _ in
   
   let singleSection = self.sectionTitles!.firstIndex(of: "")!
   
   let unsectioned = self.photoSnippet.photoItems2D
   
   let indexPathPairs = unsectioned.first!.enumerated().map
   {
    (atIndexPath: self.photoItemIndexPath(with: $0.element.hostedManagedObject)!,
     toIndexPath: IndexPath(row: $0.offset, section: singleSection))
   }
   
   let indexes = self.sectionTitles!.enumerated().filter{!$0.element.isEmpty}.map{$0.offset}
   
   UIView.animate(withDuration: 0.85, delay: 0,
                  usingSpringWithDamping: 0.9,
                  initialSpringVelocity: 15,
                  options: [.curveEaseInOut],
                  animations:
    {
     self.photoCollectionView.performBatchUpdates(
     {
       indexes.forEach{ self.photoItems2D[$0].removeAll() }
       self.photoItems2D[singleSection] = unsectioned.first!
       indexPathPairs.forEach { self.photoCollectionView.moveItem(at: $0.atIndexPath, to: $0.toIndexPath) }
       
     })
     {_ in
      
      self.reloadCellsIfNeeded(at: indexPathPairs.map{$0.toIndexPath})
      //self.saveContext()
      self.photoCollectionView.performBatchUpdates(
      {
        self.photoItems2D = unsectioned
        self.sectionTitles = nil
        self.photoCollectionView.deleteSections(IndexSet(indexes))
      })
     }
   })
  }
 }//func moveToUnsectionedItems()...
 
 
 func moveSectionedItems()
 {
  if photoItems2D.isEmpty { return }
  UIView.performWithoutAnimation
  {
   self.photoCollectionView.performBatchUpdates(
   {
    if ( !self.sectionTitles!.contains("") )
    {
     let pos = self.photoSnippet.ascending ? 0 : self.sectionTitles!.count
     self.sectionTitles!.insert("", at:  pos)
     self.photoItems2D.insert([], at: pos)
     self.photoCollectionView.insertSections([pos])
    }
   })
   { _ in
    
    let singleSection = self.sectionTitles!.firstIndex(of: "")!
    
    let desectioned = [self.photoSnippet.allItems]
    
    let indexPathPairs = desectioned.first!.enumerated().map
    {
     (atIndexPath: self.photoItemIndexPath(with: $0.element.hostedManagedObject)!,
      toIndexPath: IndexPath(row: $0.offset, section: singleSection))
    }
    
    let indexes = self.sectionTitles!.enumerated().filter{!$0.element.isEmpty}.map{$0.offset}
    
    UIView.performWithoutAnimation
    {
     self.photoCollectionView.performBatchUpdates(
     {
       indexes.forEach{ self.photoItems2D[$0].removeAll() }
       self.photoItems2D[singleSection] = desectioned.first!
       indexPathPairs.forEach { self.photoCollectionView.moveItem(at: $0.atIndexPath, to: $0.toIndexPath) }
      
     })
     {_ in
      
      self.reloadCellsIfNeeded(at: indexPathPairs.map{$0.toIndexPath})
      UIView.performWithoutAnimation
      {
       self.photoCollectionView.performBatchUpdates(
       {
         self.photoItems2D = desectioned
         self.sectionTitles = nil
         self.photoCollectionView.deleteSections(IndexSet(indexes))
       })
       {_ in
        self.moveToSectionedItems()
       }
      } //UIView.performWithoutAnimation...
     }
    }
   } //UIView.performWithoutAnimation...
  } //UIView.performWithoutAnimation...
 }//func moveSectionedItems()...
 
 
}// extension PhotoSnippetViewController
