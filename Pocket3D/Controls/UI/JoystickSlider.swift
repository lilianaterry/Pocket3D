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
    var coordinateLabel: UILabel = UILabel()
    var panGesture = UIPanGestureRecognizer()
    
    let min: CGFloat = 0
    let max: CGFloat = 500
    var bottomLeftLabel: UILabel = UILabel()
    var bottomRightLabel: UILabel = UILabel()
    var topLeftLabel: UILabel = UILabel()
    var topRightLabel: UILabel = UILabel()
    
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
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let origin = CGPoint(x: self.bounds.origin.x + 3, y: self.bounds.origin.y + 3)
        let width = self.bounds.width - 6.0
        
        let delta = self.bounds.midX / 5.0
        for i in 0...4 {
            let currDelta = delta * CGFloat(i)
            let x = origin.x + currDelta
            let y = origin.y + currDelta
            let size = width - currDelta * 2
            
            let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: size, height: size))
            
            context.setStrokeColor(ui.textColor.cgColor)
            context.setLineWidth(6.0)
            context.stroke(rect)
        }
    }
    
    // add slider head and hook up gesture recognizer to be able to drag it
    func setupSliderHead() {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        sliderHeadView = UIView(frame: frame)
        
        // make circle shape
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: frame, cornerRadius: 15).cgPath
        circle.fillColor = UIColor.white.cgColor
        sliderHeadView?.layer.addSublayer(circle)
        
        // add gesture recognizer to view so we can move the head around
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(JoystickSlider.dragHead))
        sliderHeadView?.addGestureRecognizer(panGesture)
        sliderHeadView?.isUserInteractionEnabled = true
        
        // add coordinate label
        coordinateLabel = UILabel(frame: CGRect(origin: sliderHeadView!.bounds.origin, size: sliderHeadView!.bounds.size))
        coordinateLabel.layer.position = CGPoint(x: sliderHeadView!.center.x, y: sliderHeadView!.center.y + 35)
        coordinateLabel.text = "(\(Int(sliderHeadView!.center.x.rounded())), \(Int((sliderHeadView!.center.y.rounded()))))"
        coordinateLabel.textColor = ui.titleColor
        coordinateLabel.font = ui.sliderTitleFont
        coordinateLabel.sizeToFit()
        self.addSubview(coordinateLabel)
        
        // add to top-level view
        self.addSubview(sliderHeadView!)
        sliderHeadView?.layer.zPosition = self.layer.zPosition + 1
        coordinateLabel.layer.zPosition = self.layer.zPosition + 2
    }
    
    // selector to move slider head when Pan Gesture is detected
    @objc func dragHead(sender: UIPanGestureRecognizer) {
        let head = sender.view!
        let location = sender.location(in: self)
        
        // keep it in the coordinate space
        var x = location.x >= 0 ? location.x : 0
        var y = location.y >= 0 ? location.y : 0
        x = x <= bounds.width ? x : bounds.width
        y = y <= bounds.height ? y : bounds.height
        
        let point = CGPoint(x: x, y: y)
        
        head.center = point
        coordinateLabel.center = CGPoint(x: point.x, y: point.y + 35)

        let relativeCoord = convertCoordinate(coordinate: point)
        coordinateLabel.text = "(\(Int(relativeCoord.x.rounded())), \(Int(relativeCoord.y.rounded())))"
        coordinateLabel.sizeToFit()
    }
    
    func convertCoordinate(coordinate: CGPoint) -> CGPoint {
        let percentX = coordinate.x / self.bounds.width
        let percentY = coordinate.y / self.bounds.height
        
        let x = max * percentX
        let y = max - (max * percentY)
        
        return CGPoint(x: x, y: y)
    }
}
