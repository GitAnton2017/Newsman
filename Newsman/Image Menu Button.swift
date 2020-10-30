//
//  Menu Buttons.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class ImageMenuButton: MenuItemButton
{
 convenience init(named: String,
                  imageTintColor: UIColor = .black,
                  handler: @escaping () -> ())
 {
  self.init(image: UIImage(named: named),
            imageTintColor: imageTintColor,
            handler: handler)
 }
 
 convenience init(systemName: String,
                  symbolConfiguration: UIImage.SymbolConfiguration = .unspecified,
                  imageTintColor: UIColor = .black,
                  mirrowed: Bool = false,
                  handler: @escaping () -> ())
 {
  let image = mirrowed ? UIImage(systemName: systemName)?.withHorizontallyFlippedOrientation() : UIImage(systemName: systemName)
  
  self.init(image: image?.applyingSymbolConfiguration(symbolConfiguration),
            imageTintColor: imageTintColor,
            handler: handler)
 }
 
 init(frame: CGRect = .zero,
      image: UIImage?,
      imageTintColor: UIColor = .black,
      handler: @escaping () -> ())
 {
  super.init(frame: frame, handler: handler)
  //setImage(image, for: .normal)
  let buttonImage = UIImageView(image: image)
  

  buttonImage.translatesAutoresizingMaskIntoConstraints = false
  addSubview(buttonImage)
  buttonImage.contentMode = .scaleAspectFit
  
  NSLayoutConstraint.activate([
    buttonImage.bottomAnchor.constraint   (equalTo: bottomAnchor,    constant: 0),
    buttonImage.topAnchor.constraint      (equalTo: topAnchor,       constant: 0),
    buttonImage.leadingAnchor.constraint  (equalTo: leadingAnchor,   constant: 0),
    buttonImage.trailingAnchor.constraint (equalTo: trailingAnchor,  constant: 0)
   ])
  
  
//  contentVerticalAlignment = .fill
//  contentHorizontalAlignment = .fill
//  imageEdgeInsets = .init(top: 3, left: 0, bottom: 3, right: 0)
  tintColor = imageTintColor
  backgroundColor = .clear
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
}

