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
    
    var settings = UserDefaults.standard
    
    @IBOutlet var saveButton: ButtonView!
    
    @IBOutlet var ipAddressText: UILabel!
    @IBOutlet var apiKeyText: UILabel!
    @IBOutlet var sortFilesText: UILabel!
    @IBOutlet var posText: UILabel!
    
    @IBOutlet var ipAddressField: TextFieldView!
    @IBOutlet var apiKeyField: TextFieldView!
    
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
    @IBOutlet var mirroringYLabel: UILabel!
    @IBOutlet var mirroringNegXLabel: UILabel!
    @IBOutlet var mirroringNegYLabel: UILabel!
    @IBOutlet var posXButton: BubbleButton!
    @IBOutlet var negXButton: BubbleButton!
    @IBOutlet var posYButton: BubbleButton!
    @IBOutlet var negYButton: BubbleButton!
    
    
    @IBOutlet var gcodeGrid: GridView!
    
    var gcodeCommands: [(String, [String])] = []
    
    var fileSortSelection: ButtonGroupController!
    var xyCoordSelection: ButtonGroupController!
    var mirroringXSelection: ButtonGroupController!
    var mirroringYSelection: ButtonGroupController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gcodeGrid.delegate = self
        setupGridView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setup()
        settings = UserDefaults.standard
    }
    
    func setup() {
        ui = UIExtensions()
        
        view.backgroundColor = ui.backgroundColor

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
        saveUserDefaults()
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
        saveUserDefaults()
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
        
        // add selectors to detec editing
        ipAddressField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        apiKeyField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        bedMaxField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        bedMinField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        extruderMaxField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        extruderMinField.addTarget(self, action: #selector(SettingsViewController.detectTextFieldChange(sender:)), for: .editingDidEnd)
        
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
    }
    
    // select buttons that the user has set and saved in settings before
    func setupButtons() {
        self.fileSortSelection = ButtonGroupController(buttons: [alphaSortButton, creationSortButton])
        self.xyCoordSelection = ButtonGroupController(buttons: [xyCoordButton, yxCoordButton])
        self.mirroringXSelection = ButtonGroupController(buttons: [posXButton, negXButton])
        self.mirroringYSelection = ButtonGroupController(buttons: [posYButton, negYButton])
        
        // file sorting settings
        if let fileSortIndex = settings.value(forKey: "fileSort") as? Int {
            let selected = fileSortSelection.buttons[fileSortIndex]
            fileSortSelection.selectButton(sender: selected)
        } else {
            print("Setup Buttons: no fileSort option found")
        }
        
        // xy coordinate inversion setting
        if let posCoordIndex = settings.value(forKey: "posCoord") as? Int {
            let selected = xyCoordSelection.buttons[posCoordIndex]
            xyCoordSelection.selectButton(sender: selected)
        } else {
            print("Setup Buttons: no posCoord option found")
        }
        
        // current mirroring fields
        if let mirrorX = settings.value(forKey: "mirrorX") as? Float {
            let index = mirrorX == 1.0 ? 0 : 1
            let selected = mirroringXSelection.buttons[index]
            mirroringXSelection.selectButton(sender: selected)
        } else {
            print("Setup Buttons: no mirroring found for X")
        }
        
        if let mirrorY = settings.value(forKey: "mirrorY") as? Float {
            let index = mirrorY == 1.0 ? 0 : 1
            let selected = mirroringYSelection.buttons[index]
            mirroringYSelection.selectButton(sender: selected)
        } else {
            print("Setup Buttons: no mirroring found for Y")
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
        mirroringNegXLabel.textColor = ui.textColor
        mirroringNegYLabel.textColor = ui.textColor
        
        extruderMaxLabel.font = ui.sliderTitleFont
        extruderMinLabel.font = ui.sliderTitleFont
        bedMinLabel.font = ui.sliderTitleFont
        bedMaxLabel.font = ui.sliderTitleFont
        mirroringXLabel.font = ui.sliderTitleFont
        mirroringYLabel.font = ui.sliderTitleFont
        mirroringNegXLabel.font = ui.sliderTitleFont
        mirroringNegYLabel.font = ui.sliderTitleFont
    }
    
    // multiple choice bubble buttons have changed selection for file sorting
    @IBAction func fileSortOptionSelected(_ sender: BubbleButton) {
        let changeDetected = sender.isSelected == false
        fileSortSelection.selectButton(sender: sender)
        
        if changeDetected {
            saveUserDefaults()
        }
    }
    
    // multiple choice bubble buttons have changed selection for xy coords
    @IBAction func coordOptionSelected(_ sender: BubbleButton) {
        let changeDetected = sender.isSelected == false
        xyCoordSelection.selectButton(sender: sender)
        
        if changeDetected {
            saveUserDefaults()
        }
    }
    
    // multiple choice bubble buttons have changed selected for mirroring in the x direction
    @IBAction func mirroringXSelected(_ sender: BubbleButton) {
        let changeDetected = sender.isSelected == false
        mirroringXSelection.selectButton(sender: sender)
        
        if changeDetected {
            saveUserDefaults()
        }
    }
    
    // multiple choice bubble buttons have changed selected for mirroring in the y direction
    @IBAction func mirroringYSelected(_ sender: BubbleButton) {
        let changeDetected = sender.isSelected == false
        mirroringYSelection.selectButton(sender: sender)
        
        if changeDetected {
            saveUserDefaults()
        }
    }
    
    // save to core memory if the button color says a change has occured on the page
    @IBAction func saveSelected(_ sender: UIButton) {
        if sender.isEnabled {
            saveUserDefaults()
            sender.backgroundColor = ui.bodyElementColor
            sender.isEnabled = false
        }
    }
    
    // make sure an empty text field doesn't try to save an undefined value
    @objc func detectTextFieldChange(sender: UITextField) {
        if (sender.text == nil || sender.text?.count == 0) {
            sender.text = "0"
            print("Error: saved an undefined value in a settings text field")
        }
    
        saveUserDefaults()
    }
    
    // save any changes to core data so they persist
    @objc func saveUserDefaults() {
        let usrDefault = UserDefaults.standard
        usrDefault.set(ipAddressField.text, forKey: "ipAddress")
        usrDefault.set(apiKeyField.text, forKey: "apiKey")
        usrDefault.set(fileSortSelection.currSelection, forKey: "fileSort")
        usrDefault.set(xyCoordSelection.currSelection, forKey: "posCoord")
        usrDefault.set(Int(String(extruderMinField.text!))!, forKey: "extruderMin")
        usrDefault.set(Int(String(extruderMaxField.text!))!, forKey: "extruderMax")
        usrDefault.set(Int(String(bedMinField.text!))!, forKey: "bedMin")
        usrDefault.set(Int(String(bedMaxField.text!))!, forKey: "bedMax")
        
        let xSelection = mirroringXSelection.currSelection == 0 ? 1.0 : -1.0 as Float
        let ySelection = mirroringYSelection.currSelection == 0 ? 1.0 : -1.0 as Float
        usrDefault.set(xSelection, forKey: "mirrorX")
        usrDefault.set(ySelection, forKey: "mirrorY")
        
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
