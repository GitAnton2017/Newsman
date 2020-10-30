//
//  Menu Item Button.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class MenuItemButton: UIButton
{
 deinit { print ("MenuItemButton is DESTROYED!") }
 
 
 var handler: () -> ()

 init(frame: CGRect = .zero, handler: @escaping () -> ())
 {
  self.handler = handler
  super.init(frame: frame)
  
  //addTarget(self, action: #selector(tap), for: .touchUpInside)
 }
 
 func touchSpring(completion: (() -> Void)? = nil)
 {
  let animateDown = UIViewPropertyAnimator(duration: 0.125, dampingRatio: 0.75)
  {
   self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
   self.alpha = 0.5
  }
  
  let animateUp = UIViewPropertyAnimator(duration: 0.125, dampingRatio: 0.75)
  {
   self.transform = .identity
   self.alpha = 1
  }
  
  animateUp  .addCompletion {_ in completion?()}
  animateDown.addCompletion {_ in animateUp.startAnimation()}
  animateDown.startAnimation()
 }
 
 
 @objc func tap()
 {
  touchSpring { [weak self] in self?.handler() }
 }
 
 required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
