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

class ControlsViewController: UIViewController, Observer, JoystickSliderDelegate, GridViewDelegate {
    let ui = UIExtensions()
    
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

    var gcodeCommands: [(String, [String])] = [("Home X", ["G28 X"]),
                                               ("Home Y", ["G28 Y"]),
                                               ("Home Z", ["G28 Z"]),
                                               ("Klipper reset", ["firmware_restart", "restart"]),
                                               ("Test multiple", ["G28 X", "G0 X250 F10000"])]

    var context: NSManagedObjectContext!
    var settings: NSManagedObject!
    var request: NSFetchRequest<NSFetchRequestResult>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        Push.instance.observe(who: self as Observer, topic: Push.current)

        xyPositionSlider.delegate = self
        zPositionSlider.isContinuous = false
        extruderSlider.isContinuous = false
        heatbedSlider.isContinuous = false
        zPositionSlider.addTarget(self, action: #selector(zHeightChanged), for: .valueChanged)
        extruderSlider.addTarget(self, action: #selector(eHeatChanged), for: .valueChanged)
        heatbedSlider.addTarget(self, action: #selector(bedHeatChanged), for: .valueChanged)

        gcodeGrid.delegate = self
//        if let commands = UserDefaults.standard.array(forKey: "gcode_commands") as! [(String, String)]? {
//            self.gcodeCommands = commands
//            self.gcodeGrid.addCell(view: GcodeGridCell(text: "Hello"))
//            self.gcodeGrid.addCell(view: GcodeGridCell(text: "World"))
        for c in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: c.0))
        }
//        }
    }

//    override func viewWillLayoutSubviews() {
//        let max = xyPositionSlider.bounds.height
//        xyPositionSlider.moveHead(location: CGPoint(x: 0, y: max))
//    }

    func notify(message: Notification) {
        let json = message.object! as! JSON
        if json["temps"].array?.count != 0 {
            extruderTempLabel.text = "Extruder: \(json["temps"][0]["tool0"]["actual"].floatValue)°"
            bedTempLabel.text = "Heat Bed: \(json["temps"][0]["bed"]["actual"].floatValue)°"
            extruderSlider.value = json["temps"][0]["tool0"]["target"].floatValue
            heatbedSlider.value = json["temps"][0]["bed"]["target"].floatValue
        }
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
//        if (json["state"]["text"] == "Printing") {
//            // Do something to gray out controls
//            // For now it just hides it which
//            // looks ugly as balls so probably find a way to gray it out
//            // and turn off the controls.
//            // One way would be to have boolean to check if it's enabled
//            // and stop it from sending the command to the printer in the
//            // head moving functions and then just do something ot the view visually
//            xyPositionSlider.isHidden = true
//            zPositionSlider.isHidden = true
//        }
//        else {
//            // Do something to ungray controls
//            xyPositionSlider.isHidden = false
//            zPositionSlider.isHidden = false
//        }
    }

    func setup() {
        setupCoreData()
        setupViews()
    }

    // make sure everything is colored beautifully
    func setupViews() {
        let inverted = (settings.value(forKey: "posCoord") as! Int) == 1
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
        
        self.view.backgroundColor = ui.backgroundColor
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

    @objc func eHeatChanged(_ sender: UISlider) {
        API.instance.extruderHeat(hotness: sender.value) { _ in
        }
    }

    @objc func bedHeatChanged(_ sender: UISlider) {
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
        API.instance.commands(commands: self.gcodeCommands[which].1) { _ in
        }
    }
}
