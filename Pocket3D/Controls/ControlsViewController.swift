//
//  ControlsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import SwiftyJSON
import UIKit
import OctoKit

class ControlsViewController: UIViewController, Observer, JoystickSliderDelegate, GridViewDelegate {
    let ui = UIExtensions()
    
    let usrDefault = UserDefaults.standard
    
    @IBOutlet var positionText: UILabel!
    @IBOutlet var temperatureText: UILabel!
    @IBOutlet var topLeftText: UILabel!
    @IBOutlet var bottomLeftText: UILabel!
    @IBOutlet var bottomRightText: UILabel!
    @IBOutlet var zText: UILabel!
    
    @IBOutlet var xyPositionSlider: JoystickSlider!
    @IBOutlet var zPositionSlider: HorizontalCustomSlider!
    @IBOutlet var extruderSlider: UISlider!
    @IBOutlet var heatbedSlider: UISlider!
    @IBOutlet var posLabelTR: UILabel!
    @IBOutlet var extruderTempLabel: UILabel!
    @IBOutlet var bedTempLabel: UILabel!
    @IBOutlet var gcodeGrid: GridView!
    
    var didSetInitialValues: Bool!
    
    var gcodeCommands: [(String, [String])] = []
    
    var tempUpdateCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Push.instance.observe(who: self as Observer, topic: Push.current)
        
        print("In controls, adding listener to notification center")
        
        didSetInitialValues = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(settingsChanged),
                                               name: NSNotification.Name(rawValue: "settings_changed"), object: nil)
        
        xyPositionSlider.delegate = self
        zPositionSlider.isContinuous = false
        extruderSlider.isContinuous = false
        heatbedSlider.isContinuous = false
        zPositionSlider.addTarget(self, action: #selector(zHeightChanged), for: .valueChanged)
        extruderSlider.addTarget(self, action: #selector(eHeatChanged), for: .valueChanged)
        heatbedSlider.addTarget(self, action: #selector(bedHeatChanged), for: .valueChanged)
        
        gcodeGrid.delegate = self
        settingsChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        didSetInitialValues = false
    }
    
    // Save button was selected on Settings Page and Sliders/Buttons need to be updated
    @objc func settingsChanged() {
        // TODO, actually change coordinate field
        posLabelTR.text = usrDefault.integer(forKey: "posCoord") == 0 ? "xy" : "yx"
        extruderSlider.minimumValue = usrDefault.float(forKey: "extruderMin")
        extruderSlider.maximumValue = usrDefault.float(forKey: "extruderMax")
        heatbedSlider.minimumValue = usrDefault.float(forKey: "bedMin")
        heatbedSlider.maximumValue = usrDefault.float(forKey: "bedMax")
        
        // merge gcode arrays back together
        updateGcodeCells()
    }
    
    // Get GCode button information from UserDefaults
    func updateGcodeCells() {
        // clear out old information
        gcodeCommands = []
        gcodeGrid.clearCells()
        
        // merge gcode arrays back together
        let commandNames = usrDefault.object(forKey: "gcodeNames") as! [String]
        let commands = usrDefault.object(forKey: "gcodeCommands") as! [[String]]
        
        gcodeCommands = Array(zip(commandNames, commands))
        
        for command in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: command.0))
        }
    }
    
    func notify(message: Notification) {
        let json = message.object! as! JSON
        
        // update temperature labels with live temperature not intended
        if json["temps"].array?.count != 0 {
            extruderTempLabel.text = "Extruder: \(json["temps"][0]["tool0"]["actual"].floatValue)°"
            bedTempLabel.text = "Heat Bed: \(json["temps"][0]["bed"]["actual"].floatValue)°"
            
            // only update the slider head when the view appears to avoid user confusion
            if (!extruderSlider.isTracking && tempUpdateCounter <= 0) {
                extruderSlider.value = json["temps"][0]["tool0"]["target"].floatValue
                heatbedSlider.value = json["temps"][0]["bed"]["target"].floatValue
            }
            tempUpdateCounter -= 1;
        }
        
        // update z position
        if let z = json["currentZ"].float {
            zPositionSlider.value = z
        }
        
        // try to set the xy control position
        for l in (json["logs"].arrayObject! as! [String]).filter({ $0.starts(with: "Send:") }) {
            var split: [Substring]
            if let star = l.lastIndex(of: "*") {
                split = l[l.startIndex...l.index(before: star)].split(separator: " ")
            } else {
                split = l.split(separator: " ")
            }
            if split.count < 3 {
                continue
            } else if split[2] == "G28" {
                xyPositionSlider.moveHead(location: xyPositionSlider.invertCoordinate(coord: CGPoint(x: 0, y: 0)))
                break
            } else if split[2] == "G0" || split[2] == "G1" {
                var x = xyPositionSlider.value.x
                var y = xyPositionSlider.value.y
                if let tx = split.first(where: { $0.starts(with: "X") }) {
                    x = CGFloat(Float(String(tx.dropFirst()))!)
                }
                if let ty = split.first(where: { $0.starts(with: "Y") }) {
                    y = CGFloat(Float(String(ty.dropFirst()))!)
                }
                xyPositionSlider.moveHead(location: xyPositionSlider.invertCoordinate(coord: CGPoint(x: x, y: y) as PrinterCoordinate), notify: false)
                break
            }
        }
        
        // grey out controls if print is in progress
        if json["state"].array?.count != 0 {
            let printInProgress = json["state"]["flags"]["printing"].boolValue
            var alpha: CGFloat = 0
            if printInProgress && zPositionSlider.isEnabled {
                zPositionSlider.isEnabled = false
                xyPositionSlider.isEnabled = false
                alpha = 0.25 as CGFloat
                positionText.text = "Print in progress."
                positionText.sizeToFit()
            } else if !printInProgress && !zPositionSlider.isEnabled {
                zPositionSlider.isEnabled = true
                xyPositionSlider.isEnabled = true
                alpha = 1.0 as CGFloat
                positionText.text = "Position"
                positionText.sizeToFit()
            }
            
            topLeftText.alpha = alpha
            bottomLeftText.alpha = alpha
            bottomRightText.alpha = alpha
        }
    }
    
    // make sure everything is colored beautifully
    func setup() {
        let inverted = (usrDefault.value(forKey: "posCoord") as! Int) == 1
        if inverted {
            posLabelTR.text = "yx"
        }
        
        positionText.textColor = ui.titleColor
        temperatureText.textColor = ui.titleColor
        
        topLeftText.textColor = ui.titleColor
        bottomLeftText.textColor = ui.titleColor
        posLabelTR.textColor = ui.titleColor
        bottomRightText.textColor = ui.titleColor
        
        zText.textColor = ui.titleColor
        extruderTempLabel.textColor = ui.titleColor
        bedTempLabel.textColor = ui.titleColor
        
        view.backgroundColor = ui.backgroundColor
    }
    
    @objc func eHeatChanged(_ sender: UISlider) {
        tempUpdateCounter = 2

        API.instance.extruderHeat(hotness: sender.value) { _ in
        }
    }
    
    @objc func bedHeatChanged(_ sender: UISlider) {
        tempUpdateCounter = 2
        API.instance.bedHeat(hotness: sender.value) { _ in
        }
    }
    
    @objc func zHeightChanged(_ sender: UISlider) {
        API.instance.move(x: nil, y: nil, z: sender.value, f: 1000) { _ in
        }
    }
    
    // MARK: JoystickSliderDelegate
    
    func headMoved(point: CGPoint) {
        API.instance.move(x: Float(point.x), y: Float(point.y), z: nil, f: 10000) { _ in
        }
    }
    
    // MARK: GridViewDelegate
    
    func gridViewTapped(which: Int) {
        API.instance.commands(commands: gcodeCommands[which].1) { _ in
        }
    }
}
