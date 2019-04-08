//
//  TextFieldView.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/3/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

@IBDesignable
open class TextFieldView: UITextField {
    
    var ui = UIExtensions()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.clearsOnBeginEditing = true
        
        setupBackground()
        setupFont()
    }
    
    func setupBackground() {
        self.backgroundColor = UIColor.clear
        
        self.borderStyle = UITextField.BorderStyle.none
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = ui.titleColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        
        border.borderWidth = width
        border.name = "border"
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func setupFont() {
        self.font = ui.textFieldTitleFont
        self.textColor = ui.titleColor
    }
    
    func updateBorder() {
        let newBorder = CALayer()
        let width = CGFloat(2.0)
        newBorder.borderColor = ui.titleColor.cgColor
        newBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        newBorder.borderWidth = width
        newBorder.name = "border"
        
        for oldLayer in self.layer.sublayers! {
            if oldLayer.name == "border" {
                self.layer.replaceSublayer(oldLayer, with: newBorder)
            }
        }
    }
}
