//
//  ControlsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/20/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class ControlsViewController: UIViewController {
    
    let ui = UIExtensions()

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var xyPositionSlider: UIView!
    @IBOutlet weak var zPositionSlider: HorizontalCustomSlider!
    @IBOutlet weak var extruderSlider: UISlider!
    @IBOutlet weak var heatbedSlider: UISlider!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        contentView.backgroundColor = ui.backgroundColor
        
        headerView.backgroundColor = ui.headerBackgroundColor
        headerTitle.font = ui.headerTitleFont
        headerTitle.textColor = ui.headerTextColor
    }
    
    @IBAction func extruderTempSlider(_ sender: Any) {
        let slider = sender as! HorizontalCustomSlider
        slider.updateLabelPosition()
    }
}



