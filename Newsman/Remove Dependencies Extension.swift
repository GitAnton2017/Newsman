//
//  Remove Dependencies Extension.swift
//  Newsman
//
//  Created by Anton2016 on 02/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension Operation //This recursive member function removes all finisshed Operation dependancies.
{
 func removeAllDependencies()
 {
  guard isFinished || isCancelled else { return }
  dependencies.forEach
  {
    $0.removeAllDependencies()
    removeDependency($0)
  }
 }
}
