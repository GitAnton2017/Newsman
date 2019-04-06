//
//  Draggable Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

func == (lhs: Draggable?, rhs: Draggable?) -> Bool
{
 return lhs?.hostedManagedObject === rhs?.hostedManagedObject
}

protocol Draggable: class
{
 var dragSession: UIDragSession?           { get set }
 
 var id: UUID                              { get     }
 
 var hostedManagedObject: NSManagedObject  { get     } // ref to the MO wrapped in conformer
 
 var isSelected: Bool                      { get set } // managed state by MO wrapped in conformer...
 var isDragAnimating: Bool                 { get set } // not managed...
 var isSetForClear: Bool                   { get set } // not managed...
 //this state is traced to avoid multiple clearance animations to be fired for cell when drop session ends...
 
 var isFolderDragged: Bool                 { get     }
 var isZoomed: Bool                        { get set } // not manged state if dragged is zoomed-in
 
 var zoomView: ZoomView?                   { get set }
 // the weak ref to open ZoomView is needed to update animatiom and selection state when
 // the entire PhotoFolderItem is being dragged and displayed in ZoomView
 
 var dragAnimationCancelWorkItem: DispatchWorkItem? { get set }
 
 func move(to snippet: BaseSnippet, to draggableItem: Draggable?)
 
}



