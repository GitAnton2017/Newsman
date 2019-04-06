//
//  Drag Waggle Animation Protocol .swift
//  Newsman
//
//  Created by Anton2016 on 16/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

protocol DragWaggleAnimatable: class
{
 var isDragAnimating: Bool  { get set }
 var waggleView: UIView { get  }
 func dragWaggleBegin()
 func dragWaggleEnd()
 
}
