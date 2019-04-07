//
//  StatusViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import MJPEGStreamLib
import SwiftyJSON
import UIKit

class StatusViewController: UIViewController, Observer {
    lazy var printTimeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute]
        f.zeroFormattingBehavior = [.pad]
        return f
    }()

    func notify(message: Notification) {
        let json = message.object! as! JSON
        updateStatus(status: json["state"]["text"].stringValue,
                     filename: json["job"]["file"]["name"].stringValue)
        updateProgress(progress: json["progress"]["completion"].doubleValue)
        updateTimeRemaining(timeRemain: json["progress"]["printTimeLeft"].intValue)
    }

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var webcamImageView: UIImageView!
    @IBOutlet var errorLabel: UILabel!

    @IBOutlet weak var pauseButton: ButtonView!
    @IBOutlet weak var cancelButton: ButtonView!
    
    let ui = UIExtensions()
    var stream: MJPEGStreamLib!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], for: .normal)

        // Do any additional setup after loading the view.
        setup()

        Push.instance.observe(who: self as Observer, topic: Push.current)

        // TODO: apply settings for imageview mirroring
        webcamImageView.transform = CGAffineTransform(scaleX: -1, y: -1)
        stream = MJPEGStreamLib(imageView: webcamImageView)
        stream.contentURL = API.instance.stream()
        print("Playing mjpeg stream \(String(describing: stream.contentURL))")
        stream.didStartLoading = {
            print("MJPEG stream loading...")
        }
        stream.didFinishLoading = {
            print("MJPEG stream loaded!")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stream.play()
    }

    override func viewWillDisappear(_: Bool) {
        stream.stop()
    }

    // set font and background colors
    func setup() {
        // body
        filenameLabel.textColor = ui.textColor
        progressLabel.textColor = ui.textColor
        timeRemainingLabel.textColor = ui.textColor

        errorLabel.layer.zPosition = webcamImageView.layer.zPosition - 1
        
        toggleButtons(turnOn: false)
    }
    
    func toggleButtons(turnOn: Bool) {
        if (turnOn) {
            pauseButton.isEnabled = true
            cancelButton.isEnabled = true
            pauseButton.backgroundColor = ui.headerTextColor
            cancelButton.backgroundColor = ui.headerTextColor
            pauseButton.alpha = 1.0
            cancelButton.alpha = 1.0
        } else {
            pauseButton.isEnabled = false
            cancelButton.isEnabled = false
            pauseButton.backgroundColor = ui.textColor
            cancelButton.backgroundColor = ui.textColor
            pauseButton.alpha = 0.5
            cancelButton.alpha = 0.5
        }
    }

    func updateStatus(status: String, filename: String) {
        if status == "Printing" {
            statusLabel.text = "Printing:"
            filenameLabel.text = filename
            toggleButtons(turnOn: true)
        } else {
            statusLabel.text = status
            filenameLabel.text = "-"
            toggleButtons(turnOn: false)
        }
        statusLabel.sizeToFit()
        filenameLabel.sizeToFit()
    }

    func updateProgress(progress: Double) {
        progressLabel.text = NSString(format: "%.2f%%", progress) as String
        progressLabel.sizeToFit()
    }

    func updateTimeRemaining(timeRemain: Int) {
        timeRemainingLabel.text = printTimeFormatter.string(from: Double(timeRemain))
        timeRemainingLabel.sizeToFit()
    }
}
