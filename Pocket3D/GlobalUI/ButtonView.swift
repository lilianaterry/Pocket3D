//
//  ButtonView.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/3/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonView: UIButton {
    
    let ui = UIExtensions()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = ui.headerTextColor
        self.layer.cornerRadius = 10
    }
}
