//
//  SettingsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/21/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit
import Foundation

enum SelectedButtonTag: Int {
    case First
    case Second
    case Third
}

class SettingsViewController: UIViewController, GridViewDelegate, GCodeButtonDelegate {

    var ui = UIExtensions()
    
    let settings = UserDefaults.standard
    
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
    
    @IBOutlet var extruderMinLabel: UILabel!
    @IBOutlet var extruderMinField: TextFieldView!
    @IBOutlet var extruderMaxLabel: UILabel!
    @IBOutlet var extruderMaxField: TextFieldView!
    @IBOutlet var bedMinLabel: UILabel!
    @IBOutlet var bedMinField: TextFieldView!
    @IBOutlet var bedMaxLabel: UILabel!
    @IBOutlet var bedMaxField: TextFieldView!
    
    @IBOutlet var mirroringXLabel: UILabel!
    @IBOutlet var mirroringXField: TextFieldView!
    @IBOutlet var mirroringYLabel: UILabel!
    @IBOutlet var mirroringYField: TextFieldView!
    
    @IBOutlet var gcodeGrid: GridView!
    
    var gcodeCommands: [(String, [String])] = []
    
    var fileSortSelection: Int!
    var xyCoordSelection: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gcodeGrid.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setup()
    }

    func setup() {
        ui = UIExtensions()

        setupViews()
        setupLabels()
        setupButtons()
        setupTextFields()
        setupGridView()
    }
    
    // Get GCode button information from UserDefaults
    func setupGridView() {
        // clear out old information
        self.gcodeCommands = []
        gcodeGrid.clearCells()
        
        // merge gcode arrays back together
        let commandNames = settings.object(forKey: "gcodeNames") as! [String]
        let commands = settings.object(forKey: "gcodeCommands") as! [[String]]
        
        for index in 0...commandNames.count - 1 {
            let gcodeCommand = (commandNames[index], commands[index])
            self.gcodeCommands.append(gcodeCommand)
        }
        
        for command in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: command.0))
        }
    }
    
    @IBAction func addNewButtonTapped(_ sender: Any) {
        // LILIANA_TODO
        // trigger popover to create new button
        let newCell = GcodeGridCell(text: "New Button")
        gcodeGrid.addCell(view: newCell)
        gcodeCommands.append(("New Button", ["new_button"]))
        
        performSegue(withIdentifier: "addButtonSegue", sender: nil)
        detectChange()
    }
    
    // cell is selected in gcode grid view to edit or make new button
    func gridViewTapped(which: Int) {
        // LILIANA_TODO
        performSegue(withIdentifier: "addButtonSegue", sender: which)
        detectChange()
    }
    
    func editButton(index: Int, name: String, code: [String]) {
        print("EDIT BUTTON")
        gcodeGrid.clearCells()
        gcodeCommands[index] = ("NEW!!", code)
        
        for command in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: command.0))
        }
    }
    
    func addButton(index: Int, name: String, code: [String]) {
        print("ADD BUTTON")
    }
    
    func deleteButton(index: Int) {
        print("DELETE BUTTON")
    }

    // add editing recognizers and fill with core data
    func setupTextFields() {
        // re-constrain after loading view
        ipAddressField.updateBorder()
        apiKeyField.updateBorder()
        
        bedMaxField.updateBorder()
        bedMinField.updateBorder()
        
        extruderMaxField.updateBorder()
        extruderMinField.updateBorder()
        
        mirroringXField.updateBorder()
        mirroringYField.updateBorder()
        
        // add selectors to detec editing
        ipAddressField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        apiKeyField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        bedMaxField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        bedMinField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        extruderMaxField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        extruderMinField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        mirroringXField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)
        mirroringYField.addTarget(self, action: #selector(SettingsViewController.detectChange), for: .editingChanged)

        
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
            print("Setup TextFields: no ipAddress found")
        }
        
        // current extruder fields
        if let extruderMin = settings.value(forKey: "extruderMin") as? String {
            extruderMinField.text = extruderMin
        } else {
            print("Setup TextFields: no extruder min found")
        }
        
        if let extruderMax = settings.value(forKey: "extruderMax") as? String {
            extruderMaxField.text = extruderMax
        } else {
            print("Setup TextFields: no extruder max found")
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
        
        extruderMaxLabel.textColor = ui.textColor
        extruderMinLabel.textColor = ui.textColor
        bedMinLabel.textColor = ui.textColor
        bedMaxLabel.textColor = ui.textColor
        mirroringXLabel.textColor = ui.textColor
        mirroringYLabel.textColor = ui.textColor
        
        extruderMaxLabel.font = ui.sliderTitleFont
        extruderMinLabel.font = ui.sliderTitleFont
        bedMinLabel.font = ui.sliderTitleFont
        bedMaxLabel.font = ui.sliderTitleFont
        mirroringXLabel.font = ui.sliderTitleFont
        mirroringYLabel.font = ui.sliderTitleFont
        
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
            saveUserDefaults()
            sender.backgroundColor = ui.bodyElementColor
            sender.isEnabled = false
        }
    }

    // save any changes to core data so they persist
    func saveUserDefaults() {
        let usrDefault = UserDefaults.standard
        usrDefault.set(ipAddressField.text, forKey: "ipAddress")
        usrDefault.set(apiKeyField.text, forKey: "apiKey")
        usrDefault.set(colorModeSwitch.selectedSegmentIndex, forKey: "colorMode")
        usrDefault.set(fileSortSelection, forKey: "fileSort")
        usrDefault.set(xyCoordSelection, forKey: "posCoord")
        usrDefault.set(extruderMinField.text, forKey: "extruderMin")
        usrDefault.set(extruderMaxField.text, forKey: "extruderMax")
        usrDefault.set(bedMinField.text, forKey: "bedMin")
        usrDefault.set(bedMaxField.text, forKey: "bedMax")
        usrDefault.set(mirroringXField.text, forKey: "mirrorX")
        usrDefault.set(mirroringYField.text, forKey: "mirrorY")
        
        // save buttons by splitting array in half
        let commandNames = gcodeCommands.map { (element) -> String in
            return element.0
        }
        let commands = gcodeCommands.map { (element) -> [String] in
            return element.1
        }
        usrDefault.set(commandNames, forKey: "gcodeNames")
        usrDefault.set(commands, forKey: "gcodeCommands")
        
        let settingsChanged = Notification.Name("settings_changed")
        NotificationCenter.default.post(name: settingsChanged, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addButtonSegue" {
            let dest = segue.destination as! EditButtonViewController
            dest.delegate = self
            if sender != nil {
                dest.currIndex = sender as? Int
                dest.newButton = false
            } else {
                dest.currIndex = gcodeCommands.count - 1
                dest.newButton = true
            }
        }
    }
}
