//
//  Snippet Items Draggable Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 03.07.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import enum UIKit.UIUserInterfaceIdiom
import enum UIKit.UIUserInterfaceSizeClass
import class UIKit.UIViewController

protocol SnippetItemsDraggable: ContentDraggable
{
 var snippet: BaseSnippet?                         { get }
 var snippetViewController: UIViewController?      { get }
}

extension SnippetItemsDraggable
{
 var deviceType: UIUserInterfaceIdiom
 {
  snippetViewController?.traitCollection.userInterfaceIdiom ?? .unspecified
 }
 
 var vsc: UIUserInterfaceSizeClass
 {
  snippetViewController?.traitCollection.verticalSizeClass ?? .unspecified
 }
 
 var hsc: UIUserInterfaceSizeClass
 {
  snippetViewController?.traitCollection.horizontalSizeClass ?? .unspecified
 }
}

extension SnippetItemsDraggable where Self: PhotoSnippetViewController
{
 var snippet: BaseSnippet? { photoSnippet }
 var snippetViewController: UIViewController? { self }
 
 var isContentDraggable: Bool
 {

  switch (photosInRow, deviceType, vsc, hsc) {
   case (3...maxPhotosInRow - 4 , .phone, .regular, .compact),
        (4...maxPhotosInRow - 3 , .phone, .compact, .compact),
        (5...maxPhotosInRow - 2 , .phone, .compact, .regular),
        (7...maxPhotosInRow     , .pad,   .regular, .regular) : return true
   
   default: return false
  }
 }
}

extension SnippetItemsDraggable where Self: PhotoSnippetCellProtocol
{
 var snippet: BaseSnippet? { photoSnippet }
 var snippetViewController: UIViewController? { photoSnippetVC }
 
 var itemsInRow: Int { photoSnippetVC?.photosInRow ?? 0 }
 
 var isContentDraggable: Bool
 {
  guard itemsInRow > 0 else { return false }
  
  switch (itemsInRow, deviceType, vsc, hsc) {
   case (1...2, .phone, .regular, .compact),
        (1...2, .phone, .compact, .compact),
        (1...3, .phone, .compact, .regular),
        (1...5, .pad,   .regular, .regular): return true
   
   default: return false
  }
 }
}
