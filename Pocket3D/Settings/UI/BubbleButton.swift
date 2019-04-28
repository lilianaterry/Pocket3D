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
            layer.cornerRadius = cornerRadius
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

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    convenience init(frame: CGRect, image _: UIImage) {
        self.init(frame: frame)
        setup()
    }

    // circular button UI
    func setup() {
        layer.borderColor = ui.bodyElementColor.cgColor
        layer.borderWidth = 4.0
        cornerRadius = bounds.width / 2
        layer.backgroundColor = UIColor.clear.cgColor
    }

    // selects the target button by filling it in and deselecting all others
    func selectButton() {
        layer.backgroundColor = ui.titleColor.cgColor
        isSelected = true
    }
    
    func deselectButton() {
        layer.backgroundColor = UIColor.clear.cgColor
        isSelected = false
    }
}
