//
//  Photo Snippet CV Headers & Footers.swift
//  Newsman
//
//  Created by Anton2016 on 20/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class DecoratedReusableView: UICollectionReusableView
{
 override final func didMoveToSuperview()
 {
  super.didMoveToSuperview()
  layer.borderColor = superview?.backgroundColor?.cgColor
 }
 
 override final func awakeFromNib()
 {
  super.awakeFromNib()
  layer.cornerRadius = 10.0
  layer.borderWidth = 2
 }
}


final class PhotoSectionHeader: DecoratedReusableView
{
 static let reuseID = "photoSectionHeader"
 @IBOutlet weak var headerLabel: UILabel!

}


final class PhotoSectionFooter: DecoratedReusableView
{
 static let reuseID = "photoSectionFooter"
 @IBOutlet weak var footerLabel: UILabel!
 
}


extension PhotoSnippetViewController
{
 
 func updateSectionFooter(for sectionIndex: Int)
 {
  let kind = UICollectionView.elementKindSectionFooter
  let indexPath = IndexPath(row: 0, section: sectionIndex)
  
  guard let footer = photoCollectionView.supplementaryView(forElementKind: kind, at: indexPath) as? PhotoSectionFooter else { return }
  
  footer.footerLabel.text = footerLabel(for: sectionIndex)
 
 }
 
 func updateSectionsFooters(for sectionIndexes: [Int])
 {
  sectionIndexes.forEach{ updateSectionFooter(for: $0) }
 }
 
 
 func makeSectionHeader(for indexPath: IndexPath) -> PhotoSectionHeader
 {
  let kind = UICollectionView.elementKindSectionHeader
  let header = photoCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoSectionHeader.reuseID, for: indexPath) as! PhotoSectionHeader
  
  header.headerLabel.text = nil
  guard photoCollectionView.photoGroupType?.isSectioned ?? false else { return header }
  guard let titleStr = sectionTitles?[indexPath.section] else { return header }
  let title = photoCollectionView.photoGroupType?.sectionType?.init(rawValue: titleStr)
  header.headerLabel.text = title?.localizedString
  header.backgroundColor = title?.color

  return header
  
 }
 
 func footerLabel(for section: Int) -> String
 {
  let photoCount = photoItems2D[section].filter{$0 is PhotoItem}.count
  let folderCount = photoItems2D[section].filter{$0 is PhotoFolderItem}.count
  
  switch (photoCount, folderCount)
  {
   case (1..., 1...): let total = photoCount + folderCount
    return §§"Total photos & folders in group" + " : \(total) (\(photoCount)/\(folderCount))"
   case (1..., 0   ):  return §§"Total photos in group"  + " : \(photoCount)"
   case (0  , 1... ):  return §§"Total folders in group" + " : \(folderCount)"
   default: return ""
  }
  
 }
 func makeSectionFooter(for indexPath: IndexPath) -> PhotoSectionFooter
 {
  let kind = UICollectionView.elementKindSectionFooter
  let footer = photoCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoSectionFooter.reuseID, for: indexPath) as! PhotoSectionFooter
  
  footer.footerLabel.text = nil
  
  guard photoCollectionView.photoGroupType?.isSectioned ?? false else { return footer }
  footer.footerLabel.text = footerLabel(for: indexPath.section)
  footer.backgroundColor = UIColor(white: 0, alpha: 0.05)
  
  return footer
 
 }
 
 
 func collectionView(_ collectionView: UICollectionView,
                     viewForSupplementaryElementOfKind kind: String,
                     at indexPath: IndexPath) -> UICollectionReusableView
  
 {
 
  switch (kind)
  {
   case UICollectionView.elementKindSectionHeader: return makeSectionHeader(for: indexPath)
   case UICollectionView.elementKindSectionFooter: return makeSectionFooter(for: indexPath)
   default: return UICollectionReusableView()
  }
  
 }
 
 
 
 func collectionView(_ collectionView: UICollectionView,
                     willDisplaySupplementaryView view: UICollectionReusableView,
                     forElementKind elementKind: String, at indexPath: IndexPath)
 {
  switch (elementKind, view)
  {
   case let (UICollectionView.elementKindSectionHeader, view as PhotoSectionHeader):
    view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.height)
    view.headerLabel.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    view.alpha = 0.5
    UIView.animate(withDuration: 0.25, delay: 0,
                   usingSpringWithDamping: 0.6,
                   initialSpringVelocity: 15,
                   options: .curveEaseInOut,
                   animations:
                   {
                     view.transform = .identity
                     view.alpha = 1
                   }, completion:
                   {_ in
                    UIView.animate(withDuration: 0.25, delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 15,
                                   options: .curveEaseInOut,
                                   animations:
                                   {
                                     view.headerLabel.transform = .identity
                                     view.alpha = 1
                                   }, completion: {_ in } )
                   } )
   
   case let (UICollectionView.elementKindSectionFooter, view as PhotoSectionFooter):
    view.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
    view.alpha = 0.5
    UIView.animate(withDuration: 0.55, delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 15,
                   options: .curveEaseInOut,
                   animations:
                   {
                    view.transform = .identity
                    view.alpha = 1
                   }, completion: {_ in } )
    default: break
  }
  
  
  
 }
  
 
}


