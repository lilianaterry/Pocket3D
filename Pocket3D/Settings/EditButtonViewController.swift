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

class EditButtonViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let ui = UIExtensions()
    @IBOutlet var nameField: TextFieldView!
    @IBOutlet var codeCollectionView: UICollectionView!
    
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
        
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let codes = currCode {
            return codes.count + 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = codeCollectionView.dequeueReusableCell(withReuseIdentifier: "gcodeFieldCell", for: indexPath)
        
        let textField = TextFieldView(frame: cell.frame)
        textField.addTarget(self, action: #selector(EditButtonViewController.editCodeField(sender:)), for: .editingDidEnd)
        
        cell.addSubview(textField)
        
        if (currCode != nil && indexPath.row < currCode!.count) {
            textField.text = currCode![indexPath.row]
        }
        
        textField.tag = indexPath.row
                
        return cell
    }
    
    // if this is the last text field being edited, add another to the end so the user can continue
    @objc func editCodeField(sender: TextFieldView) {
        print("editCodeField")
        if (sender.tag == currCode?.count) {
            currCode?.append("")
            self.codeCollectionView.reloadData()
            print("finished refreshing data")
        }
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        if (newButton!) {
//            delegate?.addButton(index: currIndex!, name: nameField.text!, code: [codeField.text!])
        } else {
//            delegate?.editButton(index: currIndex!, name: nameField.text!, code: [codeField.text!])
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
