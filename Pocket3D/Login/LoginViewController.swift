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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = ui.header_backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

