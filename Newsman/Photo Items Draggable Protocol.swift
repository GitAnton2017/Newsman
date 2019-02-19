//
//  Photo Items Draggable Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

protocol PhotoItemsDraggable: class
{
 var photoSnippet: PhotoSnippet!                   { get     }
 var photoSnippetVC: PhotoSnippetViewController!   { get set }
 
 var isDraggable: Bool                             { get     }
}
