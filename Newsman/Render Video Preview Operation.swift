//
//  Render Video Preview Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import AVKit

class RenderVideoPreviewOperation: Operation, ResizeImageDataProvider
{
 var imageToResize: UIImage? { previewImage }
 
 private var contextDepend: VideoPreviewDataProvider?
 {
  dependencies.compactMap{ $0 as? VideoPreviewDataProvider }.first
 }
 
 private var cachedDepend: CachedImageOperation?
 {
  dependencies.compactMap{$0 as? CachedImageOperation}.first
 }
 
 private var videoURL: URL?        { contextDepend?.videoURL         }
 private var cachedImage: UIImage? { cachedDepend?.cachedImage       }
 private var type: SnippetType?    { contextDepend?.imageSnippetType }
 
 private var previewImage: UIImage?
 
 private var observers = Set<NSKeyValueObservation>()
 
 override init()
 {
  super.init()
  
  let cnxObserver = observe(\.isCancelled)
  {op,_ in
   op.removeAllDependencies()
   op.observers.removeAll()
  }
  
  
  let finObserver = observe(\.isFinished)
  {op,_ in
   op.removeAllDependencies()
   op.observers.removeAll()
  }
  
  observers.insert(finObserver)
  observers.insert(cnxObserver)
 }
 
 override func main()
 {
  if isCancelled { return }
  
  guard let url = videoURL, type == .video, cachedImage == nil, previewImage == nil else {return}
  
  do
  {
   let asset = AVURLAsset(url: url, options: nil)
   let imgGenerator = AVAssetImageGenerator(asset: asset)
   imgGenerator.appliesPreferredTrackTransform = true
   let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
   
   if isCancelled { return }
   
   previewImage = UIImage(cgImage: cgImage)
   
  }
  catch let error
  {
   print("ERROR, generating thumbnail from video at URL:\n \"\(url.path)\"\n\(error.localizedDescription)")
  }
  
 }
 
}


