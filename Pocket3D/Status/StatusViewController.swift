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
        //print(json)
        updateFields(status: json["state"]["text"].stringValue,
                     filename: json["job"]["file"]["name"].stringValue,
                     progress: json["progress"]["completion"].doubleValue,
                     timeRemain: json["progress"]["printTimeLeft"].intValue)
        
        
        if json["state"]["text"] == "Operational" {
            NotificationData.currentTimeRemaining = -1
        } else {
            NotificationData.currentFileName = json["job"]["file"]["name"].stringValue
            NotificationData.currentTimeRemaining = json["progress"]["printTimeLeft"].intValue
        }
    }
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var filenameText: UILabel!
    @IBOutlet var progressText: UILabel!
    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var timeText: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var webcamImageView: UIImageView!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var pauseButton: ButtonView!
    @IBOutlet var cancelButton: ButtonView!
    
    let ui = UIExtensions()
    var stream: MJPEGStreamLib!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], for: .normal)
        
        // Do any additional setup after loading the view.
        setup()
        
        Push.instance.observe(who: self as Observer, topic: Push.current)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(settingsChanged),
                                               name: NSNotification.Name(rawValue: "settings_changed"), object: nil)
        settingsChanged()
        
        pauseButton.addTarget(self, action: #selector(pausePressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        
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
    
    // Save button was selected on Settings Page and
    @objc func settingsChanged() {
        let x = UserDefaults.standard.float(forKey: "mirrorX")
        let y = UserDefaults.standard.float(forKey: "mirrorY")
        
        webcamImageView.transform = CGAffineTransform(scaleX: CGFloat(x), y: CGFloat(y))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stream.play()
    }
    
    override func viewWillDisappear(_: Bool) {
        stream.stop()
    }
    
    @objc
    func pausePressed(sender: UIButton) {
        API.instance.pause { _ in
        }
    }
    
    @objc func cancelPressed(sender: UIButton) {
        API.instance.cancel { _ in
        }
    }
    
    // set font and background colors
    func setup() {
        // body
        view.backgroundColor = ui.backgroundColor
        
        statusLabel.textColor = ui.titleColor
        filenameText.textColor = ui.titleColor
        progressText.textColor = ui.titleColor
        timeText.textColor = ui.titleColor
        
        filenameLabel.textColor = ui.textColor
        progressLabel.textColor = ui.textColor
        timeRemainingLabel.textColor = ui.textColor
        
        filenameLabel.adjustsFontSizeToFitWidth = true
        
        errorLabel.layer.zPosition = webcamImageView.layer.zPosition - 1
        
        toggleButtons(turnOn: false)
    }
    
    func toggleButtons(turnOn: Bool) {
        if turnOn {
            pauseButton.isEnabled = true
            cancelButton.isEnabled = true
            pauseButton.backgroundColor = ui.headerTextColor
            cancelButton.backgroundColor = ui.headerTextColor
            pauseButton.alpha = 1.0
            cancelButton.alpha = 1.0
        } else {
            pauseButton.isEnabled = false
            cancelButton.isEnabled = false
            pauseButton.backgroundColor = ui.bodyElementColor
            cancelButton.backgroundColor = ui.bodyElementColor
            pauseButton.alpha = 0.5
            cancelButton.alpha = 0.5
        }
    }
    
    func setPauseButtonLabel(status: String) {
        if (status == "Paused") {
            pauseButton.setTitle("Resume", for: UIControl.State.normal)
        }
        else {
            pauseButton.setTitle("Pause", for: UIControl.State.normal)
        }
    }
    
    func updateFields(status: String, filename: String, progress: Double, timeRemain: Int) {
        statusLabel.text = status
        
        if status == "Operational" {
            filenameLabel.text = "—"
            progressLabel.text = "—"
            timeRemainingLabel.text = "—"
        } else {
            filenameLabel.text = filename
            progressLabel.text = NSString(format: "%.2f%%", progress) as String
            timeRemainingLabel.text = printTimeFormatter.string(from: Double(timeRemain))
        }
        toggleButtons(turnOn: status != "Operational")
        setPauseButtonLabel(status: status)
        statusLabel.sizeToFit()
        progressLabel.sizeToFit()
        timeRemainingLabel.sizeToFit()
    }
}
