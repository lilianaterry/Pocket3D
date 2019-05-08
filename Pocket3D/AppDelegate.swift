//
//  AppDelegate.swift
//  Pocket3D
//
//  Created by Chris Day on 2/26/19.
//  Copyright © 2019 Team 2. All rights reserved.
//

import CoreData
import IQKeyboardManagerSwift
import UIKit
import UserNotifications
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.bool(forKey: "hasLaunched") == false {
            // set up settings to sane defaults
            let usrDefault = UserDefaults.standard
            usrDefault.set(true, forKey: "hasLaunched")
            usrDefault.set(0, forKey: "fileSort")
            usrDefault.set(0, forKey: "posCoord")
            usrDefault.set(0, forKey: "extruderMin")
            usrDefault.set(250, forKey: "extruderMax")
            usrDefault.set(0, forKey: "bedMin")
            usrDefault.set(120, forKey: "bedMax")
            usrDefault.set(1.0, forKey: "mirrorX")
            usrDefault.set(1.0, forKey: "mirrorY")
            usrDefault.set([], forKey: "gcodeNames")
            usrDefault.set([], forKey: "gcodeCommands")
            UserDefaults.standard.set(true, forKey: "isDarkMode")
        }
// LMAOOOOO 
        INPreferences.requestSiriAuthorization { (status) in
            if (status == .authorized) {
                let intent = PrintStatusIntent()
                let interaction = INInteraction(intent: intent, response: nil)
                print("Intent donated")
                interaction.donate(completion: nil)
            }
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {
            (success, error) in
            if success {
                print("Yea")
            } else {
                print("O no")
            }
        })
        IQKeyboardManager.shared.enable = true
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        handleNotification()
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        handleNotification()
    }

    func applicationWillEnterForeground(_: UIApplication) {

        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.interaction == nil else {
            return false
        }
        return true // I guess?
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Pocket3D")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Code adapted from class demo snippets
    func handleNotification() {
        print("Attempting to make a notification")
        let notification = UNMutableNotificationContent()
        notification.title = "Your print job should be finished or near finished."
        notification.subtitle = "Based on estimated time - may not be accurate."
        notification.body = "Job: " + NotificationData.currentFileName
        notification.badge = 9001
        
        let time = NotificationData.currentTimeRemaining
        print(time)
        if (time > 0) {
            print("Time is valid")
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
            let request = UNNotificationRequest(identifier: "clickNotification",
                                                content: notification,
                                                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                print("Error",error as Any)
            }
        }

    }

}
