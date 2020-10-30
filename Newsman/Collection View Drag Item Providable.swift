//
//  Collection View Drag Item Providable.swift
//  Newsman
//
//  Created by Anton2016 on 03.07.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import struct UIKit.IndexPath

protocol CollectionViewDragItemProvidable
{
 func draggedItem(at indexPath: IndexPath) -> Draggable?
}

