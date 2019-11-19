//
//  IntroViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/13/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit
import UserNotifications

class IntroViewController: UIViewController {
    // Properties
    var didGivePermissions = false
    
    // Outlets
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var permissionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
