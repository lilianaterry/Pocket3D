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
    let headerBackgroundColor = UIColor.init(hex: 0x1C2937)
    let headerTextColor = UIColor.init(hex: 0x1B88CB)
    let headerShadowColor = UIColor.init(hex: 0x000000)
    
    let backgroundColor = UIColor.init(hex: 0x15202B)
    let titleColor = UIColor.init(hex: 0xFFFFFF)
    let textColor = UIColor.init(hex: 0x8899A6)
    
    // text
    let headerTitleFont = UIFont(name: "SFProDisplay-Bold", size: 34.0)
    let textFieldTitleFont = UIFont(name: "SFProDisplay-Medium", size: 22.0)
    let buttonTitleFont = UIFont(name: "SFProDisplay-Bold", size: 24.0)
    let sliderTitleFont = UIFont(name: "SFProDisplay-Semibold", size: 18.0)
    
    let titleSize = 24.0 as CGFloat
    let textSize = 18.0 as CGFloat
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

