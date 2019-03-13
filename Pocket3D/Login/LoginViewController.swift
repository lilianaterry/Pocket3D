//
//  LoginViewController.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let ui = UIExtensions()
    @IBOutlet var apiKeyField: TextFieldView!
    @IBOutlet var ipAddressField: TextFieldView!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = ui.headerBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func loginSelected(_ sender: Any) {
        if apiKeyField.hasText && ipAddressField.hasText &&
            apiKeyField.text != "API Key" && ipAddressField.text != "IP Address" {
            errorLabel.text = ""
            
            API.instance.setup(url: ipAddressField.text!, key: apiKeyField.text!)
            API.instance.login { [unowned self] status, _ in
                print("Got status \(status) from logging in")
                
                if status == .Ok {
                let defaultVC = self.storyboard!.instantiateViewController(withIdentifier: "StatusViewController")
                self.present(defaultVC, animated: true, completion: nil)
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
