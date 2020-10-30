//
//  Undo Manager Menu Action Cases.swift
//  Newsman
//
//  Created by Anton2016 on 19/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

enum UndoManagerActions: String, AllCasesSelectorRepresentable
{
 static private var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
 
 var isCaseEnabled: Bool
 {
  get { return UndoManagerActions.enabled[self]! }
  set { UndoManagerActions.enabled[self] = newValue }
 }
 
 var localizedString: String { return §§rawValue }
 
 case undo      = "Undo Last"
 case redo      = "Redo Last"
 case undoAll   = "Undo All"
 case redoAll   = "Redo All"
 case undoTimes = "Undo Multiple"
 case redoTimes = "Redo Multiple"
}
