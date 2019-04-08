//
//  UIExtensions.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/3/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class UIExtensions {
    // dark color pallete
    var headerBackgroundColor: UIColor
    var headerTextColor: UIColor
    let headerShadowColor = UIColor.init(hex: 0x000000)

    var backgroundColor: UIColor
    var titleColor: UIColor
    var textColor: UIColor
    var bodyElementColor: UIColor
    
    // text
    let headerTitleFont = UIFont(name: "SFProDisplay-Bold", size: 34.0)
    let textFieldTitleFont = UIFont(name: "SFProDisplay-Medium", size: 22.0)
    let buttonTitleFont = UIFont(name: "SFProDisplay-Bold", size: 24.0)
    let sliderTitleFont = UIFont(name: "SFProDisplay-Semibold", size: 18.0)
    let sliderSubtitleFont = UIFont(name: "SFProDisplay-Semibold", size: 14.0)
    
    // files text page
    var filesExpandedColor: UIColor
    let fileExpandedFont = UIFont(name: "SFProDisplay-Semibold", size: 12.0)

    let titleSize = 24.0 as CGFloat
    let textSize = 18.0 as CGFloat
    
    init() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            headerBackgroundColor = UIColor.init(hex: 0x1C2937)
            headerTextColor = UIColor.init(hex: 0x1B88CB)
            
            backgroundColor = UIColor.init(hex: 0x15202B)
            titleColor = UIColor.init(hex: 0xFFFFFF)
            textColor = UIColor.init(hex: 0x8899A6)
            bodyElementColor = UIColor.init(hex: 0x8899A6)
            
            filesExpandedColor = UIColor.init(hex: 0x8899A6)
        } else {
            headerBackgroundColor = UIColor.init(hex: 0xE2E2E2)
            headerTextColor = UIColor.init(hex: 0x000000)
            
            backgroundColor = UIColor.init(hex: 0xFFFFFF)
            titleColor = UIColor.init(hex: 0x000000)
            textColor = UIColor.init(hex: 0x000000)
            bodyElementColor = UIColor.init(hex: 0xB2B2B2)
            
            filesExpandedColor = UIColor.init(hex: 0x000000)
        }
    }
}

// create UI color from hex code
extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

