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
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var menuBar: MenuBarView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var filenameLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var webcamImageView: UIImageView!
    
    let ui = UIExtensions()
    var stream: MJPEGStreamLib!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        stream.stop()
    }
    
    // set font and background colors
    func setup() {
        // header
        headerView.backgroundColor = ui.headerBackgroundColor
        let selectedIndex = IndexPath(item: 1, section: 0)
        menuBar.collectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: [])
        
        // body
        view.backgroundColor = ui.backgroundColor
        filenameLabel.textColor = ui.textColor
        progressLabel.textColor = ui.textColor
        timeRemainingLabel.textColor = ui.textColor
    }
    
    func updateStatus(status: String, filename: String) {
        if status == "Printing" {
            statusLabel.text = "Printing:"
            filenameLabel.text = filename
        } else {
            statusLabel.text = status
            filenameLabel.text = ""
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
