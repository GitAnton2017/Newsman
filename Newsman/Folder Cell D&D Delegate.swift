//
//  Folder Cell D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 09/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class FolderCellDropViewDelegate: SingleCellDropViewDelegate
{
 override func updateMergedCell()
 {
  
  guard let vc = photoSnippetVC else { return }
  guard let cv = vc.photoCollectionView else { return }
  
  guard let folderCell = self.owner as? PhotoFolderCell else { return }
  guard let mergedFolder = folderCell.hostedItem as? PhotoFolderItem else { return }
  
  let count = mergedFolder.singlePhotoItems.count - folderCell.photoItems.count
  let indexPath = IndexPath(row: folderCell.photoItems.count, section: 0)
  let indexPaths = Array(repeating: indexPath, count: count)
  let itemsToInsert = Set(mergedFolder.singlePhotoItems).subtracting(folderCell.photoItems)
  folderCell.photoItems.append(contentsOf: itemsToInsert)
  folderCell.photoCollectionView.insertItems(at: indexPaths)
  
  guard let zoomView = cv.zoomView else { return }
  guard let hosted = folderCell.hostedItem, hosted.isZoomed else { return }
  
  zoomView.photoItems.append(contentsOf: itemsToInsert)
  (zoomView.presentSubview as? UICollectionView)?.insertItems(at: indexPaths)
  
  
  
 }
 
}
