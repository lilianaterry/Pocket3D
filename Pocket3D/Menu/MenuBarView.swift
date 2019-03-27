//
//  MenuBarView.swift
//  Pocket3D
//
//  Created by Liliana Terry on 3/23/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

// allows login view controller to call same segue method
protocol SegueDelegate {
    func segue(identifier: String)
}

class MenuBarView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SegueDelegate {
    let ui = UIExtensions()

    let cellId = "menuCell"
    let screenNames = ["Status", "Controls", "Files", "Settings"]

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.purple
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        setup()
    }

    func setup() {
        backgroundColor = UIColor.purple
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        let leading = NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)

        let height = NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)

        addConstraint(leading)
        addConstraint(trailing)
        addConstraint(top)
        addConstraint(height)
    }

    // MARK: - CVMethods

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell

        cell.label.text = screenNames[indexPath.row]
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = screenNames[indexPath.item]
        segue(identifier: identifier)
    }

    // when a screen on the menu bar is selected, go to that view controller
    func segue(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // make sure to set storyboard id in storyboard for these VC
        let startingVC = storyboard.instantiateViewController(withIdentifier: identifier)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.viewControllers = [startingVC]
    }
}
