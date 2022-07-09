//
//  Photo Item Undoable.swift
//  Newsman
//
//  Created by Anton2016 on 09/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension PhotoItem: UndoableItem
{
 
 var canUndo: Bool            { return photo.canUndo }
 func undo()                  { photo.undo()         }
 func undo(_ times: Int)      { photo.undo(times)    }
 func undoAll()               { photo.undoAll()      }
 
 
 var canRedo: Bool            { return photo.canRedo }
 func redo()                  { photo.redo()         }
 func redo(_ times: Int)      { photo.redo(times)    }
 func redoAll()               { photo.redoAll()      }
}
