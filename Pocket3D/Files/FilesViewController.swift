//
//  FilesViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import SwiftyJSON
import UIKit

class FilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FileCellDelegate {
    @IBOutlet var tableView: UITableView!
    
    var files: [JSON] = []
    var selectedIndexPath: IndexPath?
    
    lazy var printTimeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute]
        f.zeroFormattingBehavior = [.pad]
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        API.instance.files { [unowned self] _, json in
            self.files = json["files"].arrayValue
//            print("Got files array of \(self.files.count) from json object")
            // TODO: check shared prefernces
            self.files.sort(by: { (a, b) -> Bool in
                a["date"].int64Value > b["date"].int64Value
            })
            self.tableView.reloadData()
        }
    }
    
    func printPressed() {
        API.instance.printFile(file: URL(string: self.files[self.selectedIndexPath!.row]["refs"]["resource"].stringValue)!) { status in
            print("Starting print: \(status)")
        }
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.files.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILE_CELL")! as! FileTableViewCell
        cell.delegate = self
        cell.nameLabel.text = files[indexPath.row]["name"].stringValue
        cell.modifiedLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: files[indexPath.row]["date"].doubleValue), dateStyle: .medium, timeStyle: .medium)
        cell.estTimeLabel.text = printTimeFormatter.string(from:
            files[indexPath.row]["gcodeAnalysis"]["estimatedPrintTime"].doubleValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexpath = selectedIndexPath
        if indexPath == self.selectedIndexPath {
            self.selectedIndexPath = nil
        } else {
            self.selectedIndexPath = indexPath
        }
        var indexPaths: Array<IndexPath> = []
        if let previous = previousIndexpath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! FileTableViewCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == self.selectedIndexPath {
            return FileTableViewCell.expandedHeight
        } else {
            return FileTableViewCell.defaultHeight
        }
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        (cell as! FileTableViewCell).ignoreFrameChanges()
//    }
}

protocol FileCellDelegate: class {
    func printPressed()
}

class FileTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var modifiedLabel: UILabel!
    @IBOutlet var readLabel: UILabel!
    @IBOutlet var estTimeLabel: UILabel!
    @IBOutlet var labelsStack: UIStackView!
    @IBOutlet var printButton: UIButton!
    
    weak var delegate: FileCellDelegate!
    
    class var expandedHeight: CGFloat { return 165 }
    class var defaultHeight: CGFloat { return 50 }
    
    func checkHeight() {
        self.modifiedLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        self.readLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        self.estTimeLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        self.labelsStack.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        self.printButton.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        self.checkHeight()
    }
    
//    func ignoreFrameChanges() {
//        //do nothing
//    }
    @IBAction func printButtonPressed(_ sender: Any) {
        self.delegate.printPressed()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            self.checkHeight()
        }
    }
}
