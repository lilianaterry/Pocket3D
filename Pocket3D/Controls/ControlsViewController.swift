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

    @IBOutlet weak var xyPositionSlider: JoystickSlider!
    @IBOutlet weak var zPositionSlider: HorizontalCustomSlider!
    @IBOutlet weak var extruderSlider: UISlider!
    @IBOutlet weak var heatbedSlider: UISlider!
    @IBOutlet weak var posLabelTR: UILabel!
    
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

    func headMoved(point: CGPoint) {
        API.instance.move(x: Float(point.x), y: Float(point.y), z: nil, f: 10000) { _ in
        }
    }
}
