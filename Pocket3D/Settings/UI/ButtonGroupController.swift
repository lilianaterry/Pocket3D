//
//  ButtonGroup.swift
//  Pocket3D
//
//  Created by Liliana Terry on 4/12/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

class ButtonGroupController {
    
    var buttons: [BubbleButton]
    var currSelection: Int
    
    init(buttons: [BubbleButton]) {
        self.buttons = buttons
        self.currSelection = 0
        
        // tag each button to keep track of selected index
        var index = 0
        for button in buttons {
            button.tag = index
            index = index + 1
        }
    }
    
    // selects sender and deselects all others in this grouping
    public func selectButton(sender: BubbleButton) {
        for button in buttons {
            // select button
            if button.hashValue == sender.hashValue {
                button.selectButton()
                currSelection = button.tag
            } else {
                button.deselectButton()
            }
        }
    }
}
