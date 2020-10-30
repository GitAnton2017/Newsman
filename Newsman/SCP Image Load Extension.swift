//
//  SCP Image Load Extension.swift
//  Newsman
//
//  Created by Anton2016 on 18/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import struct Combine.AnyPublisher

extension PhotoItemProtocol where Self: PhotoItem
{
 var requiredImageWidth: CGFloat
 {
  switch (hostingCollectionViewCell, hostingZoomedCollectionViewCell)
  {
   case let (_ ,  zoomedCell?)  : return zoomedCell.frame.width
   case let (singleCell?, nil)  : return singleCell.frame.width
   default: return 0
  }
 }
 
 
 var imagePublisher: AnyPublisher<UIImage, Never>
 {
  getImagePublisher(requiredImageWidth: requiredImageWidth)
   .compactMap{$0}
   .subscribe(on: DispatchQueue.global(qos: .userInitiated))
   .receive(on: DispatchQueue.main)
   .eraseToAnyPublisher()
 }
}

extension PhotoItemProtocol where Self: PhotoFolderItem
{
 var folderHostingCell: PhotoFolderCell? { hostingCollectionViewCell as? PhotoFolderCell }
 var requiredImageWidth: CGFloat { folderHostingCell?.frameSize ?? 0 }
 var imagesInRow: Int { folderHostingCell?.nphoto ?? 0 }
 var imageCornerRadius: CGFloat { ceil(7 * (1 - 1/exp(CGFloat(imagesInRow) / 5))) }
 
 var imagePublisher: AnyPublisher<UIImage, Never>
 {
  getFolderGridPreviewPublisher(folderSize: requiredImageWidth,
                                imagesInRow: imagesInRow,
                                imageCornerRadius: imageCornerRadius)
   .subscribe(on: DispatchQueue.global(qos: .userInitiated))
   .receive(on: DispatchQueue.main)
   .handleEvents(receiveOutput: { [ weak self ] _ in self?.folderHostingCell?.reloadFolderCell()})
   .eraseToAnyPublisher()
 }
}

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{
 func refreshCellView(_ animated: Bool = true)
 {
  //refreshRowPositionMarker()
  //refreshFlagMarker(
  refreshVideoMarkers()
  updateImage(animated)
  

 
 }
  
 func updateImage(_ animated: Bool = true)
 {
  guard let hostedBefore = self.hostedItem  else { return }
  
  hostedBefore.cellImageUpdateSubscription = hostedBefore.imagePublisher.sink
  { [ weak hostedBefore, weak self ] image in
   guard let self = self else { return }
   guard let hostedAfter = self.hostedItem  else { return }
   guard hostedBefore === hostedAfter  else { return }
   
   if let snipper = self.hostedAccessoryView as? UIActivityIndicatorView
   {
    snipper.stopAnimating()
   }
   
   guard let imageView = self.hostedView as? UIImageView else { return }
   
   if animated && self is PhotoFolderCell == false 
   {
    let duration = (imageView.image == nil) ? 0.05 : 1.25
    
    UIView.transition(with: imageView,
                      duration: duration ,
                      options: [.transitionCrossDissolve, .curveEaseInOut],
                      animations: { imageView.image = image })
   }
   else
   {
    imageView.image = image
   }
   
  }
 }
 

}//extension PhotoSnippetCellProtocol where Self: UICollectionViewCell...

