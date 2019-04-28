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
