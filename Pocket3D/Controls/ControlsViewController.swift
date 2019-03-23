//
//  ControlsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit
import SwiftyJSON

class ControlsViewController: UIViewController, Observer {
    
    let ui = UIExtensions()

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var xyPositionSlider: UIView!
    @IBOutlet weak var zPositionSlider: HorizontalCustomSlider!
    @IBOutlet weak var extruderSlider: UISlider!
    @IBOutlet weak var heatbedSlider: UISlider!
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var posLabelTL: UILabel!
    @IBOutlet weak var posLabelTR: UILabel!
    @IBOutlet weak var posLabelBL: UILabel!
    @IBOutlet weak var posLabelBR: UILabel!
    @IBOutlet weak var zPosTitle: UILabel!
    @IBOutlet weak var extruderTitle: UILabel!
    @IBOutlet weak var heatbedTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
        
        Push.instance.observe(who: self as Observer, topic: Push.current)
    }
    
    func notify(message: Notification) {
        print("Notifying I guess")
        let json = message.object! as! JSON
        //print(json)
        updateTemperature(temp: 13242)
        
    }
    
    func setup() {
        contentView.backgroundColor = ui.backgroundColor
        
        headerView.backgroundColor = ui.headerBackgroundColor
        headerTitle.font = ui.headerTitleFont
        headerTitle.textColor = ui.headerTextColor
        
        posLabelTL.textColor = ui.textColor
        posLabelTR.textColor = ui.textColor
        posLabelBL.textColor = ui.textColor
        posLabelBR.textColor = ui.textColor
        zPosTitle.textColor = ui.textColor
        extruderTitle.textColor = ui.textColor
        heatbedTitle.textColor = ui.textColor
    }
    
    // Update functions
    // "temp" is for "temperature", not "temporary" - the lazy variable name
    // Doesn't actually do anything yet
    func updateTemperature(temp: Int) {
        var json : [String: Any] = [
        "command": "target",
        "targets": [
            "tool0": 220,
            "tool1": 205
            ]
        ]
        let valid = JSONSerialization.isValidJSONObject(json) // true
        print(valid)
    }
}



