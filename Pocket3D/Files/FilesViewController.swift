//
//  FilesViewController.swift
//  Pocket3D
//
//  Created by Liliana Terry on 2/28/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import NVActivityIndicatorView
import SwiftyJSON
import UIKit

class FilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, FileCellDelegate {
    @IBOutlet var tableView: UITableView!

    let ui = UIExtensions()

    var selectedIndexPath: IndexPath?
    var frc: NSFetchedResultsController<File>!
    var moc: NSManagedObjectContext!

    lazy var printTimeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute]
        f.zeroFormattingBehavior = [.pad]
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ui.backgroundColor

        let loadingAnimation = setupLoadingAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged),
                                               name: NSNotification.Name(rawValue: "settings_changed"), object: nil)

        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        moc.mergePolicy = NSMergePolicy.overwrite
        reloadFrc()

        API.instance.files { [weak self] _, json in
            if let self = self {
                for f in json["files"].arrayValue {
                    if f["type"] == "folder" {
                        continue
                    }
                    let of = NSEntityDescription.insertNewObject(forEntityName: "File", into: self.moc) as! File
                    of.time = Int64(f["gcodeAnalysis"]["estimatedPrintTime"].intValue)
                    of.name = f["name"].stringValue
                    of.display = f["display"].stringValue
                    of.date = Date(timeIntervalSince1970: f["date"].doubleValue)
                    of.octoHash = f["hash"].stringValue
                    of.refs_resource = f["refs"]["resource"].stringValue
                }
                try! self.moc.save()
                loadingAnimation.stopAnimating()
            }
        }

        // this has to go after initialization of core data
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }

    // starts loading animation so that user knows files are on their way!
    func setupLoadingAnimation() -> NVActivityIndicatorView {
        let size = CGSize(width: view.bounds.width / 4, height: view.bounds.height / 4)
        let center = CGPoint(x: view.center.x - size.width / 2, y: view.center.y - size.height / 2)
        let frame = CGRect(origin: center, size: size)
        let loadingAnimation = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballScaleRippleMultiple, color: ui.bodyElementColor)

        view.addSubview(loadingAnimation)

        loadingAnimation.startAnimating()
        return loadingAnimation
    }
    
    @objc
    func settingsChanged() {
        reloadFrc()
    }
    
    func reloadFrc() {
        let req = NSFetchRequest<File>(entityName: "File")
        let sort = NSSortDescriptor(key: UserDefaults.standard.integer(forKey: "fileSort") == 0 ? "name" : "date", ascending: false)
        req.sortDescriptors = [sort]
        frc = NSFetchedResultsController(fetchRequest: req, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
            self.tableView.reloadData()
        } catch {
            fatalError("oops")
        }
    }

    func printPressed() {
        let file = frc.object(at: selectedIndexPath!)
        API.instance.printFile(file: URL(string: file.refs_resource!)!) { _ in
        }
    }

    // MARK: - UITableViewDelegate

    func numberOfSections(in _: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let res = frc!.sections!
        return res[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILE_CELL")! as! FileTableViewCell
        cell.delegate = self
        let file = frc.object(at: indexPath)

        cell.nameLabel.text = file.display
        cell.modifiedLabel.text = DateFormatter.localizedString(from: file.date!, dateStyle: .medium, timeStyle: .medium)
        cell.estTimeLabel.text = printTimeFormatter.string(from: Double(file.time))
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

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

protocol FileCellDelegate: class {
    func printPressed()
}

class FileTableViewCell: UITableViewCell {
    let ui = UIExtensions()

    @IBOutlet var expandedBackground: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var modifiedText: UILabel!
    @IBOutlet var modifiedLabel: UILabel!
    @IBOutlet var estText: UILabel!
    @IBOutlet var estTimeLabel: UILabel!
    @IBOutlet var printButton: UIButton!
    @IBOutlet var expandedView: UIStackView!

    weak var delegate: FileCellDelegate!

    class var expandedHeight: CGFloat { return 165 }
    class var defaultHeight: CGFloat { return 50 }

    override func awakeFromNib() {
        expandedBackground.backgroundColor = ui.headerBackgroundColor

        nameLabel.textColor = ui.filesExpandedColor
        modifiedLabel.textColor = ui.filesExpandedColor
        estTimeLabel.textColor = ui.filesExpandedColor

        modifiedText.textColor = ui.filesExpandedColor
        estText.textColor = ui.filesExpandedColor

        modifiedLabel.font = ui.fileExpandedFont
        estTimeLabel.font = ui.fileExpandedFont

        modifiedText.font = ui.fileExpandedFont
        estText.font = ui.fileExpandedFont
    }

    func checkHeight() {
        nameLabel.isHidden = false
        expandedBackground.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
        expandedView.isHidden = (frame.size.height < FileTableViewCell.expandedHeight)
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
