//
//  MenuButton.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/22/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class MenuButton: UITabBarItem {
    
    var ui = UIExtensions()
    
    override func awakeFromNib() {        
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ui.titleColor], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font: ui.menuFont as Any], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ui.headerTextColor], for: .selected)
    }
}

func getUnderline(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
        let rect = CGRect(x:0, y: 0, width: size.width, height: size.height)
        let rectLine = CGRect(x:0, y: 0, width: lineSize.width,height: lineSize.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        color.setFill()
        UIRectFill(rectLine)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
}
