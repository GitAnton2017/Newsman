//
//  Snippet Cell Images Loading.swift
//  Newsman
//
//  Created by Anton2016 on 27/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell
{
 final func animateCellRandomImages   (size imageSize: CGFloat?,
                                       firstLoadedImage image: UIImage?,
                                       perImageDuration duration: TimeInterval,
                                       startDelay delay: TimeInterval)
 {
  guard imageSize != nil else { return }
  guard let snippet = self.hostedSnippet else { return }
  
  snippet.imageProvider.getRandomImages(requiredImageWidth: imageSize!)
  { [weak self] (images) in
   guard var images = images else {return}
   guard let cell = self else { return }
   guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
   
   if let firstImage = image {images.insert(firstImage, at: 0)}
   
   SnippetsAnimator.startRandom(for: Array(Set(images)), cell: cell, duration: duration, delay: delay)
   
  }
 }
 
 final func animateCellFistImage  (firstImage: UIImage?,
                                   startDelay: DispatchTimeInterval,
                                   completion: @escaping () -> ())
 {
  guard firstImage != nil else { return }
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + startDelay)
  { [weak self] in
   guard let cell = self else { return }
   cell.imageSpinner.stopAnimating()
   UIView.transition(with: cell.snippetImage,
                     duration: 0.35,
                     options: [.transitionFlipFromTop, .curveEaseInOut],
                     animations: { cell.snippetImage.image = firstImage },
                     completion:
    { [weak self] _ in
     guard let cell = self else { return }
     cell.snippetImage.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
     UIView.animate(withDuration: 0.15,
                    delay: 0.25,
                    usingSpringWithDamping: 3500,
                    initialSpringVelocity: 0,
                    options: .curveEaseInOut,
                    animations: { cell.snippetImage.transform = .identity },
                    completion: { _ in completion() })
   })
   
   
  }
 }
 
 
 
 final func loadFirstImage(size imageSize: CGFloat?)
 {
  guard imageSize != nil else { return }
  guard let snippet = self.hostedSnippet else { return }
  snippet.imageProvider.getLatestImage(requiredImageWidth: imageSize!)
  {[weak self] (image) in
   guard let cell = self else { return }
   guard cell.hostedSnippet?.objectID == snippet.objectID else {return}
   
   cell.animateCellFistImage(firstImage: image, startDelay: .microseconds(200))
   {
    cell.animateCellRandomImages(size: imageSize, firstLoadedImage: image, perImageDuration: 2, startDelay: 5)
   }
  }
 }
 
 
 final func updateCellImageSet(with newSize: CGFloat?)
 {
  guard let newSize = newSize else {return}
  guard let snippet = self.hostedSnippet else {return}
  
  stopImageProvider()
  imageSpinner.startAnimating()
  
  snippet.imageProvider.getLatestImage(requiredImageWidth: newSize)
  {[weak self] image in
   guard image != nil else { return }
   guard let cell = self else { return }
   cell.imageSpinner.stopAnimating()
   guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
   cell.animateCellRandomImages(size: newSize, firstLoadedImage: image, perImageDuration: 2, startDelay: 5)
  }
  
 }
}
