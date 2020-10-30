//
//  Menu Base View CV.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class MenuButtonCell: UICollectionViewCell
{
 static let reuseID = "MenuButtonCell"
 
 override func awakeFromNib()
 {
  super.awakeFromNib()
 }
 
 override func prepareForReuse()
 {
  super.prepareForReuse()
 }
 
}//class MenuButtonCell...



extension MenuBaseView: UICollectionViewDataSource
{
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
 {
  return buttons.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 {
  let buttonCell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuButtonCell.reuseID, for: indexPath) as! MenuButtonCell
  
  let fromButton = buttonCell.contentView.subviews.first as? MenuItemButton
  let toButton = buttons[indexPath.row]
  
  toButton.translatesAutoresizingMaskIntoConstraints = false
  
  buttonCell.contentView.addSubview(toButton)
  
  buttonCell.contentView.layer.shadowOpacity = 1
  buttonCell.contentView.layer.shadowOffset = CGSize(width: -1.5, height: 1.5)
  buttonCell.contentView.layer.shadowColor = UIColor.black.cgColor
  buttonCell.contentView.layer.shadowRadius = 2
  
  NSLayoutConstraint.activate([
   toButton.bottomAnchor.constraint   (equalTo: buttonCell.contentView.bottomAnchor,    constant: buttonInset),
   toButton.topAnchor.constraint      (equalTo: buttonCell.contentView.topAnchor,       constant: buttonInset),
   toButton.leadingAnchor.constraint  (equalTo: buttonCell.contentView.leadingAnchor,   constant: buttonInset),
   toButton.trailingAnchor.constraint (equalTo: buttonCell.contentView.trailingAnchor,  constant: buttonInset)
  ])
  
  toButton.isHidden = true
  
  UIView.transition(with: buttonCell.contentView, duration: 0.35,
                    options: [.transitionCrossDissolve, .curveEaseInOut],
                    animations:
                    {
                     fromButton?.removeFromSuperview()
                     toButton.isHidden = false
                    },
                    completion: nil)
 
  return buttonCell
 }
}//extension MenuBaseView
 


extension MenuBaseView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
 var buttonSize: CGFloat
 {
  let w = self.bounds.width - 2 * buttonsCVInset
  let size = (w - margin * CGFloat(buttonsInRow + 1)) / CGFloat(buttonsInRow)
  return size.rounded(.towardZero)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize
 {
  CGSize(width: buttonSize, height: buttonSize)
 }
 
 func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat
 {
  let w = collectionView.bounds.width
  let wr = (w - margin * CGFloat(buttonsInRow + 1)).truncatingRemainder(dividingBy: CGFloat(buttonsInRow)) / CGFloat(buttonsInRow - 1)

  return margin + wr

 }
}//extension MenuBaseView...
