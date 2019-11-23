//
//  NudgesViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/14/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit
import UserNotifications
import MessageUI

struct Nudge {
    var date:   DateComponents
    var requests:   [UNNotificationRequest]
    var completed:  Bool
}

class NudgesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate
{
    
    // Properties
    // An array to hold the steps taken each week
    var steps: [Int] = []
    
    // A Dictionary to hold which days the user picked
    var daysOfTheWeek: [Int] = []
    
    // An array to hold which times to nudge the user
    let hours = [9, 13, 17]
    
    // A counter of how many nudges per day we're adding
    var nudgesPerDay = 3
    
    // A variable to hold the user's end goal
    var goal: Int = 0
    
    // An array with the notification objects to hold every single Nudge
    var nudges: [Nudge] = []
    
    // Variables to hold the user's current Calendar and TimeZone objects
    let calendar = Calendar.current
    let timezone = TimeZone.current
    let today = Date()
    
    @IBAction func launchEmail(_ sender: Any)
    {
        let subject = "Nudge App Feedback"
        let body = "Feature request or bug report?"
        let to = ["joe@thespotofjoe.com"]
        let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        mailComposer.setToRecipients(to)

        self.present(mailComposer, animated: true, completion: nil)
    }

    func mailComposeController(_:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {

        self.presentedViewController!.dismiss(animated: true, completion: nil)
    }
    
    // UITableViewDelegate Methods
    // If the user swipes in on the right side of the cell, mark all the nudges for that day as completed
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        // Get the date for the nudge for this row
        let nudgeTrigger = nudges[indexPath.row].requests[0].trigger as! UNCalendarNotificationTrigger
        
        let nudgeDateTimeComponents = nudgeTrigger.dateComponents
        let nudgeDateTime = nudgeDateTimeComponents.date!
        
        // If the nudge is in the past or present, it's active. Allow it to be toggled.
        if !(today < nudgeDateTime)
        {
            let completeAction = UIContextualAction(style: .normal, title: "Complete")
            { (_: UIContextualAction, _ UIView, actionPerformed:(Bool) -> Void) in
                // Set this Nudge to completed
                self.nudges[indexPath.row].completed = true
            
                // Update the table
                tableView.reloadData()
            
                // Return true to indicate everything went as planned muahaha
                actionPerformed(true)
            }
            
            return UISwipeActionsConfiguration(actions: [completeAction])
        }
        
        // We got here which means the nudge is in the future.
        // Don't allow the user to toggle it.
        return nil
    }
    
    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checkSum()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Declare the cell here since we'll give it a value in if/else blocks
        var cell: UITableViewCell
        
        // Get the date for the nudge for this row
        let nudgeTrigger = nudges[indexPath.row].requests[0].trigger as! UNCalendarNotificationTrigger
        
        let nudgeDateTimeComponents = nudgeTrigger.dateComponents
        let nudgeDateTime = nudgeDateTimeComponents.date!
        
        // If the nudge is in the past or present, use an "active" cell
        if !(today < nudgeDateTime)
        {
            // If it's been completed, use an "activeNudgeCompleted" cell
            if nudges[indexPath.row].completed
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "activeNudgeCompleted", for: indexPath)
            } else {    // Otherwise use an "activeNudgeUncompleted" cell
                cell = tableView.dequeueReusableCell(withIdentifier: "activeNudgeUncompleted", for: indexPath)
            }
        } else {    // Nudge is in the future, use an "unactiveNudge" cell
            cell = tableView.dequeueReusableCell(withIdentifier: "unactiveNudge", for: indexPath)
        }
        
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
        let errorInRounding = numWeeks - steps.count
        for _ in 0..<errorInRounding
        {
            steps.insert(1, at: 0)
        }
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
                
                // Initialize variable to hold the date of the next Nudge
                var nextNudgeDate = DateComponents()
                
                // Set calendar and timezone to user's
                nextNudgeDate.calendar = self.calendar
                nextNudgeDate.timeZone = self.timezone
                
                // Add the appropriate date and time components to the variable
                nextNudgeDate.year = nextWeeksYear
                nextNudgeDate.weekOfYear = nextWeekOfTheYear
                nextNudgeDate.weekday = daysOfTheWeek[step]
                
                // Create the nudge
                var nudge = Nudge(date: nextNudgeDate, requests: [], completed: false)
                
                for hour in hours
                {
                    // Set the hour
                    nextNudgeDate.hour = hour
                    
                    // Iterate whichNudge
                    whichNudge = whichNudge + 1
                   
                    // Create the UNNotificationRequest
                    let request = UNNotificationRequest(identifier: "Nudge \(whichNudge)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: nextNudgeDate, repeats: false))
                    
                    // Append this request to the Nudge
                    nudge.requests.append(request)
                }
                
                // Append the Nudge to the array
                nudges.append(nudge)
            }
            
            // Advance the next week by 1
            nextWeekOfTheYear = nextWeekOfTheYear + 1
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Just in case we add/remove an hour in hours: [Int] without updating
        // nudgesPerDay, this line of code will update it for us
        nudgesPerDay = hours.count
        
        // Calculate the steps needed each week
        generateSteps(in: 3)
        
        print (steps)
        
        // Create the array of Nudges
        populateNudges()
        
        // Register all the notifications
        for nudge in nudges
        {
            let center = UNUserNotificationCenter.current()
            
            // Add all the requests in the Nudge's array of requests
            for index in 0 ..< nudgesPerDay
            {
                let thisRequest = nudge.requests[index]
                center.add(thisRequest) { (error : Error?) in
                    if error != nil
                    {
                        // If there's a no permissions error, display an alert to make the user give permissions
                    } else {
                        print ("Added notification for \((thisRequest.trigger as! UNCalendarNotificationTrigger).dateComponents.date!) successfully")
                    }
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
