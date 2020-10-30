//
//  Snippet Cell CA Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 27/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell: CAAnimationDelegate
{
 func animationDidStop(_ anim: CAAnimation, finished flag: Bool )
 {
  guard let snippet = hostedSnippet  else { return }
  guard flag else { return }
  
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + transDuration * 0.75)
  {[weak self] in
   guard let cell = self else {return}
   guard cell.animationID == anim.value(forKey: "animationID") as? UUID else { return }
   guard cell.hostedSnippet?.objectID == snippet.objectID else { return }
   cell.animate?(0.25 * cell.transDuration)
  }
 }
}
