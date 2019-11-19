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
    // Dictionary for which days the user picked
    // I kept it as an Int instead of a String
    // to make further code easier
    var weekDays = [1 /* Sunday */: false,
                2 /* Monday */: false,
                3 /* Tuesday */: false,
                4 /* Wednesday */: false,
                5 /* Thursday */: false,
                6 /* Friday */: false,
                7 /* Saturday */: false]
    var goal: Int = 0
    
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
        for (_, dayIsEnabled) in weekDays
        {
            if dayIsEnabled { count += 1 }
        }
        
        return count
    }
    
    @IBAction func dayWasToggled(_ sender: UIButton)
    {
        // Convert the button toggled into an Int we can use with our days dictionary.
        var dayPicked: Int
        switch sender
        {
        case sundayButton:
            dayPicked = 1
            
        case mondayButton:
            dayPicked = 2
            
        case tuesdayButton:
            dayPicked = 3
            
        case wednesdayButton:
            dayPicked = 4
            
        case thursdayButton:
            dayPicked = 5
            
        case fridayButton:
            dayPicked = 6
            
        case saturdayButton:
            dayPicked = 7
            
        default:
            break
            
        }
        
        // Toggle the day that was pressed in our data, fase to true, true to false.
        weekDays[dayPicked] = !weekDays[dayPicked]!
        
        // Set appropriate color for the button. Keep enabled so user can unpick if needed.
        if weekDays[dayPicked]!
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
        
        if let nextView: NudgesViewController = segue.destination as? NudgesViewController
        {
            nextView.goal = goal
            
            // Populate daysOfTheWeek with just the days the user picked
            for (day, isEnabled) in weekDays
            {
                if isEnabled
                {
                    nextView.daysOfTheWeek.append(day)
                }
            }
        }
    }

}
