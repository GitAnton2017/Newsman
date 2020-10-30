//
//  Image Set Operation.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class ImageSetOperation: Operation
{
 var imageSet: [UIImage]?
 
 private var observers = Set<NSKeyValueObservation>()
 
 override init()
 {
  super.init()
  let cnxObserver = observe(\.isCancelled)
  {op, _ in
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
  if isCancelled {return}
  imageSet = dependencies.compactMap{($0 as? ImageSetDataProvider)?.finalImage}
 }
 
 
}
