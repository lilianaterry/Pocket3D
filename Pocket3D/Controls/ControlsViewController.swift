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

class ControlsViewController: UIViewController, Observer, JoystickSliderDelegate {
    let ui = UIExtensions()
    
    @IBOutlet var menuBar: MenuBarView!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerTitle: UILabel!
    
    @IBOutlet var xyPositionSlider: JoystickSlider!
    @IBOutlet var zPositionSlider: HorizontalCustomSlider!
    @IBOutlet var extruderSlider: UISlider!
    @IBOutlet var heatbedSlider: UISlider!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var posLabelTL: UILabel!
    @IBOutlet var posLabelTR: UILabel!
    @IBOutlet var posLabelBL: UILabel!
    @IBOutlet var posLabelBR: UILabel!
    @IBOutlet var zPosTitle: UILabel!
    @IBOutlet var extruderTitle: UILabel!
    @IBOutlet var heatbedTitle: UILabel!
    
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
    }
    
    override func viewWillLayoutSubviews() {
        let max = xyPositionSlider.bounds.height
        xyPositionSlider.moveHead(location: CGPoint(x: 0, y: max))
    }
    
    func notify(message: Notification) {
        let json = message.object! as! JSON
    }
    
    func setup() {
        setupCoreData()
        setupViews()
    }
    
    // make sure everything is colored beautifully
    func setupViews() {
        self.view.backgroundColor = ui.backgroundColor
        
        let selectedIndex = IndexPath(item: 1, section: 0)
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
        if inverted {
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
    
    @objc func eHeatChanged(_ sender: UISlider) {
        API.instance.extruderHeat(hotness: sender.value) { (status) in
        }
    }
    
    @objc func bedHeatChanged(_ sender: UISlider) {
        API.instance.bedHeat(hotness: sender.value) { (status) in
        }
    }
    
    @objc func zHeightChanged(_ sender: UISlider) {
        API.instance.move(x: nil, y: nil, z: sender.value, f: 1000) { (status) in
            
        }
    }
    
    func headMoved(point: CGPoint) {
        API.instance.move(x: Float(point.x), y: Float(point.y), z: nil, f: 10000) { (status) in
            
        }
    }
}
