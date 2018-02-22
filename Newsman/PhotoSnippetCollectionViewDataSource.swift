
import Foundation
import UIKit
import CoreData

//MARK: ============================= CV DATA MODEL EXTENSION ===================================
extension PhotoSnippetViewController
//===============================================================================================
{
//MARK: ---------------- Creating Photo Items 2D model Array ----------------
//---------------------------------------------------------------------------
 func createPhotoItems2D() -> [[PhotoItemProtocol]]
//---------------------------------------------------------------------------
 {
   var photoItems = [[PhotoItemProtocol]]()
   if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
   {
    if let sortPred = GroupPhotos(rawValue: photoSnippet.grouping!)?.sortPredicate
    {
       photoItems.append(allPhotos.filter{$0.folder == nil}.map{PhotoItem(photo: $0)})
        
       if let folders = photoSnippet.folders?.allObjects as? [PhotoFolder]
       {
         photoItems[0].append(contentsOf: folders.map{PhotoFolderItem(folder: $0)})
       }
     
       photoItems[0].sort(by: sortPred)
    }
    else
    {
      photoItems = sectionedPhotoItems()
    }
   }
    
   return photoItems
    
  }//func createPhotoItems2D()...

//MARK: --------------- Creating Sectioned Photo Items ----------------------
//---------------------------------------------------------------------------
 func sectionedPhotoItems() -> [[PhotoItemProtocol]]
//---------------------------------------------------------------------------
 {
  var photoItems = [[PhotoItemProtocol]]()
  if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
  {
   // if photo has no folder we take the photo flag otherwise we take the flag of the folder...
   let flags = allPhotos.map{$0.folder == nil ? $0.priorityFlag ?? "" : $0.folder!.priorityFlag ?? ""}
    
   // sort section titles set by index rate...
   let sections = Set(flags).sorted
   {
       let x0 = PhotoPriorityFlags(rawValue: $0)?.rateIndex ?? -1
       let x1 = PhotoPriorityFlags(rawValue: $1)?.rateIndex ?? -1
       return photoSnippet.ascending ? x0 < x1 : x0 > x1
   }
    
   sections.forEach
   {title in
     var newSection = [PhotoItemProtocol]()
    
     // add all photo folders first...
     if let folders = (photoSnippet.folders?.allObjects as? [PhotoFolder])?.filter({($0.priorityFlag ?? "") == title})
     {
        newSection.append(contentsOf: folders.map{PhotoFolderItem(folder: $0)})
     }
    
     // then add all photos which are not assigned to any existing folder...
     newSection.append(contentsOf: allPhotos.filter {$0.folder == nil && ($0.priorityFlag ?? "") == title}.map{PhotoItem(photo: $0)})
    
     photoItems.append(newSection.sorted{$0.date <= $1.date})
   }
   sectionTitles = sections
  }
  return photoItems    //return all single photos and photo folders sectioned by priority flags...
 } //func sectionedPhotoItems()...
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//MARK: -
    
    
    
 
//MARK: -- Creating Desectioned Photo Items with one (number - 0) section ---
//---------------------------------------------------------------------------
 func desectionedPhotoItems() -> [[PhotoItemProtocol]]
//---------------------------------------------------------------------------
 {
  var photoItems = [[PhotoItemProtocol]]()
  if let allPhotos = photoSnippet.photos?.allObjects as? [Photo]
  {
    photoItems.append(allPhotos.filter{$0.folder == nil}.map{PhotoItem(photo: $0)})
    if let folders = photoSnippet.photos?.allObjects as? [PhotoFolder]
    {
      photoItems[0].append(contentsOf: folders.map{PhotoFolderItem(folder: $0)})
    }
  }
  sectionTitles = nil //no sectiones ...no sections titles....
  return photoItems
 } //func desectionedPhotoItems()...
//----------------------------------------------------------------------------
//MARK: -

    
    
//MARK: ------------ Searching for Index path by Photo Item ID ---------------
//----------------------------------------------------------------------------
 func photoItemIndexPath(photoItem: PhotoItemProtocol) -> IndexPath
//----------------------------------------------------------------------------
 {
  let path = photoItems2D.enumerated().lazy.map
  {
   (section: $0.offset, item: $0.element.enumerated().lazy.first{$0.element.id == photoItem.id})
  }.first{$0.item != nil}
  
  return IndexPath(row: path!.item!.offset, section: path!.section)
    
 }//func photoItemIndexPath(photoItem: PhotoItemProtocol)...
//----------------------------------------------------------------------------
//MARK: -
    

    
//MARK: ----------------- Deleting Selected Photo Items ----------------------
//----------------------------------------------------------------------------
 func deleteSelectedPhotos()
//----------------------------------------------------------------------------
 {
  for (sectionIndex, section) in photoItems2D.enumerated().filter({$0.element.first(where: {$0.isSelected}) != nil}).sorted(by: {$0.offset > $1.offset})
  {
      for (itemIndex, _) in section.enumerated().filter({$0.element.isSelected}).sorted(by: {$0.offset > $1.offset})
      {
          let deletedItem = photoItems2D[sectionIndex].remove(at: itemIndex)
          deletedItem.deleteImages()
          let itemIndexPath = IndexPath(row: itemIndex, section: sectionIndex)
          photoCollectionView.deleteItems(at: [itemIndexPath])
      }
      if photoCollectionView.photoGroupType == .makeGroups
      {
          photoCollectionView.reloadSections([sectionIndex])
      }
  }
  
  for section in photoItems2D.enumerated().filter({$0.element.count == 0}).sorted(by: {$0.offset > $1.offset})
  {
      photoItems2D.remove(at: section.offset)
      sectionTitles?.remove(at: section.offset)
      photoCollectionView.deleteSections([section.offset])
  }
  
 }// func deleteSelectedPhotos()...
//----------------------------------------------------------------------------
//MARK: -
    
    
    
//MARK: ----------------- Marking Selected Sectioned Photo Items -------------
//----------------------------------------------------------------------------
 func flagGroupedSelectedPhotos(with flagStr: String?)
//----------------------------------------------------------------------------
 {
   photoItems2D.reduce([], {$0 + $1.filter({$0.isSelected})}).forEach
   {
    var selected = $0
    selected.isSelected = false
    let itemIndexPath = photoItemIndexPath(photoItem: selected)
    photoCollectionView.movePhoto(at: itemIndexPath, with: flagStr)
   }
 }//func flagGroupedSelectedPhotos(with flagStr: String?)...
//----------------------------------------------------------------------------
    
} //extension PhotoSnippetViewController...
//----------------------------------------------------------------------------
//MARK: -
//MARK: -



//MARK: ------------------ CV SECTIONES HEADER CLASSES -----------------------

//----------------------------------------------------------------------------
class PhotoSectionHeader: UICollectionReusableView
//----------------------------------------------------------------------------
{
  @IBOutlet weak var headerLabel: UILabel!
}//class PhotoSectionHeader...
//----------------------------------------------------------------------------
class PhotoSectionFooter: UICollectionReusableView
//----------------------------------------------------------------------------
{
  @IBOutlet weak var footerLabel: UILabel!
}//class PhotoSectionFooter...
//----------------------------------------------------------------------------

//MARK: -


//MARK: +++++++++++++++++++ CV DATA SOURCE EXTENSION  +++++++++++++++++++++++++

extension PhotoSnippetViewController: UICollectionViewDataSource
    
//-----------------------------------------------------------------------------
{
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
     return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
      if photoCollectionView.photoGroupType != .makeGroups
      {
        let movedItem = photoItems2D[0].remove(at: sourceIndexPath.row)
        photoItems2D[0].insert(movedItem, at: destinationIndexPath.row)
        
        for i in 0..<photoItems2D[0].count
        {
          photoItems2D[0][i].position = Int16(i)
        }
        
        photoSnippet.grouping = GroupPhotos.manually.rawValue
      }
      else
      {
        var movedItem = photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        photoItems2D[destinationIndexPath.section].insert(movedItem, at: destinationIndexPath.row)
        let flagStr = sectionTitles![destinationIndexPath.section]
        movedItem.priorityFlag = flagStr.isEmpty ? nil : flagStr
        collectionView.reloadSections([sourceIndexPath.section, destinationIndexPath.section])
        defer
        {
         if photoItems2D[sourceIndexPath.section].isEmpty
         {
          sectionTitles!.remove(at: sourceIndexPath.section)
          photoItems2D.remove(at: sourceIndexPath.section)
          collectionView.deleteSections([sourceIndexPath.section])
         }
        }
      }
 }
//MARK:-------------------------GENERATING CV SECTION HEADERS -------------------------
    
 func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView
    
//-------------------------------------------------------------------------------------
 {
     switch (kind)
     {
      case UICollectionElementKindSectionHeader:
        
       let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseIdentifier: "photoSectionHeader",
                                                                  for: indexPath) as! PhotoSectionHeader
       

       if photoCollectionView.photoGroupType == .makeGroups, let titles = sectionTitles
       {
        let title = (titles[indexPath.section].isEmpty) ? "Not Flagged Yet" : titles[indexPath.section]
        view.headerLabel.text = NSLocalizedString(title, comment: title)
        if let color = PhotoPriorityFlags(rawValue: titles[indexPath.section])?.color
        {
          view.backgroundColor = color
        }
        else
        {
         view.backgroundColor = UIColor.lightGray
        }
       }
       return view
       
        
      case UICollectionElementKindSectionFooter:
        
       let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseIdentifier: "photoSectionFooter",
                                                                  for: indexPath) as! PhotoSectionFooter
       if photoCollectionView.photoGroupType == .makeGroups
       {
        view.backgroundColor = collectionView.backgroundColor
        let itemsCount = photoItems2D[indexPath.section].count
        view.footerLabel.text = NSLocalizedString("Total photos in group", comment: "Total photos in group") + ": \(itemsCount)"
       }
       return view
        
      default:  return UICollectionReusableView()
     }
    
 } //func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind...
//-----------------------------------------------------------------------------------
//MARK: -

    
//MARK:----------------------- GETTING CV NUMBER OF SECTIONS -----------------------------
    
 func numberOfSections(in collectionView: UICollectionView) -> Int
    
//----------------------------------------------------------------------------------------
 {
    
   return photoItems2D.count // the number of vectors in 2D model array...
    
 }//func numberOfSections(in collectionView...
//----------------------------------------------------------------------------------------
//MARK: -

    
    
//MARK:----------------------- GETTING CV NUMBER ITEMS IN SECTIONS -----------------------
    
 func collectionView(_ collectionView: UICollectionView,
                       numberOfItemsInSection section: Int) -> Int
    
//----------------------------------------------------------------------------------------
 {
    
   return photoItems2D[section].count //the size of each vector in 2D model array...
    
 }//func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection...
//----------------------------------------------------------------------------------------

    
//MARK:----------------------------------- GETTING CV REQUIRED SINGLE PHOTO ITEM CELL --------------------------------
 func getPhotoCell (_ collectionView: UICollectionView, at indexPath: IndexPath, with photoItem: PhotoItem) -> PhotoSnippetCell
//--------------------------------------------------------------------------------------------------------------------
 {
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSnippetCell", for: indexPath) as! PhotoSnippetCell
    
  let photoCV = collectionView as! PhotoSnippetCollectionView
    
  photoCV.layer.addSublayer(cell.layer)
    
  if let path = photoCV.menuIndexPath, path == indexPath
  {
   let cellPoint = CGPoint(x: round(cell.frame.width * photoCV.menuShift.x), y: round(cell.frame.height * photoCV.menuShift.y))
    
   let menuPoint = cell.photoIconView.layer.convert(cellPoint, to: photoCV.layer)
    
   photoCV.drawCellMenu(menuColor: #colorLiteral(red: 0.8867584074, green: 0.8232105379, blue: 0.7569611658, alpha: 1), touchPoint: menuPoint, menuItems: mainMenuItems)
    
  }
 
  cell.photoIconView.alpha = photoItem.isSelected ? 0.5 : 1
    
  if let flag = photoItem.priorityFlag, let color = PhotoPriorityFlags(rawValue: flag)?.color
  {
   cell.drawFlag(flagColor: color)
  }
  else
  {
   cell.clearFlag()
  }
    
  photoItem.getImage(requiredImageWidth:  imageSize)
  {(image) in
    cell.photoIconView.image = image
    cell.photoIconView.layer.contentsGravity = kCAGravityResizeAspect
    
    if let img = image
    {
      if img.size.height > img.size.width
      {
         let r = img.size.width/img.size.height
         cell.photoIconView.layer.contentsRect = CGRect(x: 0, y: (1 - r)/2, width: 1, height: r)
      }
      else
      {
         let r = img.size.height/img.size.width
         cell.photoIconView.layer.contentsRect = CGRect(x: (1 - r)/2, y: 0, width: r, height: 1)
      }
     }
    
     cell.spinner.stopAnimating()
   }
    
   return cell
    
 }//func getPhotoCell (_ collectionView: UICollectionView...
//---------------------------------------------------------------------------------------------------------------------
//MARK: -

    
//MARK:---------------------- GETTING CV REQUIRED PHOTO FOLDER ITEM CELL ----------------------------------------------
 func getFolderCell (_ collectionView: UICollectionView, at indexPath: IndexPath, with photoFolder: PhotoFolderItem) -> PhotoFolderCell
//---------------------------------------------------------------------------------------------------------------------
 {
   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFolderCell", for: indexPath) as! PhotoFolderCell

    
    if let items = photoFolder.folder.photos?.allObjects as? [Photo]
    {
        cell.ds.photoItems = items.map{PhotoItem(photo: $0)}
        
    }
    else
    {
        cell.ds.photoItems = []
    }
    

    cell.photoCollectionView.reloadData()
   
    
   return cell
    
 }//func getFolderCell (_ collectionView: UICollectionView,...
//------------------------------------------------------------------------------------------------------------------
//MARK: -

//MARK:------------------------------------- GETTING CV GENERALIZED CELL -------------------------------------------
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
//------------------------------------------------------------------------------------------------------------------
 {
   switch (photoItems2D[indexPath.section][indexPath.row])
   {
    case let item as PhotoItem:
     return getPhotoCell (collectionView, at: indexPath, with: item)
    case let item as PhotoFolderItem:
     return getFolderCell(collectionView, at: indexPath, with: item)
    default:
     return UICollectionViewCell()
   }
 }
}//func collectionView(_ collectionView: UICollectionView,...
//-----------------------------------------------------------------------------------------------------------------
//MARK: -
