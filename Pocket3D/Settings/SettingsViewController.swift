//
//  SettingsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/21/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import UIKit

enum SelectedButtonTag: Int {
    case First
    case Second
    case Third
}

class SettingsViewController: UIViewController {
    var ui = UIExtensions()
    
    var delegate: CustomTabBar?
    
    @IBOutlet var saveButton: ButtonView!

    @IBOutlet var ipAddressText: UILabel!
    @IBOutlet var apiKeyText: UILabel!
    @IBOutlet var colorModeText: UILabel!
    @IBOutlet var sortFilesText: UILabel!
    @IBOutlet var posText: UILabel!
    
    @IBOutlet var ipAddressField: TextFieldView!
    @IBOutlet var apiKeyField: TextFieldView!

    @IBOutlet var colorModeSwitch: UISegmentedControl!

    @IBOutlet var modifySortButton: BubbleButton!
    @IBOutlet var modifyLabel: UILabel!
    @IBOutlet var creationSortButton: BubbleButton!
    @IBOutlet var creationLabel: UILabel!
    @IBOutlet var alphaSortButton: BubbleButton!
    @IBOutlet var alphaLabel: UILabel!

    @IBOutlet var xyCoordButton: BubbleButton!
    @IBOutlet var xyLabel: UILabel!
    @IBOutlet var yxCoordButton: BubbleButton!
    @IBOutlet var yxLabel: UILabel!

    var context: NSManagedObjectContext!
    var settings: NSManagedObject!
    var request: NSFetchRequest<NSFetchRequestResult>!

    var fileSortSelection: Int!
    var xyCoordSelection: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setup()
    }

    func setup() {
        ui = UIExtensions()

        setupCoreData()
        setupViews()
        setupLabels()
        setupButtons()
        setupTextFields()
        
        self.delegate = self.tabBarController as? CustomTabBar
    }

    // get core data Settings object
    func setupCoreData() {
        // get current core data information
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            settings = result[0]
        } catch {
            print("Failed to retrieve settings from Core Data")
        }
    }

    // add editing recognizers and fill with core data
    func setupTextFields() {
        ipAddressField.setNeedsLayout()
        apiKeyField.setNeedsLayout()
        
        ipAddressField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        apiKeyField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)

        // current IP address
        if let ipAddress = settings.value(forKey: "ipAddress") as? String {
            ipAddressField.text = ipAddress
        } else {
            print("Setup TextFields: no ipAddress found")
        }
        // current API Key
        if let apiKey = settings.value(forKey: "apiKey") as? String {
            apiKeyField.text = apiKey
        } else {
            print("Setup TextFields: no apiKey found")
        }
    }

    // select buttons that the user has set and saved in settings before
    func setupButtons() {
        let fileButtons = [alphaSortButton, creationSortButton, modifySortButton]
        let xyCoordButtons = [xyCoordButton, yxCoordButton]

        if let fileSort = settings.value(forKey: "fileSort") as? Int {
            fileButtons[fileSort]!.selectButton(toDeselect: [])
            fileSortSelection = fileSort
        } else {
            print("Setup Buttons: no fileSort option found")
        }
        // xy coordinate inversion setting
        if let posCoord = settings.value(forKey: "posCoord") as? Int {
            xyCoordButtons[posCoord]!.selectButton(toDeselect: [])
            xyCoordSelection = posCoord
        } else {
            print("Setup Buttons: no posCoord option found")
        }
        // color mode setting
        if let colorMode = settings.value(forKey: "colorMode") as? Int {
            colorModeSwitch.selectedSegmentIndex = colorMode
        } else {
            print("Setup Buttons: no inDarkMode option found")
        }
    }

    // make labels ui.textcolor
    func setupLabels() {
        modifyLabel.textColor = ui.textColor
        creationLabel.textColor = ui.textColor
        alphaLabel.textColor = ui.textColor
        xyLabel.textColor = ui.textColor
        yxLabel.textColor = ui.textColor
        
        ipAddressText.textColor = ui.titleColor
        apiKeyText.textColor = ui.titleColor
        colorModeText.textColor = ui.titleColor
        sortFilesText.textColor = ui.titleColor
        posText.textColor = ui.titleColor
        
        colorModeSwitch.tintColor = ui.titleColor
    }

    // background coloring/header font
    func setupViews() {
        self.view.backgroundColor = ui.backgroundColor
        
        saveButton.backgroundColor = ui.bodyElementColor
        saveButton.isEnabled = false
    }

    // any change has occured on the page, triggering a blue save button to indicate you need to save
    @objc func detectChange() {
        saveButton.backgroundColor = ui.headerTextColor
        saveButton.isEnabled = true
    }

    // switched to dark or light mode
    @IBAction func colorModeSelected(sender: UISegmentedControl) {
        detectChange()
    }

    // multiple choice bubble buttons have changed selection for file sorting
    @IBAction func fileSortOptionSelected(_ sender: UIButton) {
        var allOptions = [alphaSortButton, creationSortButton, modifySortButton] as [BubbleButton]

        let tag = sender.tag
        let toSelect = allOptions[tag]
        allOptions.remove(at: tag)

        if toSelect.isSelected == false {
            detectChange()
        }

        fileSortSelection = toSelect.tag
        toSelect.selectButton(toDeselect: allOptions)
    }

    // multiple choice bubble buttons have changed selection for xy coords
    @IBAction func coordOptionSelected(_ sender: UIButton) {
        var allOptions = [xyCoordButton, yxCoordButton] as [BubbleButton]

        let tag = sender.tag
        let toSelect = allOptions[tag]
        allOptions.remove(at: tag)

        if toSelect.isSelected == false {
            detectChange()
        }

        xyCoordSelection = toSelect.tag
        toSelect.selectButton(toDeselect: allOptions)
    }

    // save to core memory if the button color says a change has occured on the page
    @IBAction func saveSelected(_ sender: UIButton) {
        if sender.isEnabled {
            saveCoreData()
            sender.backgroundColor = ui.bodyElementColor
            sender.isEnabled = false
            
            let mode = self.colorModeSwitch.selectedSegmentIndex == 0 ? true : false
            UserDefaults.standard.set(mode, forKey: "isDarkMode")
            
            setup()
            delegate!.switchColorMode()
        }
    }

    // save any changes to core data so they persist
    func saveCoreData() {
        settings.setValue(ipAddressField.text, forKey: "ipAddress")
        settings.setValue(apiKeyField.text, forKey: "apiKey")
        settings.setValue(fileSortSelection, forKey: "fileSort")
        settings.setValue(xyCoordSelection, forKey: "posCoord")
        settings.setValue(colorModeSwitch.selectedSegmentIndex, forKey: "colorMode")

        do {
            try context.save()
        } catch {
            print("Failed to save login information to Core Data")
        }
    }
}
