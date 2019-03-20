//
//  TemperatureSlider.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class TemperatureSlider: UISlider {
    let ui = UIExtensions()
    
    @IBInspectable var trackHeight: CGFloat = 8
    var thumbTextLabel: UILabel = UILabel()
    
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
    
    var thumbCenterY: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midY
    }
    
    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbTextLabel.frame = thumbFrame
        thumbTextLabel.text = String(Int(value.rounded()))
        thumbTextLabel.sizeToFit()
        
        // thumb label position
        let y = thumbCenterY - 55
        thumbTextLabel.layer.position = CGPoint(x: thumbCenterX, y: y)
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        
        setup()
    }
    
    func setup() {
        self.minimumTrackTintColor = ui.textColor
        self.maximumTrackTintColor = ui.textColor
        
        let endImage = getImageWithColor(color: ui.textColor, size: self.frame.size)
        self.setMinimumTrackImage(endImage, for: .normal)
        self.setMaximumTrackImage(endImage, for: .normal)
        
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.font = ui.sliderTitleFont
        thumbTextLabel.textColor = ui.titleColor
    }
    
    // customize width of slider tacking line
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let size = CGSize(width: bounds.width, height: trackHeight)
        return CGRect(origin: bounds.origin, size: size)
    }
    
    // make a little square to un-round the edges of the slider
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
