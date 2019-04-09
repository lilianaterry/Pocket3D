//
//  GridView.swift
//  Pocket3D
//
//  Created by Chris Day on 4/5/19.
//  Copyright © 2019 Team 2. All rights reserved.
//
// Adapted from
// https://medium.com/@alexxjk_mar/swift-grid-layout-based-on-uistackview-cc927fc43d8b

import Foundation
import UIKit

private class FakeCell : UIView {}

protocol GridViewDelegate: class {
    func gridViewTapped(which: Int)
}

class GridView: UIStackView {
    private var cells: [UIView] = []
    private var currentRow: UIStackView?
    
    weak var delegate: GridViewDelegate?
    
    @IBInspectable var columns: Int = 3
    @IBInspectable var rowHeight: CGFloat = 66
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    private func prepareRow() -> UIStackView {
        let row = UIStackView(arrangedSubviews: [])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.distribution = .fillEqually
        return row
    }
    
    func addCell(view: UIView) {
        self.currentRow?.arrangedSubviews.filter { $0 is FakeCell }.forEach({ view in
            view.removeFromSuperview()
        })
        
        let firstCellInRow = self.cells.count % self.columns == 0
        if self.currentRow == nil || firstCellInRow {
            self.currentRow = self.prepareRow()
            self.addArrangedSubview(self.currentRow!)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: self.rowHeight).isActive = true
        view.setNeedsLayout()
        self.cells.append(view)
        self.currentRow!.addArrangedSubview(view)
        
        let lastCellInRow = self.cells.count % self.columns == 0
        if !lastCellInRow {
            let fakeCellCount = self.columns - self.cells.count % self.columns
            for _ in 0..<fakeCellCount {
                self.currentRow!.addArrangedSubview(FakeCell())
            }
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(childTapped)))
    }
    
    func updateCell(index: Int, name: String) {
        cells[index] = GcodeGridCell(text: name)
    }
    
    // clean out all gcode buttons when settings page has been updated 
    func clearCells() {
        cells = []
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @objc
    func childTapped(sender: UITapGestureRecognizer) {
        if let tapped = self.cells.index(of: sender.view!) {
            self.delegate?.gridViewTapped(which: tapped)
        }
    }
}
