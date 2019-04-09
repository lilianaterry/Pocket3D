//
//  CustomTabBar.swift
//  Pocket3D
//
//  Created by Liliana Terry on 4/7/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBarController {

    var ui = UIExtensions()
    
    @IBOutlet var navBackground: UITabBar!
    
    override func viewDidLoad() {
        navBackground.isTranslucent = false
        navBackground.backgroundColor = ui.headerBackgroundColor
        navBackground.barTintColor = ui.headerBackgroundColor
        
        navBackground.layer.shadowColor = ui.headerShadowColor.cgColor
        navBackground.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        navBackground.layer.shadowRadius = 5
        navBackground.layer.shadowOpacity = 0.2
        navBackground.layer.masksToBounds = false
    }
}
