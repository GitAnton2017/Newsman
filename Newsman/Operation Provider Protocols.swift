//
//  Operation Provider Protocols.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

protocol CachedImageDataProvider
{
 var cachedImageID: UUID?             {get}
}

protocol SavedImageDataProvider
{
 var savedImageURL: URL?              {get}
 var imageSnippetType: SnippetType?   {get}
}

protocol VideoPreviewDataProvider
{
 var videoURL: URL?                   {get}
 var imageSnippetType: SnippetType?   {get}
}

protocol ResizeImageDataProvider
{
 var imageToResize: UIImage?          {get}
}

protocol ThumbnailImageDataProvider
{
 var thumbnailImage: UIImage?         {get}
}

protocol ImageSetDataProvider
{
 var finalImage: UIImage?             {get}
}


