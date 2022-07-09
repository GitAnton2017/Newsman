//
//  Photo Folder Item Undoable.swift
//  Newsman
//
//  Created by Anton2016 on 09/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation


extension PhotoFolderItem: UndoableItem
{
 
 var canUndo: Bool            { return folder.canUndo }
 func undo()                  { folder.undo()         }
 func undo(_ times: Int)      { folder.undo(times)    }
 func undoAll()               { folder.undoAll()      }
 
 
 var canRedo: Bool            { return folder.canRedo }
 func redo()                  { folder.redo()         }
 func redo(_ times: Int)      { folder.redo(times)    }
 func redoAll()               { folder.redoAll()      }
}
