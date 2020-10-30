//
//  Decorations Enum.swift
//  Newsman
//
//  Created by Anton2016 on 19.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

enum Orientaion { case horizontal, vertical }

enum Decoration
{
 case bordered(color: UIColor? = nil, width: CGFloat)
 
 case framed(color: UIColor,
             width: CGFloat,
             margin: CGFloat = 0,
             pattern: [NSNumber] = [10, 5],
             animated: Bool = true,
             overlayed: Bool = true)
 
 static let clearAllFrames = Self.framed(color: .clear, width: 0, pattern: [], animated: false, overlayed: false)
 
 case rounded(radius: CGFloat = 5)
 case capsulated (orientation: Orientaion = .horizontal)
 case filled(color: UIColor? = nil, alpha: CGFloat = 1)
 
 case rotated(angle: CGFloat, anchorPoint: CGPoint? = nil)
 case scaled(x: CGFloat, y: CGFloat)
 case translated(x: CGFloat, y: CGFloat)
 case transformed(with: [CGAffineTransform])
 case identity
 
 case constraints(anchors: [Anchors])
 case constraint (anchor: Anchors)
 
 case masked(with: MaskShape, insets: UIEdgeInsets = .zero, transform: CGAffineTransform = .identity)
 
 case none
}
