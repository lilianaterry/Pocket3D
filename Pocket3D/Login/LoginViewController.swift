//
//  LoginViewController.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    let ui = UIExtensions()
    @IBOutlet var apiKeyField: TextFieldView!
    @IBOutlet var ipAddressField: TextFieldView!
    @IBOutlet var errorLabel: UILabel!
    
    var context: NSManagedObjectContext!
    var settings: NSManagedObject!
    
    var delegate: SegueDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = ui.headerBackgroundColor
        
        setupCoreData("Settings")
        
        delegate = MenuBarView(frame: CGRect())
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
                    self.saveToCoreData()
                    self.delegate.segue(identifier: "Status")
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
    
    // save login information to core data for settings page
    func saveToCoreData() {
        settings.setValue(ipAddressField.text, forKey: "ipAddress")
        settings.setValue(apiKeyField.text, forKey: "apiKey")
        do {
            try context.save()
        } catch  {
            print("Failed to save login information to Core Data")
        }
    }
    // setup core data to save login information
    func setupCoreData(_ entity:String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        // fetch settings if any have been made before
        
        do {
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if (results.count > 0) {
                
                settings = results[0]
                print("API Key: ")
                let apiKey = settings.value(forKey: "apiKey") as! String
                let ipAddress = settings.value(forKey: "ipAddress") as! String
                apiKeyField.text = apiKey
                ipAddressField.text = ipAddress
 
                
            } else {
                
                createNewDataObject()
                
            }
            
            // create new settings entity if has not been created yet
            
        } catch {
            
            createNewDataObject()
        }
    }

    // create and add a new object for Settings
    func createNewDataObject() {
        settings = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context)
        settings.setValue(0, forKey: "fileSort")
        settings.setValue(0, forKey: "posCoord")
        settings.setValue(0, forKey: "colorMode")
    }
}
