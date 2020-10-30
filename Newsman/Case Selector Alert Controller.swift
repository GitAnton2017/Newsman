//
//  Case Selector Alert Controller.swift
//  Newsman
//
//  Created by Anton2016 on 19/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import RxCocoa

protocol StringLocalizable
{
 var localizedString: String {get}
}

protocol AllCasesSelectorRepresentable: StringLocalizable, CaseIterable
{
 typealias ActionType  = (Self) -> Void
 
 var isCaseEnabled: Bool { get set }
 
 static func caseSelectorController(title: String,
                                    message: String,
                                    style: UIAlertController.Style,
                                    block: @escaping ActionType) -> UIAlertController
}



extension AllCasesSelectorRepresentable
{
 
 static func caseSelectorController (title: String, message: String,
                                     style: UIAlertController.Style,
                                     block: @escaping ActionType) -> UIAlertController
 {
  
  
  let selector = UIAlertController(title: title, message: message, preferredStyle: style)
  
  Self.allCases.map
   {item in
    let action = UIAlertAction(title: item.localizedString, style: .default){ _ in block(item)}
    action.isEnabled = item.isCaseEnabled
    return action
   }.forEach{selector.addAction($0)}
  
  let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)

  
  selector.addAction(cancelAction)
  
  return selector
  
 }
}

