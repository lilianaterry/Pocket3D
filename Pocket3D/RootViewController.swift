//
//  RootViewController.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {
    var pageViewController: UIPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageViewController!.delegate = self

        let startingViewController: DataViewController = modelController.viewControllerAtIndex(0, storyboard: storyboard!)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: { _ in })

        pageViewController!.dataSource = modelController

        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        pageViewController!.view.frame = pageViewRect

        pageViewController!.didMove(toParent: self)
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController?

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewController.SpineLocation.mid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: { _ in })

            pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = modelController.pageViewController(pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = modelController.pageViewController(pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: { _ in })

        return .mid
    }
}
