//
//  TemperatureSlider.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

@IBDesignable
class HorizontalCustomSlider: UISlider {
    let ui = UIExtensions()

    let minLabel: UILabel = UILabel()
    let maxLabel: UILabel = UILabel()

    var thumbTextLabel: UILabel = UILabel()

    @IBInspectable var trackHeight: CGFloat = 8

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

        // initialize labels
        thumbTextLabel.frame = thumbFrame
        thumbTextLabel.text = String(Int(value.rounded()))
        thumbTextLabel.sizeToFit()
        minLabel.text = String(Int(minimumValue))
        minLabel.sizeToFit()
        maxLabel.text = String(Int(maximumValue))
        maxLabel.sizeToFit()

        // slider head label position
        thumbTextLabel.layer.position = CGPoint(x: thumbCenterX, y: thumbCenterY - 75)
        minLabel.layer.position = CGPoint(x: bounds.origin.x, y: bounds.origin.y + 25)
        maxLabel.layer.position = CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + 25)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        addSubview(minLabel)
        addSubview(maxLabel)

        setup()

        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }

    // customize text, color, and appearance of the slider
    func setup() {
        // track color
        minimumTrackTintColor = ui.textColor
        maximumTrackTintColor = ui.textColor

        // make end of track square instead of round
        let endImage = getImageWithColor(color: ui.textColor, size: frame.size)
        setMinimumTrackImage(endImage, for: .normal)
        setMaximumTrackImage(endImage, for: .normal)

        // font of labels
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.font = ui.sliderTitleFont
        thumbTextLabel.textColor = ui.titleColor
        minLabel.font = ui.sliderTitleFont
        minLabel.textColor = ui.textColor
        maxLabel.font = ui.sliderTitleFont
        maxLabel.textColor = ui.textColor
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

@IBDesignable
class VerticalCustomSlider: UISlider {
    let ui = UIExtensions()

    let min = 0
    let max = 500
    let minLabel: UILabel = UILabel()
    let maxLabel: UILabel = UILabel()

    var thumbTextLabel: UILabel = UILabel()

    @IBInspectable var trackHeight: CGFloat = 8

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

        // initialize labels
        thumbTextLabel.frame = thumbFrame
        thumbTextLabel.text = String(Int(value.rounded()))
        thumbTextLabel.sizeToFit()
        minLabel.text = String(min)
        minLabel.sizeToFit()
        maxLabel.text = String(max)
        maxLabel.sizeToFit()

        // slider head label position
        thumbTextLabel.layer.position = CGPoint(x: thumbCenterX, y: thumbCenterY - 65)
        minLabel.layer.position = CGPoint(x: bounds.origin.x, y: bounds.origin.y + 45)
        maxLabel.layer.position = CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y + 45)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        addSubview(minLabel)
        addSubview(maxLabel)

        setup()

        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }

    // customize text, color, and appearance of the slider
    func setup() {
        // track color
        minimumTrackTintColor = ui.textColor
        maximumTrackTintColor = ui.textColor

        // make end of track square instead of round
        let endImage = getImageWithColor(color: ui.textColor, size: frame.size)
        setMinimumTrackImage(endImage, for: .normal)
        setMaximumTrackImage(endImage, for: .normal)

        // font of labels
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.font = ui.sliderTitleFont
        thumbTextLabel.textColor = ui.titleColor
        minLabel.font = ui.sliderTitleFont
        minLabel.textColor = ui.textColor
        maxLabel.font = ui.sliderTitleFont
        maxLabel.textColor = ui.textColor
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

    // when the slider moves, move the label with it
    func updateLabelPosition() {
        thumbTextLabel.center = CGPoint(x: thumbCenterX, y: thumbCenterY)
    }
}
