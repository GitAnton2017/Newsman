//
//  CGPoint Math Extensions.swift
//  Newsman
//
//  Created by Anton2016 on 26.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

infix operator <-> : MultiplicationPrecedence

extension CGPoint
{
 static func -(p2: Self, p1: Self) -> Self { Self(x: p2.x - p1.x, y: p2.y - p1.y) }
 
 static func <->(p2: Self, p1: Self) -> CGFloat
 {
  let diff = p2 - p1
  return sqrt(diff.x * diff.x + diff.y * diff.y)
 }
 
 func rotation(from p1: CGPoint, to p2: CGPoint) -> CGFloat?
 {
  let dx1 = p1.x - x, dx2 = p2.x - x
  let dy1 = p1.y - y, dy2 = p2.y - y
  
  //print("Rotate around center from \(p1) to \(p2)")
  
  let a1 = ( dx1 != 0 ) ? atan(dy1 / dx1) : .pi / 2
  let a2 = ( dx2 != 0 ) ? atan(dy2 / dx2) : .pi / 2
  
  //print("Rotate \(((a1 * 180 / .pi) * 100).rounded() / 100) to \(((a2 * 180 / .pi) * 100).rounded() / 100)")
 
  switch ((dx: dx1, dy: dy1), (dx: dx2, dy: dy2))
  {
   case ((dx: 0..., dy: 0...), (dx: 0..., dy: 0...)): return a2 - a1                   // both p1 & p2 in 1Q
   case ((dx: ...0, dy: 0...), (dx: ...0, dy: 0...)): return a2 - a1                   // both p1 & p2 in 2Q
   case ((dx: ...0, dy: ...0), (dx: ...0, dy: ...0)): return a2 - a1                   // both p1 & p2 in 3Q
   case ((dx: 0..., dy: ...0), (dx: 0..., dy: ...0)): return a2 - a1                   // both p1 & p2 in 4Q
 
   // move 1 <-> 2
   case ((dx: 0..., dy: 0...), (dx: ...0, dy: 0...)): return  .pi - abs(a2) - abs(a1)  //dx>0 dy>0 -> dx<0 dy>0
   case ((dx: ...0, dy: 0...), (dx: 0..., dy: 0...)): return -.pi + abs(a2) + abs(a1)  //dx<0 dy>0 -> dx>0 dy>0
   
   // move 2 <-> 3
   case ((dx: ...0, dy: 0...), (dx: ...0, dy: ...0)): return   abs(a2) + abs(a1)       //dx<0 dy>0 -> dx<0 dy<0
   case ((dx: ...0, dy: ...0), (dx: ...0, dy: 0...)): return  -abs(a2) - abs(a1)       //dx<0 dy<0 -> dx<0 dy<0
   
   // move 3 <-> 4
   case ((dx: ...0, dy: ...0), (dx: 0..., dy: ...0)): return  .pi - abs(a2) - abs(a1)  //dx<0 dy<0 -> dx>0 dy<0
   case ((dx: 0..., dy: ...0), (dx: ...0, dy: ...0)): return -.pi + abs(a2) + abs(a1)  //dx>0 dy<0 -> dx<0 dy<0
   
   // move 4 <-> 1
   case ((dx: 0..., dy: ...0), (dx: 0..., dy: 0...)): return   abs(a2) + abs(a1)       //dx>0 dy<0 -> dx>0 dy>0
   case ((dx: 0..., dy: 0...), (dx: 0..., dy: ...0)): return  -abs(a2) - abs(a1)       //dx>0 dy>0 -> dx>0 dy<0
   
   // move 1 <-> 3 bypassing 2
   case ((dx: 0..., dy: 0...), (dx: ...0, dy: ...0)): return   .pi + abs(a2) - abs(a1) //dx>0 dy>0 -> dx<0 dy<0
   case ((dx: ...0, dy: ...0), (dx: 0..., dy: 0...)): return  -.pi - abs(a2) + abs(a1) //dx<0 dy<0 -> dx>0 dy>0
   
   // move 2 <-> 4 bypassing 3
   case ((dx: ...0, dy: 0...), (dx: 0..., dy: ...0)): return   .pi - abs(a2) + abs(a1) //dx<0 dy>0 -> dx>0 dy<0
   case ((dx: 0..., dy: ...0), (dx: ...0, dy: 0...)): return  -.pi + abs(a2) - abs(a1) //dx>0 dy<0 -> dx<0 dy>0
   
   default: return nil
  }
 }
 
}

