//
//  MultipleChoiceButtonView.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/22/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

@IBDesignable
class BubbleButton: UIButton {

    let ui = UIExtensions()
    
    @IBInspectable
    public var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat = 4.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        setup()
    }
    
    // circular button UI
    func setup() {
        self.layer.borderColor = ui.textColor.cgColor
        self.layer.borderWidth = 4.0
        cornerRadius = self.bounds.width / 2
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    // selects the target button by filling it in and deselecting all others
    func selectButton(toDeselect: [UIButton]) {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.isSelected = true
        
        for button in toDeselect {
            button.layer.backgroundColor = UIColor.clear.cgColor
            button.isSelected = false
        }
    }
}
