//
//  Photo Item Position.swift
//  Newsman
//
//  Created by Anton2016 on 20/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

struct PhotoItemPosition
{
 static let zero = PhotoItemPosition(0)
 
 let sectionName: String?
 var row: Int
 let sectionKeyPath: String?
 
 init(sectionName: String?, row: Int, for sectionKeyPath: String?)
 {
  self.sectionName = sectionName
  self.sectionKeyPath = sectionKeyPath
  self.row = row
 }
 
 
 init(_ row: Int)
 {
  self.sectionName = nil
  self.sectionKeyPath = nil
  self.row = row
 }
 
 var isFoldered: Bool { sectionName == nil && sectionKeyPath == nil }
 
 var isUnfoldered: Bool { !isFoldered }
}
