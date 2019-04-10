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
    
    var delegate: GCodeButtonDelegate?
    
    var currIndex: Int?
    var newButton: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.ui.textColor.withAlphaComponent(0.5)
        
        popupWindow.layer.cornerRadius = 5.0
        popupWindow.backgroundColor = ui.headerBackgroundColor
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelSelected(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameField.updateBorder()
        codeField.updateBorder()
    }
    
    
    // if user taps off of popup window, go back to previous screen
    @objc @IBAction func cancelSelected(_ sender: Any) {
        if (newButton!) {
            delegate?.deleteButton(index: currIndex!)
        }
        dismiss()
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        if (newButton!) {
            delegate?.addButton(index: currIndex!, name: nameField.text!, code: [codeField.text!])
        } else {
            delegate?.editButton(index: currIndex!, name: "Edited Button", code: [])
        }
        dismiss()
    }
    
    @IBAction func deleteSelected(_ sender: Any) {
        delegate?.deleteButton(index: currIndex!)
        dismiss()
    }
    
    // exit modal popover
    func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }
}
