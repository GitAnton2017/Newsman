//
//  App Appearance Setup.swift
//  Newsman
//
//  Created by Anton2016 on 10.06.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit

extension UIColor
{
 static let newsmanRed = UIColor(named: "Newsman.red")!
}

class NewsmanNavigationController: UINavigationController
{
 override var prefersStatusBarHidden: Bool { false }
 
 override var supportedInterfaceOrientations: UIInterfaceOrientationMask
 {
  switch topViewController
  {
   case is MainViewController: return .portrait
   case is SnippetsViewController: return .portrait
   default: return .all
  }
  
 }
}

extension AppDelegate
{
 final func configueAppAppearance()
 {
  
  UIButton.appearance(for: UITraitCollection(verticalSizeClass: .regular),
                      whenContainedInInstancesOf: [UIStepper.self])
                       .backgroundColor = UIColor.newsmanRed.withAlphaComponent(0.5)
  
  UIButton.appearance(for: UITraitCollection(verticalSizeClass: .compact),
                      whenContainedInInstancesOf: [UIStepper.self])
                      .backgroundColor = UIColor.newsmanRed.withAlphaComponent(0.85)
  
  UIStepper.appearance(for: UITraitCollection(verticalSizeClass: .regular)).tintColor = .white
  UIStepper.appearance(for: UITraitCollection(verticalSizeClass: .compact)).tintColor = .lightGray
  
  
  let configue = UIImage.SymbolConfiguration(scale: .large)
                .applying(UIImage.SymbolConfiguration(weight: .semibold))
 
  
  let plusImageNorm = UIImage(systemName: "plus.circle", withConfiguration: configue)
  UIStepper.appearance().setIncrementImage(plusImageNorm, for: .normal)
  
  let minusImageNorm = UIImage(systemName: "minus.circle", withConfiguration: configue)
  UIStepper.appearance().setDecrementImage(minusImageNorm, for: .normal)
  
  let plusImageHigh = UIImage(systemName: "plus.circle.fill", withConfiguration: configue)
  UIStepper.appearance().setIncrementImage(plusImageHigh, for: .highlighted)
 
  let minusImageHigh = UIImage(systemName: "minus.circle.fill", withConfiguration: configue)
  UIStepper.appearance().setDecrementImage(minusImageHigh, for: .highlighted)
 

 }
 
}
