//
//  StatusViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    let ui = UIExtensions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        dummyData()
    }
    
    // remove this once API is connected to this view controller
    func dummyData() {
        updateStatus(printing: true, filename: "Toilet.obj")
        updateProgress(progress: 72)
        updateTimeRemaining(timeRemain: 200)
    }
    
    // set font and background colors
    func setup() {
        // header
        headerTitle.textColor = ui.headerTextColor
        headerView.backgroundColor = ui.headerBackgroundColor
        
        // body
        self.view.backgroundColor = ui.backgroundColor
        filenameLabel.textColor = ui.textColor
        progressLabel.textColor = ui.textColor
        timeRemainingLabel.textColor = ui.textColor
    }
    
    func updateStatus(printing: Bool, filename: String) {
        if printing {
            statusLabel.text = "Printing"
            filenameLabel.text = filename
            filenameLabel.sizeToFit()
        } else {
            statusLabel.text = "Idle"
            filenameLabel.text = ""
        }
    }
    
    func updateProgress(progress: Double) {
        progressLabel.text = "\(String(progress))%"
        progressLabel.sizeToFit()
    }
    
    func updateTimeRemaining(timeRemain: Int) {
        let hoursRemaining = timeRemain / 60
        let minsRemaining = timeRemain % 60
        timeRemainingLabel.text = "\(String(hoursRemaining))h\(String(minsRemaining))m"
        timeRemainingLabel.sizeToFit()
    }
}
