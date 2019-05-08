//
//  LoginViewController.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import OctoKit
import UIKit

class LoginViewController: UIViewController {
    let ui = UIExtensions()

    @IBOutlet var welcomeText: UILabel!
    @IBOutlet var signinText: UILabel!
    @IBOutlet var apiKeyField: TextFieldView!
    @IBOutlet var ipAddressField: TextFieldView!
    @IBOutlet var errorLabel: UILabel!

    var context: NSManagedObjectContext!
    var settings: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setup()

        if let key = UserDefaults.standard.string(forKey: "apiKey"), let ip = UserDefaults.standard.string(forKey: "ipAddress") {
            apiKeyField.text = key
            ipAddressField.text = ip
        }
    }

    // setup data and UI
    func setup() {
        view.backgroundColor = ui.backgroundColor

        welcomeText.textColor = ui.titleColor
        signinText.textColor = ui.titleColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func loginSelected(_: Any) {
        if apiKeyField.hasText, ipAddressField.hasText,
            apiKeyField.text != "API Key", ipAddressField.text != "IP Address" {
            errorLabel.text = ""

            API.instance.setup(url: ipAddressField.text!, key: apiKeyField.text!)
            API.instance.login { [unowned self] status, json in
                print("Got status \(status) from logging in")

                if status == .Ok {
                    UserDefaults.standard.set(self.apiKeyField.text!, forKey: "apiKey")
                    UserDefaults.standard.set(self.ipAddressField.text!, forKey: "ipAddress")
                    let ud = UserDefaults.init(suiteName: "group.utexas.cs371.team2.Pocket3D")!
                    ud.set(self.apiKeyField.text!, forKey: "apiKey")
                    ud.set(self.ipAddressField.text!, forKey: "ipAddress")
                    Push.instance.connect(baseUrl: URL(string: self.ipAddressField.text!)!,
                                          name: json["name"].stringValue,
                                          sessionKey: json["session"].stringValue)
                    self.performSegue(withIdentifier: "LOGIN", sender: self)
                } else {
                    self.errorLabel.text = "Login info incorrect"
                }
            }
        } else {
            if (!apiKeyField.hasText || apiKeyField.text == "API Key") &&
                (!ipAddressField.hasText || ipAddressField.text == "IP Address") {
                errorLabel.text = "Please provide an API Key and IP Address"
            } else if !apiKeyField.hasText || apiKeyField.text == "API Key" {
                errorLabel.text = "Please provide an API Key"
            } else if !ipAddressField.hasText || ipAddressField.text == "IP Address" {
                errorLabel.text = "Please provide an IP Address"
            }
        }
    }
}
