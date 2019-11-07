//
//  ViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/6/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Create outlets to
    //      1) change the counter to show the user and...
    //      2) access the stepper's .value attribute
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // Mirror the stepper's value in the label
    //      to show the user
    @IBAction func valueChanged(_ sender: Any)
    {
        // Convert the Double value to Int first to truncate the decimal
        //      then to String and assign to the label to show the user
        number.text = String(Int(stepper!.value))
    }
    
}

