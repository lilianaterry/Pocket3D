//
//  JoystickSlider.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/21/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import UIKit

protocol JoystickSliderDelegate: class {
    func headMoved(point: PrinterCoordinate)
}

typealias PrinterCoordinate = CGPoint
typealias ViewCoordinate = CGPoint

class JoystickSlider: UIView {
    weak var delegate: JoystickSliderDelegate!

    let ui = UIExtensions()

    var sliderHeadView: UIView?
    var coordinateLabel: UILabel = UILabel()
    var panGesture = UIPanGestureRecognizer()

    static let min: CGFloat = 0
    static let max: CGFloat = 500
    
    var value: PrinterCoordinate = CGPoint(x: min, y: max) as PrinterCoordinate

    var context: NSManagedObjectContext!
    var settings: NSManagedObject!
    var request: NSFetchRequest<NSFetchRequestResult>!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // transform UI from white square to super cool joystick!
    func setup() {
        backgroundColor = UIColor.clear
        setupSliderHead()
        setupCoreData()
    }

    // get core data Settings object
    func setupCoreData() {
        // get current core data information
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            settings = result[0]
        } catch {
            print("Failed to retrieve settings from Core Data")
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let origin = CGPoint(x: bounds.origin.x + 3, y: bounds.origin.y + 3)
        let width = bounds.width - 6.0

        let delta = bounds.midX / 5.0
        for i in 0 ... 4 {
            let currDelta = delta * CGFloat(i)
            let x = origin.x + currDelta
            let y = origin.y + currDelta
            let size = width - currDelta * 2

            let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: size, height: size))

            context.setStrokeColor(ui.bodyElementColor.cgColor)
            context.setLineWidth(6.0)
            context.stroke(rect)

            if i >= 1 {
                let point = CGPoint(x: x, y: y + rect.height + 4)
                let frame = CGRect(origin: point, size: CGSize(width: 100, height: 100))
                let label = UILabel(frame: frame)
                label.font = ui.sliderSubtitleFont
                label.textColor = ui.textColor
                label.text = String(i * 50)
                label.sizeToFit()
                addSubview(label)
            }
        }
    }

    // add slider head and hook up gesture recognizer to be able to drag it
    func setupSliderHead() {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        sliderHeadView = UIView(frame: frame)

        // make circle shape
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: frame, cornerRadius: 15).cgPath
        circle.fillColor = ui.titleColor.cgColor
        circle.shadowColor = ui.headerShadowColor.cgColor
        circle.shadowOffset = CGSize(width: 2, height: 2)
        circle.shadowRadius = 5
        circle.shadowOpacity = 0.3
        sliderHeadView?.layer.addSublayer(circle)

        // add gesture recognizer to view so we can move the head around
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(JoystickSlider.dragHead))
        sliderHeadView?.addGestureRecognizer(panGesture)
        sliderHeadView?.isUserInteractionEnabled = true

        // add coordinate label
        coordinateLabel = UILabel(frame: CGRect(origin: sliderHeadView!.bounds.origin, size: sliderHeadView!.bounds.size))
        coordinateLabel.layer.position = CGPoint(x: sliderHeadView!.center.x, y: sliderHeadView!.center.y + 35)
        coordinateLabel.text = "(\(Int(sliderHeadView!.center.x.rounded())), \(Int(sliderHeadView!.center.y.rounded())))"
        coordinateLabel.textColor = ui.titleColor
        coordinateLabel.font = ui.sliderTitleFont
        coordinateLabel.sizeToFit()
        addSubview(coordinateLabel)

        // add to top-level view
        addSubview(sliderHeadView!)
        sliderHeadView?.layer.zPosition = layer.zPosition + 1
        coordinateLabel.layer.zPosition = layer.zPosition + 2
    }

    // selector to move slider head when Pan Gesture is detected
    @objc func dragHead(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)

        moveHead(location: location)
    }

    // move CALayer to desired location
    func moveHead(location: CGPoint, notify: Bool = true) {
        // keep it in the coordinate space
        var x = location.x >= 0 ? location.x : 0
        var y = location.y >= 0 ? location.y : 0
        x = x <= bounds.width ? x : bounds.width
        y = y <= bounds.height ? y : bounds.height

        let point = CGPoint(x: x, y: y) as ViewCoordinate

        sliderHeadView!.center = point
        coordinateLabel.center = CGPoint(x: point.x, y: point.y + 35)

        let relativeCoord = convertCoordinate(coord: point)
        self.value = relativeCoord
        coordinateLabel.text = "(\(Int(relativeCoord.x.rounded())), \(Int(relativeCoord.y.rounded())))"
        coordinateLabel.sizeToFit()

        if notify, let d = self.delegate {
            d.headMoved(point: relativeCoord)
        }
    }
    
    func invertCoordinate(coord: PrinterCoordinate) -> ViewCoordinate {
        var inverted = false
        if let setting = settings {
            inverted = (setting.value(forKey: "posCoord") as! Int == 1)
        }
        
        var px = coord.x / JoystickSlider.max
        var py = coord.y / JoystickSlider.max
        if (inverted) {
            swap(&px, &py)
        }
        
        let x = px * bounds.width
        let y = (1 - py) * bounds.height
        return CGPoint(x: x, y:y)
    }

    func convertCoordinate(coord: ViewCoordinate) -> PrinterCoordinate {
        var inverted = false
        if let setting = settings {
            inverted = (setting.value(forKey: "posCoord") as! Int == 1)
        }

        let percentX = coord.x / bounds.width
        let percentY = coord.y / bounds.height

        let x = JoystickSlider.max * percentX
        let y = JoystickSlider.max - (JoystickSlider.max * percentY)

        if inverted {
            return CGPoint(x: y, y: x)
        } else {
            return CGPoint(x: x, y: y)
        }
    }
}
