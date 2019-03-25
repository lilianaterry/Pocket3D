//
//  FilesViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import SwiftyJSON
import UIKit

class FilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    var files: [JSON] = []
    //alpha use only
    var tempFiles: [tempFile] = []
    var selectedIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //for Alpha use only
        let file1 = tempFile(name: "Robot Toy", modDate: "Nov 7 2017", readDate: "Nov 16 2017", estTime: "23h22m")
        let file2 = tempFile(name: "Toilet", modDate: "Jan 23 2019", readDate: "Jan 23 2019", estTime: "12h35m")
        let file3 = tempFile(name: "Circle", modDate: "Oct 31 2015", readDate: "Nov 4 2017", estTime: "0h20m")
        let file4 = tempFile(name: "Square", modDate: "Feb 14 2018", readDate: "Apr 14 2019", estTime: "2h15m")
        let file5 = tempFile(name: "Triangle", modDate: "Jul 4 1776", readDate: "Jul 4 2017", estTime: "26h30m")
        let file6 = tempFile(name: "TempFile", modDate: "Nov 7 2017", readDate: "Nov 16 2017", estTime: "0h10m")
        self.tempFiles = [file1, file2, file3, file4, file5, file6, file6, file6, file6, file6, file6, file6]
        //self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
//        API.instance.files { [unowned self] _, json in
//            self.files = json["files"].arrayValue
//            print("Got files array of \(self.files.count) from json object")
//            // TODO: check shared prefernces
//            self.files.sort(by: { (a, b) -> Bool in
//                a["date"].int64Value > b["date"].int64Value
//            })
//            self.tableView.reloadData()
//        }
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return section == 0 ? self.files.count : 0
        //alpha use only
        return section == 0 ? self.tempFiles.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILE_CELL")! as! FileTableViewCell
        //cell.nameLabel.text = files[indexPath.row]["name"].stringValue
        //alpha use only
        cell.nameLabel.text = tempFiles[indexPath.row].name
        cell.modifiedLabel.text = tempFiles[indexPath.row].modDate
        cell.readLabel.text = tempFiles[indexPath.row].readDate
        cell.estTimeLabel.text = tempFiles[indexPath.row].estTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        API.instance.printFile(file: URL(string: self.files[indexPath.row]["refs"]["resource"].stringValue)!) { status in
//            print("Starting print: \(status)")
//        }
//    }
        let previousIndexpath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        var indexPaths : Array<IndexPath> = []
        if let previous = previousIndexpath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with: .automatic )
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! FileTableViewCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return FileTableViewCell.expandedHeight
        } else {
            return FileTableViewCell.defaultHeight
        }
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        (cell as! FileTableViewCell).ignoreFrameChanges()
//    }
}

class tempFile {
    let name : String
    let modDate : String
    let readDate : String
    let estTime : String
    
    init(name:String, modDate:String, readDate:String, estTime:String){
        self.name = name
        self.modDate = modDate
        self.readDate = readDate
        self.estTime = estTime
    }
}

class FileTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var modifiedLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var estTimeLabel: UILabel!
    @IBOutlet weak var labelsStack: UIStackView!
    @IBOutlet weak var printButton: UIButton!
    class var expandedHeight: CGFloat { get { return 165 } }
    class var defaultHeight: CGFloat { get {return 50 } }
    
    func checkHeight() {
        modifiedLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        readLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        estTimeLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        labelsStack.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        printButton.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        checkHeight()
    }
    
//    func ignoreFrameChanges() {
//        //do nothing
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
}
