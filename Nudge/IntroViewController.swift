//
//  IntroViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/13/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit

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
        // Set didGivePermissions to true
    }

}
