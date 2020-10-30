//
//  Snippet Drop View Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 23/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension SnippetsViewCell
{
 
 func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool
 {
  return true
 }//func dropInteraction(_ interaction: ...
 
 
 func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem,
                        willAnimateDropWith animator: UIDragAnimating)
 {
  animator.addAnimations
  {
   self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
   self.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
  }
  
 
 }//func dropInteraction(_ interaction: ...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession)
 {
  UIView.animate(withDuration: 0.25, animations:
  {
    self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
    self.transform = .identity
  })
  {_ in
    self.layer.borderColor = #colorLiteral(red: 1, green: 0.9294556831, blue: 0.9573842366, alpha: 1)
    self.layer.borderWidth = 1.0
    self.touchKeySpring()
   //self.updateMergedCell()
  }
  
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession)
 {
  //print (#function)
  layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
  layer.borderWidth = 2.0
  backgroundColor = backgroundColor?.withAlphaComponent(1)
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession)
 {
  //print (#function)
  layer.borderWidth = 1.0
  layer.borderColor = #colorLiteral(red: 1, green: 0.9294556831, blue: 0.9573842366, alpha: 1)
  backgroundColor = backgroundColor?.withAlphaComponent(0.5)
 }//func dropInteraction(_ interaction:...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
 {
  print (#function)
  layer.borderWidth = 1.0
  layer.borderColor = #colorLiteral(red: 1, green: 0.9294556831, blue: 0.9573842366, alpha: 1)
  backgroundColor = backgroundColor?.withAlphaComponent(0.5)
//  AppDelegate.clearAllDraggedItems()
  //clear Global Drags Array with delayed unselection and removing drag animation from all hosted cells in drag items
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
 {
  if session.localDragSession != nil
  {
   return UIDropProposal(operation: .move)
  }
  else
  {
   return UIDropProposal(operation: .copy)
  }
 }//func dropInteraction(_ interaction:...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
 {
  print (#function)
  
  if session.localDragSession != nil
  {
 
  }
  else
  {
   
  }
 }//func dropInteraction(_ interaction:...
 
}
