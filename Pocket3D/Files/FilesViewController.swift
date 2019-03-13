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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        API.instance.files { [unowned self] _, json in
            self.files = json["files"].arrayValue
            print("Got files array of \(self.files.count) from json object")
            // TODO: check shared prefernces
            self.files.sort(by: { (a, b) -> Bool in
                a["date"].int64Value > b["date"].int64Value
            })
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.files.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILE_CELL")! as! FileTableViewCell
        cell.nameLabel.text = files[indexPath.row]["name"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        API.instance.printFile(file: URL(string: self.files[indexPath.row]["refs"]["resource"].stringValue)!) { status in
            print("Starting print: \(status)")
        }
    }
}

class FileTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}
