//
//  D&D Subject States.swift
//  Newsman
//
//  Created by Anton2016 on 22.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

enum DragAndDropDelegateStates : Equatable
{
 static let minProceedMove: CGFloat = 10.0
 
 static func == (lhs: DragAndDropDelegateStates, rhs: DragAndDropDelegateStates) -> Bool
 {
  switch (lhs, rhs)
  {
   case (.initial, .initial) :                  return true
   case (.begin,   .begin) :                    return true
   case let (.enter(v1, l1), .enter(v2, l2)) :  return v1 === v2 && l1 == l2
   case let (.exit(v1, l1),  .exit(v2, l2)) :   return v1 === v2 && l1 == l2
   case (.end,     .end)   :                    return true
   case let (.proceed(l1), .proceed(l2)) :      return l1 <-> l2 <= minProceedMove
   case let (.drop (c1, ip1), .drop(c2, ip2)) : return c1 == c2 && ip1 == ip2
   case let (.flock(d1), .flock(d2)):           return d1 == d2
   case (.final , .final)  :                    return true
   default:                                     return false
  }
 }
 
 case initial
 case begin 
 case flock(dragItem: Draggable)
 case enter(view: UIView?, at: CGPoint?)
 case exit(view: UIView?, at: CGPoint?)
 case drop(eventCount: Int, destination: IndexPath?)
 case proceed(location: CGPoint)
 case end
 case final
}
