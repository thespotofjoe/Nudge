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
    // Properties
    var goal = 0
    
    // Outlets
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Frequency"
    }
    
    // Mirror the stepper's value in the label
    //      to show the user
    @IBAction func valueChanged(_ sender: Any)
    {
        // Update goal with the new number.
        goal = Int(stepper!.value)
        
        // Update the label to show the user the current goal.
        number.text = "\(goal)"
    }
    
    // Pass goal picked by user to SecondViewController when the user goes to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextView: SecondViewController = segue.destination as? SecondViewController
        {
            nextView.goal = goal
        }
    }
}

