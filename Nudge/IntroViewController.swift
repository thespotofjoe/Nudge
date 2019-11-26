//
//  IntroViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/13/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class IntroViewController: UIViewController {
    // Properties
    var didGivePermissions = false
    
    // Outlets
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var permissionsButton: UIButton!
    
    func isThereSavedData() -> Bool? {
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
    
        do {
            let users = try managedContext.fetch(fetchRequest)
            if users.count > 0
            {
                print("The goal is \(users[0].value(forKey: "goal")).")
                return true
            }
            
            print("The user didn't save any data yet.")
            return false
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for saved data. If there is, fastforward to nudge view
        if isThereSavedData()!
        {
            print("Switching to third view now.")
            self.performSegue(withIdentifier: "loadDataSegue", sender: self)
        }

        // Check for notification permissions
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: .alert)
        {
            (granted, error) in
            if granted
            {
                // Note that the user gave permission
                self.didGivePermissions = true
            }
        }
        
        if didGivePermissions
        {
            // Disable the "Enable Permissions" button
            self.permissionsButton.isEnabled = false
            
            // Enable the "Let's get started!" button
            self.startButton.isEnabled = true
        }
//        // See if the user gave permission to notify
//        // Check for notification permissions
//        let center = UNUserNotificationCenter.current()
//
//        center.getNotificationSettings
//        { (settings) in
//            if settings.authorizationStatus != .authorized {
//                // Notifications haven't been granted.
//                // Ask the user now.
//                center.requestAuthorization(options: .alert)
//                    {
//                        (granted, error) in
//                        if granted
//                        {
//                            // Note that the user gave permission
//                            self.didGivePermissions = true
//                        }
//                    }
//            } else {    // Notifications were already granted. Note this
//                self.didGivePermissions = true
//            }
//        }
//
//        if didGivePermissions
//        {
//            // Disable the "Enable Permissions" button
//            self.permissionsButton.isEnabled = false
//
//            // Enable the "Let's get started!" button
//            self.startButton.isEnabled = true
//        }
    }
    
    @IBAction func enableNotificationPermissions(_ sender: Any)
    {
        // Check for notification permissions
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: .alert)
        {
            (granted, error) in
            if granted
            {
                // Note that the user gave permission
                self.didGivePermissions = true
            }
        }
        
        if didGivePermissions
        {
            // Disable the "Enable Permissions" button
            self.permissionsButton.isEnabled = false
            
            // Enable the "Let's get started!" button
            self.startButton.isEnabled = true
        }
    }

}
