//
//  MenuCell.swift
//  Alamofire
//
//  Created by Liliana Terry on 3/23/19.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    let ui = UIExtensions()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = ui.sliderTitleFont
        l.textColor = ui.textColor
        l.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
        return l
    }()
    
    lazy var border: CALayer = {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: frame.height - 4, width: frame.width, height: 4)
        bottomLine.backgroundColor = UIColor.clear.cgColor
        return bottomLine
    }()
    
    // change color when tab is downclicked
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? ui.headerTextColor : ui.textColor
        }
    }
    
    // change color when tab is actually selected
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                label.textColor = ui.headerTextColor
                border.backgroundColor = ui.headerTextColor.cgColor
            } else {
                label.textColor = ui.textColor
                border.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // setup UILabel and text coloring
    func setup() {
        self.backgroundColor = ui.headerBackgroundColor
        
        addSubview(label)
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.layer.addSublayer(border)
    }
}
