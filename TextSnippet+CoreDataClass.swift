//
//  TextSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TextSnippet) public class TextSnippet: BaseSnippet, SnippetImagesPreviewProvidable
{
 
 override var fields: [String] { return super.fields + [#keyPath(TextSnippet.text)] }
 
 // #keyPathes to react to changes in frc delegate...
 
 lazy var imageProvider: SnippetPreviewImagesProvider = {TextPreviewProvider(textSnippet: self)}()
 
 override func initStorage()
 {
  self.text = "Enter Snippet Text Here..."
 }
}
