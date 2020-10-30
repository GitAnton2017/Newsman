//
//  Snippet Cell Spring Interaction.swift
//  Newsman
//
//  Created by Anton2016 on 23/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell: UISpringLoadedInteractionEffect, UISpringLoadedInteractionBehavior
{

 func editHostedSnippet()
 {
  guard let snippet = self.snippet else { return }
  guard let svc = (self.tableView?.dataSource as? SnippetsViewDataSource)?.snippetsVC else { return }
  svc.editSelectedSnippet(selectedSnippet: snippet)
 }
 
 func interaction(_ interaction: UISpringLoadedInteraction,
                    didChangeWith context: UISpringLoadedInteractionContext)
 {
  switch context.state
  {

   case .possible:   self.alpha = 0.75
   case .activating: self.alpha = 0.25
   case .activated:  touchKeySpring { self.alpha = 0 }
   case .inactive:   self.alpha = 1
   @unknown default: break
  }
 }
 
 func shouldAllow(_ interaction: UISpringLoadedInteraction,
                    with context: UISpringLoadedInteractionContext) -> Bool
 {
  if context.targetItem == nil
  {
   context.targetItem = DispatchTime.now()
   return false
  }
  
  let start = context.targetItem as! DispatchTime
  let now = DispatchTime.now()
  return now > start + .seconds(2)
 }
 
 func interactionDidFinish(_ interaction: UISpringLoadedInteraction)
 {
  touchKeySpring { self.alpha = 1 }
 }
 
 func configueSpringInteraction()
 {

  let spring = UISpringLoadedInteraction(interactionBehavior: self, interactionEffect: self)
  {interaction, context in
   
   self.editHostedSnippet()
 
  }
  
  dropView.addInteraction(spring)
 }
}

