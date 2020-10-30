//
//  Photo Item Creation.swift
//  Newsman
//
//  Created by Anton2016 on 03/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData
import AVKit


extension PhotoItem
{
 class func createNewPhoto (in photoSnippet: PhotoSnippet,
                            with image: UIImage,
                            ofRequiredSize cachedImageWidth: CGFloat,
                            completion: @escaping (_ newPhotoItem: PhotoItem?) -> Void)
 {
  DispatchQueue.global().async
  {
   guard let data = image.jpegData(compressionQuality: 0.95) else
   {
    print ("UNABLE TO CREATE JPEG/PNG DATA FROM PICKED IMAGE")
    DispatchQueue.main.async { completion(nil) }
    return
   }
   
   let newPhotoID = UUID()
   let newPhotoURL = docFolder.appendingPathComponent(photoSnippet.id!.uuidString)
                              .appendingPathComponent(newPhotoID.uuidString)
   
   guard let _ = try? data.write(to: newPhotoURL, options: [.atomic]) else
   {
    print ("JPEG/PNG DATA FILE WRITE ERROR")
    DispatchQueue.main.async {completion(nil)}
    return
   }
   
   print ("JPEG IMAGE OF SIZE \(data.count) bytes SAVED SUCCESSFULLY AT PATH:\n\(newPhotoURL.path)")
   
   cacheThumbnailImage(imageID: newPhotoID.uuidString, image: image, width: Int(cachedImageWidth))
   
   var newPhotoItem: PhotoItem? = nil
   PhotoItem.MOC.performChanges(block:
   {
    let newPhoto = Photo(context: PhotoItem.MOC)
    newPhoto.date = Date() as NSDate
    newPhoto.photoSnippet = photoSnippet
    newPhoto.isSelected = true    //*
    newPhoto.isJustCreated = true //*
    newPhoto.id = newPhotoID
    newPhoto.recordName = newPhotoID.uuidString
    photoSnippet.addToPhotos(newPhoto)
    newPhoto.initAllRowPositions()
    newPhotoItem = PhotoItem(photo: newPhoto)
   })
   {result in
    guard case .success() = result else
    {
     deletePhotoItemFromDisk(at: newPhotoURL)
     DispatchQueue.main.async { completion(nil) }
     return
    }
    
    DispatchQueue.main.async { completion(newPhotoItem) }
    
   }
  }
 }
 
 class func createNewVideo (in photoSnippet: PhotoSnippet,
                            from videoURL: URL,
                            withPreviewSize previewImageWidth: CGFloat,
                            using newVideoID: UUID,
                            completion: @escaping (_ newVideoItem: PhotoItem?) -> Void)
 {
  
 }
 
}
