//
//  GcodeGridCell.swift
//  Pocket3D
//
//  Created by Chris Day on 4/5/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Foundation
import UIKit

class GcodeGridCell: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(text: String) {
        self.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightText
        label.textAlignment = .center
        label.contentMode = .center
        label.text = text
        self.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        self.bounds = self.bounds.insetBy(dx: 3, dy: 3)
    }
}
