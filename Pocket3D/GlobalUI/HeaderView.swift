//
//  HeaderView.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/4/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class HeaderView: UIView {

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
        self.backgroundColor = ui.headerBackgroundColor
        let title = UILabel(frame: CGRect(x: 50, y: self.bounds.height - 50, width: self.bounds.width, height: self.bounds.height))
        self.layer.addSublayer(title.layer)
    }

}
