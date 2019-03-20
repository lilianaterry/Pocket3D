//
//  StatusViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJPEGStreamLib

class StatusViewController: UIViewController, Observer {
    
    func notify(message: Notification) {
        let json = message.object! as! JSON
        updateStatus(status: json["state"]["text"].stringValue,
                     filename: json["state"]["file"]["name"].stringValue)
        updateProgress(progress: json["progress"]["completion"].doubleValue)
        updateTimeRemaining(timeRemain: json["progress"]["printTimeLeft"].intValue)
    }

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var webcamImageView: UIImageView!
    
    let ui = UIExtensions()
    var stream: MJPEGStreamLib!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        Push.instance.observe(who: self as Observer, topic: Push.current)
        
        // TODO: apply settings for imageview mirroring
        self.webcamImageView.transform = CGAffineTransform(scaleX: -1, y: -1)
        stream = MJPEGStreamLib(imageView: self.webcamImageView)
        stream.contentURL = API.instance.stream()
        print("Playing mjpeg stream \(String(describing: stream.contentURL))")
        stream.didStartLoading = {
            print("MJPEG stream loading...")
        }
        stream.didFinishLoading = {
            print("MJPEG stream loaded!")
        }
        stream.play()
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
    
    func updateStatus(status: String, filename: String) {
        filenameLabel.text = status
        filenameLabel.sizeToFit()
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
