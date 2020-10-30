//
//  Photo Item Cell Drop Providable.swift
//  Newsman
//
//  Created by Anton2016 on 03.07.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//


protocol PhotoItemCellDropProvidable
{
 var snippet: BaseSnippet?                  { get }
 var ownerCell: PhotoSnippetCellProtocol?   { get }
}
