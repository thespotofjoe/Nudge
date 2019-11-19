//
//  NudgesViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/14/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit
import UserNotifications

class NudgesViewController: UIViewController, UITableViewDataSource {
    
    // Properties
    // An array to hold the steps taken each week
    var steps: [Int] = []
    
    // A Dictionary to hold which days the user picked
    var daysOfTheWeek: [Int] = []
    
    // An array to hold which times to nudge the user
    let hours = [9, 13, 17]
    
    // A variable to hold the user's end goal
    var goal: Int = 0
    
    // An array with the notification objects to hold every single Nudge
    var nudges: [UNNotificationRequest] = []
    
    let calendar = Calendar.current
    let timezone = TimeZone.current
    
    // A function that checks the sum of all the weeks so we can correct for rounding differences
    func checkSum() -> Int
    {
        var sum = 0
        
        for week in steps
        {
            sum += week
        }
        
        return sum
    }
    
    // A function that generates and returns the total amount of nudges each week towards the end goal
    func generateSteps(in months: Int)
    {
        // Calculate total number of weeks
        let numWeeks = months * 4
        
        // Calculate the number of weeks to stay at each step
        let weeksAtStep = numWeeks / goal
        
        
        // Create the array
        for numSteps in 1...goal
        {
            for _ in 1...weeksAtStep
            {
                steps.append(numSteps)
            }
        }
        
        // Due to int rounding errors, expand the weeks as necessary
        var errorInRounding = numWeeks - steps.count
        for _ in 0..<errorInRounding
        {
            steps.insert(1, at: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checkSum()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Nudge", for: indexPath)
        let cell = UITableViewCell()
        
        let nudgeTrigger = nudges[indexPath.row*3].trigger as! UNCalendarNotificationTrigger
        
        let nudgeDateTimeComponents = nudgeTrigger.dateComponents
        let nudgeDateTime = nudgeDateTimeComponents.date!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = dateFormatter.string(from: nudgeDateTime)
        
        // Set the cell's label's weekday
        var weekday = ""
        switch nudgeDateTimeComponents.weekday
        {
        case 1:
            weekday = "Sunday"
        case 2:
            weekday = "Monday"
        case 3:
            weekday = "Tuesday"
        case 4:
            weekday = "Wednesday"
        case 5:
            weekday = "Thursday"
        case 6:
            weekday = "Friday"
        case 7:
            weekday = "Saturday"

        default:
            break
        }
        
        cell.textLabel?.text = "\(weekday), \(dateString)"
        return cell
    }
    
    // Populate days with Date objects for each day
    // we need to Nudge the user
    func populateNudges()
    {
        // Get date and extract current week and year
        let date = Date()
        let thisWeekOfTheYear = calendar.component(.weekOfYear, from: date)
        let thisYear = calendar.component(.year, from: date)
        
        // Set next week's year and week
        var nextWeekOfTheYear = thisWeekOfTheYear + 1
        var nextWeeksYear = thisYear
        
        // Create an iterator for whichNudge we're creating
        var whichNudge = 0
        
        // Iterate over the weeks
        for n in 1...12
        {
            // If the next week is actually in the next year,
            // alter the variables appropriately
            if nextWeekOfTheYear > 52
            {
                nextWeekOfTheYear = nextWeekOfTheYear % 52
                nextWeeksYear = nextWeeksYear + 1
            }
            
            // Iterate over each step prescribed for that week
            for step in 0..<steps[n-1]
            {
                // Create content for a notification request
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Nudge nudge... Have you done your workout yet?", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "Build your athletic self! Mark it as completed now.", arguments: nil)
                
                for hour in hours
                {
                    // Initialize variable to hold the date/time of the next Nudge
                    var nextNudgeTime = DateComponents()
                    
                    // Set calendar and timezone to user's
                    nextNudgeTime.calendar = self.calendar
                    nextNudgeTime.timeZone = self.timezone
                    
                    // Add the appropriate date and time components to the variable
                    nextNudgeTime.year = nextWeeksYear
                    nextNudgeTime.weekOfYear = nextWeekOfTheYear
                    nextNudgeTime.weekday = daysOfTheWeek[step]
                    nextNudgeTime.hour = hour
                    
                    // Iterate whichNudge
                    whichNudge = whichNudge + 1
                   
                    // Create and append the notification trigger
                    // with the appropriate date to the array
                    nudges.append(UNNotificationRequest(identifier: "Nudge \(whichNudge)",
                        content: content,
                        trigger: UNCalendarNotificationTrigger(dateMatching: nextNudgeTime, repeats: false)))
                }
            }
            
            // Advance the next week by 1
            nextWeekOfTheYear = nextWeekOfTheYear + 1
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Calculate the steps needed each week
        generateSteps(in: 3)
        
        print (steps)
        
        // Create the array of Nudges
        populateNudges()
        
        // Register all the notifications
        for nudge in nudges
        {
            let center = UNUserNotificationCenter.current()
            
            center.add(nudge) { (error : Error?) in
                if let theError = error
                {
                    // If there's a no permissions error, display an alert to make the user give permissions
                } else {
                    print ("Added notification for \((nudge.trigger as! UNCalendarNotificationTrigger).dateComponents.date!) successfully")
                }
            }
        }
        
        
        
        // Populate the table with all the nudges, making only the nudges through the current date enabled to check off
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
