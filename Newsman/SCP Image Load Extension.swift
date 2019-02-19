//
//  SCP Image Load Extension.swift
//  Newsman
//
//  Created by Anton2016 on 18/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{

 func updateImage()
 {
  guard let hosted = self.hostedItem as? PhotoItem else { return }
  
  hosted.getImageOperation(requiredImageWidth:  frame.width)
  {[weak hosted, weak self] (image) in
   
   guard let cell = self else { return }
   guard let photoItem = cell.hostedItem as? PhotoItem else { return }
   guard hosted == photoItem  else { return }
   // we capture hosted weakly by completion closure and use overloaded == operator
   // to check if hosted item is change while we processed required image async...
   
   (cell.hostedAccessoryView as? UIActivityIndicatorView)?.stopAnimating()
   
   cell.refresh(with: image)

  }
 }
 
 func refresh(with image: UIImage? = nil)
 {
  
  switch (self, hostedItem, hostedView, hostedAccessoryView)
  {
   case let (_, is PhotoItem, photoIconView as UIImageView, spinner as UIActivityIndicatorView):
    
   guard let image = image else
   {
//    print ("<<<<<<<<<<UPDATED MORE...>>>>>>>>>>")
    spinner.startAnimating()
    updateImage()
    return
   }
   
    UIView.transition(with: photoIconView, duration: 0.5,
                      options: .transitionCrossDissolve,
                      animations:{photoIconView.image = image},
                      completion:
                      {_ in
                       self.refreshFlagMarker()
                       self.refreshVideoMarkers()
                       self.refreshSpring()
                       {_ in
                        if let folderCell = (self as? PhotoFolderCollectionViewCell)?.owner
                        {
                         folderCell.groupTaskCount += 1
                         if folderCell.groupTaskCount == folderCell.photoCollectionView.visibleCells.count
                         {
                          folderCell.groupTaskCount = 0
                          folderCell.refresh()
                         }
                        }
                        
                       }
                      })
  
   
    default: break

  }//switch (self, hostedItem, hostedView, hostedAccessoryView)...
 }//func refresh(with image: UIImage?)...
 
 
}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell...
