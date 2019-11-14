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

        // See if the user gave permission to notify
        // if not, stay on this screen
        // if so, trigger the segue and go to the next screen
    }
    
    @IBAction func enableNotificationPermissions(_ sender: Any)
    {
        // Ask for permission
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: .alert)
            {
                (granted, error) in
                if granted
                {
                    // Note that the user gave permission
                    self.didGivePermissions = true
                    
                    // Enable the "Let's get started!" button
                    self.startButton.isEnabled = true
                }
            }
        if didGivePermissions
        {
            // Disable the "Enable Permissions" button
            self.permissionsButton.isEnabled = false
        }
    }

}
