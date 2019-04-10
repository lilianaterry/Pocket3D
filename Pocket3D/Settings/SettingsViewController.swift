//
//  SettingsViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/21/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import Foundation
import UIKit

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
        setupGridView()
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
    }
    
    // Get GCode button information from UserDefaults
    func setupGridView() {
        // clear out old information
        gcodeGrid.clearCells()
        
        // merge gcode arrays back together
        gcodeCommands = Array(zip(settings.object(forKey: "gcodeNames") as! [String], settings.object(forKey: "gcodeCommands") as! [[String]]))
        
        for command in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: command.0))
        }
    }
    
    @IBAction func addNewButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "addButtonSegue", sender: nil)
    }
    
    // cell is selected in gcode grid view to edit or make new button
    func gridViewTapped(which: Int) {
        performSegue(withIdentifier: "addButtonSegue", sender: which)
        detectChange()
    }
    
    // edit existing button
    func editButton(index: Int, name: String, code: [String]) {
        gcodeCommands[index].0 = name
        gcodeCommands[index].1 = code
        updateGCodeGrid()
    }
    
    // add new button
    func addButton(index: Int, name: String, code: [String]) {
        let newCell = (name, code)
        gcodeCommands.append(newCell)
        updateGCodeGrid()
    }
    
    // remove button at index
    func deleteButton(index: Int) {
        gcodeCommands.remove(at: index)
        updateGCodeGrid()
    }
    
    // refresh grid view based on new gcodeCommands list
    func updateGCodeGrid() {
        gcodeGrid.clearCells()
        
        for command in gcodeCommands {
            gcodeGrid.addCell(view: GcodeGridCell(text: command.0))
        }
        detectChange()
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
        if let extruderMin = settings.value(forKey: "extruderMin") as? Int {
            extruderMinField.text = String(extruderMin)
        } else {
            print("Setup TextFields: no extruder min found")
        }
        
        if let extruderMax = settings.value(forKey: "extruderMax") as? Int {
            extruderMaxField.text = String(extruderMax)
        } else {
            print("Setup TextFields: no extruder max found")
        }
        
        // current heat bed fields
        if let bedMin = settings.value(forKey: "bedMin") as? Int {
            bedMinField.text = String(bedMin)
        } else {
            print("Setup TextFields: no extruder min found")
        }
        
        if let bedMax = settings.value(forKey: "bedMax") as? Int {
            bedMaxField.text = String(bedMax)
        } else {
            print("Setup TextFields: no extruder min found")
        }
        
        // current mirroring fields
        if let mirrorX = settings.value(forKey: "mirrorX") as? Float {
            mirroringXField.text = String(mirrorX)
        } else {
            print("Setup TextFields: no mirroring found for X")
        }
        
        if let mirrorY = settings.value(forKey: "mirrorY") as? Float {
            mirroringYField.text = String(mirrorY)
        } else {
            print("Setup TextFields: no mirroring found for Y")
        }
    }
    
    // select buttons that the user has set and saved in settings before
    func setupButtons() {
        let fileButtons = [alphaSortButton, creationSortButton]
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
        creationLabel.textColor = ui.textColor
        alphaLabel.textColor = ui.textColor
        xyLabel.textColor = ui.textColor
        yxLabel.textColor = ui.textColor
        
        ipAddressText.textColor = ui.titleColor
        apiKeyText.textColor = ui.titleColor
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
        
        // LILIANA_TODO: change this back to enabled
        colorModeText.textColor = ui.textColor
    }
    
    // background coloring/header font
    func setupViews() {
        view.backgroundColor = ui.backgroundColor
        
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
        var allOptions = [alphaSortButton, creationSortButton] as [BubbleButton]
        
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
        usrDefault.set(Int(String(extruderMinField.text!))!, forKey: "extruderMin")
        usrDefault.set(Int(String(extruderMaxField.text!))!, forKey: "extruderMax")
        usrDefault.set(Int(String(bedMinField.text!))!, forKey: "bedMin")
        usrDefault.set(Int(String(bedMaxField.text!))!, forKey: "bedMax")
        usrDefault.set(Float(String(mirroringXField.text!))!, forKey: "mirrorX")
        usrDefault.set(Float(String(mirroringYField.text!))!, forKey: "mirrorY")
        
        // save buttons by splitting array in half
        usrDefault.set(gcodeCommands.map { (element) -> String in
            return element.0
        }, forKey: "gcodeNames")
        usrDefault.set(gcodeCommands.map { (element) -> [String] in
            return element.1
        }, forKey: "gcodeCommands")
        
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
                dest.currName = gcodeCommands[sender as! Int].0
                dest.currCode = gcodeCommands[sender as! Int].1
            } else {
                dest.currIndex = gcodeCommands.count - 1
                dest.newButton = true
            }
        }
    }
}
