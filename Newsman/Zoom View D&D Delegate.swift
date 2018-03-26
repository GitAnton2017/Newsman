
import Foundation
import UIKit


extension ZoomView: UIDragInteractionDelegate, UIDropInteractionDelegate
{
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem]
    {
     for subView in subviews
     {
       if let _ = subView as? UIImageView
       {
        let photoItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
        photoItem.isSelected = true
        let ip = NSItemProvider(object: photoItem)
        let dragItem = UIDragItem(itemProvider: ip)
        dragItem.localObject = photoItem
        hasNoDraggedSubviews = false
        return [dragItem]
       }
     }
        
     return []
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
    {
     if session.localDragSession == nil
     {
      return UIDropProposal(operation: .copy)
     }
     else
     {
      return UIDropProposal(operation: .move)
     }
    
    }

    
    func copyImagesFromSideApp (_ interaction: UIDropInteraction, with session: UIDropSession)
    {
        session.loadObjects(ofClass: UIImage.self)
        {[weak self] items in
          if let images = items as? [UIImage], images.count > 0,
             let vc = self?.photoSnippetVC,
             let ip = self?.zoomedCellIndexPath,
             let cv = self?.openWithCV(in: vc.view),
             let imageSize = self?.imageSize
          {
            var mergedPhotoItems = [vc.photoItems2D[ip.section][ip.row] as! PhotoItem]
            
            images.forEach
            {image in
             let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth: imageSize)
             newPhotoItem.isSelected = true
             mergedPhotoItems.append(newPhotoItem)
             vc.photoItems2D[ip.section].insert(newPhotoItem, at: ip.row)
             vc.photoCollectionView.insertItems(at: [ip])
            }
            
            if let _ = vc.performMergeIntoFolder(vc.photoCollectionView, from: mergedPhotoItems, into: ip)
            {
             self?.photoItems = mergedPhotoItems
             cv.reloadData()
            }
            else
            {
             print ("\(#function): Unable to merge loaded items into Photo Folder at Index Path: \(ip)")
            }
            
          }
        }
    }
    
    
    func movedOuterPhotoItems (_ interaction: UIDropInteraction, with session: UIDropSession) -> [PhotoItemProtocol]
    {
      var movedItems: [PhotoItemProtocol] = []
      let destin = photoSnippetVC.photoSnippet!
      session.items.map{($0.localObject as! PhotoItemProtocol).photoSnippet}.filter{$0 !== photoSnippetVC.photoSnippet}.forEach
      {source in
       
        let folders: [PhotoItemProtocol] = PhotoItem.moveFolders(from: source, to: destin) ?? []
        let photos : [PhotoItemProtocol] = PhotoItem.movePhotos (from: source, to: destin) ?? []
        
        let totalMoved = photos + folders
        totalMoved.forEach
        {movedItem in
          photoSnippetVC.photoItems2D[zoomedCellIndexPath.section].insert(movedItem, at: zoomedCellIndexPath.row)
          photoSnippetVC.photoCollectionView.insertItems(at: [zoomedCellIndexPath])
        }
        
        movedItems += totalMoved
       
      }
      return movedItems
    }
    
    
    func movePhotoItemsInsideApp (_ interaction: UIDropInteraction, with session: UIDropSession)
    {
     guard session.allowsMoveOperation else {return}

     let zoomedItem = photoSnippetVC.photoItems2D[zoomedCellIndexPath.section][zoomedCellIndexPath.row]
     let localItems = session.items.map{$0.localObject as! PhotoItemProtocol}.filter{$0.photoSnippet === photoSnippetVC.photoSnippet}
     let outerItems = movedOuterPhotoItems(interaction, with: session)
     let totalItems = localItems + outerItems + [zoomedItem]
     outerItems.forEach{$0.isSelected = true}
    
     let photoCV = photoSnippetVC.photoCollectionView!
     
     if let newFolderItem = photoSnippetVC.performMergeIntoFolder(photoCV, from: totalItems, into: zoomedCellIndexPath)
     {
      let cv = openWithCV(in: photoSnippetVC.view)
      let ip = photoSnippetVC.photoItemIndexPath(photoItem: newFolderItem)
      if let newFolderCell = photoCV.cellForItem(at: ip) as? PhotoFolderCell
      {
       zoomedCellIndexPath = ip
       photoItems = newFolderCell.photoItems
       cv.reloadData()
      }
      else
      {
        print ("\(#function): Invalid Merged Folder Cell at Index Path: \(ip)")
      }
     }
     else
     {
      print ("\(#function): Unable to merge into Photo Folder Item at Index Path \(zoomedCellIndexPath)")
     }

    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
    {
      if session.localDragSession != nil
      {
       movePhotoItemsInsideApp (interaction, with: session)
      }
      else
      {
       copyImagesFromSideApp (interaction, with: session)
      }
    }

}
