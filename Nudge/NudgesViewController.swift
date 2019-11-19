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
    func generateSteps(to total: Int, in months: Int)
    {
        // The slope is the rate of growth of activities between one month and the last,
        //      calculated such that the total number of steps over the course of all weeks
        //      is equal to the total specified by the user
        let weeks = months * 4
        let slope: Double = 2.0*(Double(total)/Double(weeks)/Double(weeks))

        for week in 1...weeks
        {
            steps.append(Int(Double(week)*slope))
        }
        
        // The algorithm approximates the total desired by the user, but rounding errors prevent it
        //      from being 100% accurate. So this code corrects the difference by adding/subtracting
        //      the missing/extra steps needed to match the user's desired number of activities per month.
        let sum = checkSum()
        let difference = sum - total
        switch difference
        {
        case 0:                 // There is no rounding error, so let's return the step-growth-per-month array.
            break
       
        case Int.min..<0:       // Our algorithm under-calculated. We need to add steps.
            // Make the correction to our array of Int so the sum total of steps matches the user's desired total,
            //      adding from the end of the array towards the beginning
            for i in 0..<abs(difference)
            {
                steps[(weeks-i%weeks)-1] += 1
            }
        
        default:                // Our algorithm over-calculated. We need to subtract steps.
            // Make the correction to our array of Int so the sum total of steps matches the user's desired total,
            //      subtracting from the beginning of the array towards the end
            for i in 0..<abs(difference)
            {
                steps[i%weeks] -= 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checkSum()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Nudge", for: indexPath)
        
        let nudgeTrigger = nudges[indexPath.row].trigger as! UNCalendarNotificationTrigger
        
        let nudgeDateTime = nudgeTrigger.dateComponents
        
        // Set the cell's label's month
        var month = ""
        switch nudgeDateTime.month
        {
        case 1:
            month = "January"
        case 2:
            month = "February"
        case 3:
            month = "March"
        case 4:
            month = "April"
        case 5:
            month = "May"
        case 6:
            month = "June"
        case 7:
            month = "July"
        case 8:
            month = "August"
        case 9:
            month = "September"
        case 10:
            month = "October"
        case 11:
            month = "November"
        case 12:
            month = "December"
            
        default:
            break
        }
        
        // Set the cell's label's weekday
        var weekday = ""
        switch nudgeDateTime.weekday
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
        
        cell.textLabel?.text = "\(weekday), \(month) \(nudgeDateTime.day), \(nudgeDateTime.year)"
        
        return cell
    }
    
    // Populate days with Date objects for each day
    // we need to Nudge the user
    func populateNudges()
    {
        let date = Date()
        let calendar = Calendar.current
        let thisWeekOfTheYear = calendar.component(.weekOfYear, from: date)
        let thisYear = calendar.component(.year, from: date)
        var nextWeekOfTheYear = thisWeekOfTheYear + 1
        print ("thisYear: \(thisYear)")
        var nextWeeksYear = thisYear
        
        var whichNudge = 0
        
        // Iterate over the weeks
        for n in 1...12
        {
            print ("n: \(n)... nextWeekOfTheYear: \(nextWeekOfTheYear)")
            
            // If the next week is actually in the next year,
            // alter the variables appropriately
            if nextWeekOfTheYear > 52
            {
                print ("nextWeekOfTheYear: \(nextWeekOfTheYear) is over 52. Year: \(nextWeeksYear)")
                nextWeekOfTheYear = nextWeekOfTheYear % 52
                nextWeeksYear = nextWeeksYear + 1

                print ("Week has been corrected to: \(nextWeekOfTheYear).\nYear has been corrected to \(nextWeeksYear)")
            }
            
            // Iterate over each step prescribed for week n
            for step in 0..<steps[n-1]
            {
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Nudge nudge... Have you done your workout yet?", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "Build your athletic self! Mark it as completed now.", arguments: nil)
                
                for hour in hours
                {
                    // Initialize variable to hold the date/time of the next Nudge
                    var nextNudgeTime = DateComponents()
                    
                    // Add the appropriate date and time components to the variable
                    nextNudgeTime.year = nextWeeksYear
                    print ("Set year to \(nextWeeksYear)")  //debug
                    
                    nextNudgeTime.weekOfYear = nextWeekOfTheYear
                    print ("Set week to \(nextWeekOfTheYear)")  //debug
                    
                    nextNudgeTime.weekday = daysOfTheWeek[step]
                    print ("Set weekday to \(daysOfTheWeek[step])")  //debug
                    
                    nextNudgeTime.hour = hour
                    print ("Set hour to \(hour)")  //debug
                    
                    nextNudgeTime.calendar = Calendar.current
         
                    if nextNudgeTime.isValidDate
                    {
                        print ("Date checks out.")
                    } else {
                        print ("Date isn't valid.")
                    }
                    
                    print ("Appending nudge at \(nextNudgeTime.date)")  //Debug
                    
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
        generateSteps(to: goal, in: 3)
        
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
                    print ("Added notification for \((nudge.trigger as! UNCalendarNotificationTrigger).dateComponents.date) successfully")
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
