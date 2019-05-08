//
//  EditButtonViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 4/9/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

protocol GCodeButtonDelegate {
    func editButton(index: Int, name: String, code: [String])
    func addButton(index: Int, name: String, code: [String])
    func deleteButton(index: Int)
}

class EditButtonViewController: UIViewController {

    let ui = UIExtensions()
    @IBOutlet var nameField: TextFieldView!
    @IBOutlet var codeField: TextFieldView!
    
    @IBOutlet var popupWindow: UIView!
    @IBOutlet var background: UIView!
    
    var delegate: GCodeButtonDelegate?
    
    var currIndex: Int?
    var currName: String?
    var currCode: [String]?
    var newButton: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameField.updateBorder()
        codeField.updateBorder()
    }
    
    func setup() {
        self.view.backgroundColor = self.ui.textColor.withAlphaComponent(0.5)
        
        popupWindow.layer.cornerRadius = 5.0
        popupWindow.backgroundColor = ui.headerBackgroundColor
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopover))
        background.addGestureRecognizer(tapRecognizer)
        
        if currName != nil {
            nameField.text = currName
        }
        
        if currCode != nil {
            codeField.text = currCode?.joined()
        }
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        if (newButton!) {
            delegate?.addButton(index: currIndex!, name: nameField.text!, code: [codeField.text!])
        } else {
            delegate?.editButton(index: currIndex!, name: nameField.text!, code: [codeField.text!])
        }
        dismissPopover()
    }
    
    @IBAction func deleteSelected(_ sender: Any) {
        if (!newButton!) {
            delegate?.deleteButton(index: currIndex!)
        }
        dismissPopover()
    }
    
    // exit modal popover
    @objc func dismissPopover() {
        self.dismiss(animated: false, completion: nil)
    }
}
