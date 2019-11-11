//
//  SecondViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/11/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController
{
    // Properties
    var days = ["M": false, "Tu": false, "W": false, "Th": false, "F": false, "Sa": false, "Su": false]
    var goal = 0
    
    // Outlets
    @IBOutlet weak var pickXDaysLabel: UILabel!
    
    @IBOutlet weak var mondayButton: UIButton!
    
    @IBOutlet weak var tuesdayButton: UIButton!
    
    @IBOutlet weak var wednesdayButton: UIButton!
    
    @IBOutlet weak var thursdayButton: UIButton!
    
    @IBOutlet weak var fridayButton: UIButton!
    
    @IBOutlet weak var saturdayButton: UIButton!
    
    @IBOutlet weak var sundayButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    // Initialize button colors
    var dayButtonEnabledColor   = UIColor()
    var dayButtonDisabledColor  = UIColor()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set title for Nav Controller.
        self.title = "Select Days"
        
        // Update label to reflect user's picked goal
        pickXDaysLabel.text = "Pick \(goal) more days."
        
        // Get colors for button states, since we'll change the color of the buttons while leaving them enabled later in code.
        dayButtonEnabledColor = nextButton.titleColor(for: UIControl.State.normal)!
        dayButtonDisabledColor = nextButton.titleColor(for: UIControl.State.disabled)!
        
        // Set color of all days to disabled color to start
        mondayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        tuesdayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        wednesdayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        thursdayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        fridayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        saturdayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
        sundayButton.setTitleColor(dayButtonDisabledColor, for: .normal)
    }
    
    func countDays() -> Int
    {
        var count = 0
        for (_, dayIsEnabled) in days
        {
            if dayIsEnabled { count += 1 }
        }
        
        return count
    }
    
    @IBAction func dayWasToggled(_ sender: UIButton)
    {
        // Convert the button toggled into a String we can use with our days dictionary.
        var dayPicked = ""
        switch sender
        {
        case mondayButton:
            dayPicked = "M"
            
        case tuesdayButton:
            dayPicked = "Tu"
            
        case wednesdayButton:
            dayPicked = "W"
            
        case thursdayButton:
            dayPicked = "Th"
            
        case fridayButton:
            dayPicked = "F"
            
        case saturdayButton:
            dayPicked = "Sa"
            
        case sundayButton:
            dayPicked = "Su"
            
        default:
            break
            
        }
        
        // Toggle the day that was pressed in our data, fase to true, true to false.
        days[dayPicked] = !days[dayPicked]!
        
        // Set appropriate color for the button. Keep enabled so user can unpick if needed.
        if days[dayPicked]!
        {
            sender.setTitleColor(dayButtonEnabledColor, for: .normal)
        } else {
            sender.setTitleColor(dayButtonDisabledColor, for: .normal)
        }
        
        
        // Get count and calculate days left to pick
        let count = countDays()
        let daysLeft = goal - count
        
        // Change labels and enable or disable the next button to reflect the new number of days picked
        // User picked too many days
        if daysLeft < 0
        {
            // Disable next button
            nextButton.isEnabled = false
            
            // Update label to instruct user to unpick a specific amount of days
            pickXDaysLabel.text = "Unpick \(-1*daysLeft) days."
            
        }
        // User picked too few days
        else if daysLeft > 0
        {
            // Disable next button
            nextButton.isEnabled = false
            
            // Update label to instruct user to pick a specific amount of days more
            pickXDaysLabel.text = "Pick \(daysLeft) more days."
            
        }
        // User picked the perfect amount of days
        else
        {
            // Enable next button
            nextButton.isEnabled = true
            
            // Update label to tell the user it's all good!
            pickXDaysLabel.text = "Perfect. Let's go!"
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the goal the user picked from the previous View Controller.
        goal = (sender as! ViewController).goal
    }

}
