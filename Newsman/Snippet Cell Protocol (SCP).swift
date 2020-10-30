//
//  PhotoSnippetCellProtocol.swift
//  Newsman
//
//  Created by Anton2016 on 19.07.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//


import UIKit
import class RxSwift.DisposeBag
import class Combine.AnyCancellable
import struct Combine.AnyPublisher

protocol PhotoSnippetCellProtocol: DragWaggleAnimatable where Self: UICollectionViewCell
{
 
 var photoSnippetVC: PhotoSnippetViewController?        { get   set }
 var photoSnippet: PhotoSnippet?                        { get   set }
 
 var isPhotoItemSelected: Bool                          { get set }
 
 var hostedItem: PhotoItemProtocol?                     { get set }
 //the generic model item (folder or photo) that will be displayed by the conformer...
 
 var mainView: UIView!                                  { get }
 
 var hostedView: UIView                                 { get }
 
 var hostedAccessoryView: UIView?                       { get }
 
 var hostedViewSelectedAlpha: CGFloat                   { get }
 
 func cleanup()
 
 func cancelImageOperations()
 
 func drawFlagMarker (flagColor: UIColor?)
 func clearFlagMarker()
 func unsetFlagMarker()

 
 func updateImage(_ animated: Bool)
 
 func refreshFlagMarker()
 
 var disposeBag: DisposeBag                             { get }
 
 var cancellables: Set<AnyCancellable>                  { get set }
 
 var arrowMenuView:    PointedMenuView?                 { get set }
 
 func showArrowMenu(animated: Bool)
 
 var arrowMenuSearchTag: UIAlertController?             { get set }
 
}

extension PhotoSnippetCellProtocol
{
 func configueInterfaceRotationSubscription()
 {
  guard let mainView = mainView as? PhotoSnippetCellMainView else { return }
  photoSnippetVC?.$interfaceWillRotate.dropFirst().map{!$0}
   .assign(to: \.animated, on: mainView.priorityFlagMarker)
   .store(in: &cancellables)

 }
}

extension PhotoSnippetCellProtocol where Self: UICollectionViewCell
{
 
 
 var waggleView: UIView { mainView }
 
 var cornerRadius: CGFloat
 {
  get { mainView.layer.cornerRadius            }
  set { mainView.layer.cornerRadius = newValue }
 }
 
 
 func refreshSpring(completion: ((Bool) -> Void)? = nil)
 {
  contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
  
  UIView.animate(withDuration: 0.25, delay: 0,
                 usingSpringWithDamping: 0.5,
                 initialSpringVelocity: 10,
                 options: .curveEaseInOut,
                 animations: { [weak self] in self?.contentView.transform = .identity },
                 completion: completion)
 }
 
 func touchSpring(completion: (() -> Void)? = nil)
 {
  
  //print (#function, self.description)
  DispatchQueue.main.async { [ weak self ] in
   guard let self = self else { return }
   let animateDown = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 0.95)
   {
    self.mainView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
   }
   
   let animateUp = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 0.95)
   {
    self.mainView.transform = .identity
    self.hostedView.alpha = self.isPhotoItemSelected ? self.hostedViewSelectedAlpha : 1
   }
   
   animateUp  .addCompletion {_ in completion?()}
   animateDown.addCompletion {_ in animateUp.startAnimation()}
   animateDown.startAnimation()
  }
 }
 
 
 func clearFlag ()
 {
  if let prevFlagLayer = contentView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   prevFlagLayer.removeFromSuperlayer()
  }
  
 }
 
 func setHighlighted(_ state: Bool )
 {
  guard arrowMenuView == nil else { return }
  alpha = state ? 0.75 : 1.0
  mainView.layer.borderWidth = state ? 2.0 : 1.0
 }
 
 func imageRoundClip(cornerRadius: CGFloat)
 {
  mainView.layer.cornerRadius = cornerRadius
  mainView.layer.borderWidth = 1.0
  mainView.layer.borderColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1).cgColor
  mainView.layer.masksToBounds = true
 }
 

 func drawFlag (flagColor: UIColor)
 {
  let flagLayer = FlagLayer()
  flagLayer.fillColor = flagColor
  flagLayer.name = "FlagLayer"
  
  let imageSize = bounds.width
  flagLayer.frame = CGRect(x:imageSize * 0.8, y: 0, width: imageSize * 0.2, height: imageSize * 0.25)
  flagLayer.contentsScale = UIScreen.main.scale
  
  if let prevFlagLayer = contentView.layer.sublayers?.first(where: {$0.name == "FlagLayer"})
  {
   contentView.layer.replaceSublayer(prevFlagLayer, with: flagLayer)
  }
  else
  {
   contentView.layer.addSublayer(flagLayer)
  }
  
  flagLayer.setNeedsDisplay()
 }
 
 

 
}

