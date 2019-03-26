//
//  ControlsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class ControlsViewController: UIViewController, Observer {
    
    let ui = UIExtensions()

    @IBOutlet weak var menuBar: MenuBarView!
    
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
    
    var context: NSManagedObjectContext!
    var settings: NSManagedObject!
    var request: NSFetchRequest<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Push.instance.observe(who: self as Observer, topic: Push.current)
    }
    
    func notify(message: Notification) {
        print("Notifying I guess")
        let json = message.object! as! JSON
        print(json)
        updateTemperature(temp: 13242)
        
    }
    
    func setup() {
        setupCoreData()
        setupViews()
    }
    
    // make sure everything is colored beautifully
    func setupViews() {
        let selectedIndex = IndexPath(item: 0, section: 0)
        menuBar.collectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: [])
        
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
        
        let inverted = (settings.value(forKey: "posCoord") as! Int) == 1
        if (inverted) {
            posLabelTR.text = "yx"
        }
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
    
    // Update functions
    // "temp" is for "temperature", not "temporary" - the lazy variable name
    // Doesn't actually do anything yet
    func updateTemperature(temp: Int) {
        let json : [String: Any] = [
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



