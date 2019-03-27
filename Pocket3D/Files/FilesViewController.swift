//
//  FilesViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import NVActivityIndicatorView
import SwiftyJSON
import UIKit

class FilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FileCellDelegate {
    @IBOutlet var tableView: UITableView!

    let ui = UIExtensions()
    @IBOutlet var menuBar: MenuBarView!

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

        let loadingAnimation = setupLoadingAnimation()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        tableView.backgroundColor = ui.backgroundColor
        let selectedIndex = IndexPath(item: 2, section: 0)
        menuBar.collectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: [])

        API.instance.files { [weak self] _, json in
            if let self = self {
                self.files = json["files"].arrayValue
                // TODO: check shared prefernces
                self.files.sort(by: { (a, b) -> Bool in
                    a["date"].int64Value > b["date"].int64Value
                })
                loadingAnimation.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }

    // starts loading animation so that user knows files are on their way!
    func setupLoadingAnimation() -> NVActivityIndicatorView {
        let size = CGSize(width: view.bounds.width / 4, height: view.bounds.height / 4)
        let center = CGPoint(x: view.center.x - size.width / 2, y: view.center.y - size.height / 2)
        let frame = CGRect(origin: center, size: size)
        let loadingAnimation = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballScaleRippleMultiple, color: ui.textColor)

        view.addSubview(loadingAnimation)

        loadingAnimation.startAnimating()
        return loadingAnimation
    }

    func printPressed() {
        API.instance.printFile(file: URL(string: files[self.selectedIndexPath!.row]["refs"]["resource"].stringValue)!) { status in
            print("Starting print: \(status)")
        }
    }

    // MARK: - UITableView

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? files.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILE_CELL")! as! FileTableViewCell
        cell.delegate = self
        cell.nameLabel.text = files[indexPath.row]["name"].stringValue
        cell.modifiedLabel.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: files[indexPath.row]["date"].doubleValue), dateStyle: .medium, timeStyle: .medium)
        cell.estTimeLabel.text = printTimeFormatter.string(from:
            files[indexPath.row]["gcodeAnalysis"]["estimatedPrintTime"].doubleValue)
        cell.modifiedLabel.sizeToFit()
        cell.estTimeLabel.sizeToFit()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexpath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        var indexPaths: [IndexPath] = []
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

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        (cell as! FileTableViewCell).watchFrameChanges()
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return FileTableViewCell.expandedHeight
        } else {
            return FileTableViewCell.defaultHeight
        }
    }
}

protocol FileCellDelegate: class {
    func printPressed()
}

class FileTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var modifiedLabel: UILabel!
    @IBOutlet var estTimeLabel: UILabel!
    @IBOutlet var printButton: UIButton!
    @IBOutlet var expandedView: UIStackView!

    weak var delegate: FileCellDelegate!

    class var expandedHeight: CGFloat { return 165 }
    class var defaultHeight: CGFloat { return 50 }

    func checkHeight() {
        nameLabel.isHidden = false
        expandedView.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)

//        self.modifiedLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
//        self.estTimeLabel.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
//        self.printButton.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
//        print(self.modifiedLabel.isHidden)
//        print(self.estTimeLabel.isHidden)
//        print(self.printButton.isHidden)
    }

    func watchFrameChanges() {
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        checkHeight()
    }

    @IBAction func printButtonPressed(_: Any) {
        delegate.printPressed()
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
}
