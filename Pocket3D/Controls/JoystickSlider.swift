//
//  JoystickSlider.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/21/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class JoystickSlider: UIView {
    
    let ui = UIExtensions()
    
    var sliderHeadView: UIView?
    var currentlySliding: Bool = false
    var panGesture = UIPanGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // transform UI from white square to super cool joystick!
    func setup() {
        self.backgroundColor = UIColor.clear
        setupSliderHead()
    }
    
    // add slider head and hook up gesture recognizer to be able to drag it
    func setupSliderHead() {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        sliderHeadView = UIView(frame: frame)
        
        // make circle shape
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: frame, cornerRadius: 15).cgPath
        circle.fillColor = UIColor.black.cgColor
        sliderHeadView?.layer.addSublayer(circle)
        
        // add gesture recognizer to view so we can move the head around
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(JoystickSlider.dragHead))
        sliderHeadView?.addGestureRecognizer(panGesture)
        sliderHeadView?.isUserInteractionEnabled = true
        
        // add to top-level view
        self.addSubview(sliderHeadView!)
        sliderHeadView?.layer.zPosition = self.layer.zPosition + 1
    }
    
    // selector to move slider head when Pan Gesture is detected
    @objc func dragHead(sender: UIPanGestureRecognizer) {
        let head = sender.view
        head?.center = sender.location(in: self)
    }
}
