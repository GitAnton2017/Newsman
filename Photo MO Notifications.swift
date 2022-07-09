//
//  Photo MO Notifications.swift
//  Newsman
//
//  Created by Anton2016 on 01/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

enum PhotoItemMovedKey: String, Hashable
{
 case destPhoto
 case destFolder
 case sourceFolder
 case sourceSnippet
 case destSnippet
 case position
 case singleItem
 case isSelfFolderedSnippet
 case isSelfMergedSnippet
}

extension Notification.Name
{
 static let photoItemDidRefolder =  Notification.Name(rawValue: "photoItemDidRefolder")
 
 static let photoItemDidUnfolder =  Notification.Name(rawValue: "photoItemDidUnfolder")
 static let photoItemWillUnfolder = Notification.Name(rawValue: "photoItemWillUnfolder")

 static let photoItemDidFolder =    Notification.Name(rawValue: "photoItemDidFolder"  )
 static let photoItemWillFolder =   Notification.Name(rawValue: "photoItemWillFolder"  )
 
 static let photoItemDidMove =      Notification.Name(rawValue: "photoItemDidMove")
 static let photoItemDidMerge =     Notification.Name(rawValue: "photoItemDidMerge")
 
 static let folderedPhotoDidMove =  Notification.Name(rawValue: "folderedPhotoDidMove")
 static let singleItemDidUnfolder = Notification.Name(rawValue: "singleItemDidUnfolder")
}

