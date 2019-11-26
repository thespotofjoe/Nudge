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
import CoreData

class NudgesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // An array to hold nudges, compatible with CoreData
    var nudges: [NSManagedObject] = []
    
    // An array to hold the notification requests
    var notificationRequests: [UNNotificationRequest] = []
    
    var managedContext: NSManagedObjectContext? = nil
    
    // Variables to hold the user's current Calendar and TimeZone objects
    let calendar = Calendar.current
    let timezone = TimeZone.current
    let today = Date()
    
    func getDateFromNudge(_ nudge: NSManagedObject) -> Date
    {
        // Get the date for the nudge for this row
        let nudgeYear = nudge.value(forKey: "year") as! Int
        let nudgeDayOfTheWeek = nudge.value(forKey: "dayOfTheWeek") as! Int
        let nudgeWeekOfTheYear = nudge.value(forKey: "weekOfTheYear") as! Int
         
        // Create a date from the components
        let nudgeDateTimeComponents = DateComponents(calendar: calendar, timeZone: timezone, year: nudgeYear, weekday: nudgeDayOfTheWeek, weekOfYear: nudgeWeekOfTheYear)
        return nudgeDateTimeComponents.date!
    }
    
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
    // If the user swipes in on the right side of the cell, mark that day as completed
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        // Get date from Nudge in the cell the user swiped on
        let nudgeDateTime = getDateFromNudge(nudges[indexPath.row])
        
        // If the nudge is in the past or present, it's active. Allow it to be toggled.
        if !(today < nudgeDateTime)
        {
            let completeAction = UIContextualAction(style: .normal, title: "Complete")
            { (_: UIContextualAction, _ UIView, actionPerformed:(Bool) -> Void) in
                // Set this Nudge to completed
                self.nudges[indexPath.row].setValue(true, forKey: "completed")
            
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
        
        print ("Adding nudge for \(indexPath.row)")
        // Get the date and weekday for the nudge for this row
        let thisNudge = nudges[indexPath.row]
        let nudgeWeekday = thisNudge.value(forKey: "dayOfTheWeek") as! Int
        print ("Weekday is \(nudgeWeekday)")
        let nudgeDateTime = getDateFromNudge(thisNudge)
        
        // If the nudge is in the past or present, use an "active" cell
        if !(today < nudgeDateTime)
        {
            // If it's been completed, use an "activeNudgeCompleted" cell
            if nudges[indexPath.row].value(forKey: "completed") as! Bool
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
        switch nudgeWeekday
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
    
    func createNudge (completed: Bool, dayOfTheWeek: Int, weekOfTheYear: Int, year: Int) -> NSManagedObject?
    {
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
      
        managedContext =
        appDelegate.persistentContainer.viewContext
      
        let entity =
        NSEntityDescription.entity(forEntityName: "Nudge",
                                   in: managedContext!)!
      
        let nudge = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
    
        nudge.setValue(completed, forKeyPath: "completed")
        nudge.setValue(dayOfTheWeek, forKeyPath: "dayOfTheWeek")
        nudge.setValue(weekOfTheYear, forKeyPath: "weekOfTheYear")
        nudge.setValue(year, forKeyPath: "year")
      
        // Save CoreData with the new Nudge
        do
        {
            try managedContext!.save()
            print("Saved a Nudge to CoreData.")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return nudge
    }
    
    // Populate days with Date objects for each day
    // we need to Nudge the user
    func populateNudges()
    {
        // If this is the first time loading the app, generate the nudges
        if nudges == []
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
                    let nudge = createNudge(completed: false, dayOfTheWeek: nextNudgeDate.weekday!, weekOfTheYear: nextNudgeDate.weekOfYear!, year: nextNudgeDate.year!)
                    
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
                        notificationRequests.append(request)
                    }
                    
                    // Append the Nudge to the array
                    nudges.append(nudge!)
                }
                
                // Advance the next week by 1
                nextWeekOfTheYear = nextWeekOfTheYear + 1
            }
        } else { // If there are stored nudges, load them instead
            var whichNudge = 0
            
            for loadedNudge in nudges
            {
                // Create content for a notification request
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Nudge nudge... Have you done your workout yet?", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "Build your athletic self! Mark it as completed now.", arguments: nil)
                
                // Initialize variable to hold the date of the loaded Nudge
                var nudgeDate = DateComponents()
                
                // Set calendar and timezone to user's
                nudgeDate.calendar = self.calendar
                nudgeDate.timeZone = self.timezone
                
                // Add the appropriate date and time components to the variable
                nudgeDate.year = loadedNudge.value(forKey: "year") as! Int
                nudgeDate.weekOfYear = loadedNudge.value(forKey: "weekOfTheYear") as! Int
                nudgeDate.weekday = loadedNudge.value(forKey: "dayOfTheWeek") as! Int
                
                let completed = loadedNudge.value(forKey: "completed") as! Bool
                
                for hour in hours
                {
                    // Set the hour
                    nudgeDate.hour = hour
                    
                    // Iterate whichNudge
                    whichNudge = whichNudge + 1
                   
                    // Create the UNNotificationRequest
                    let request = UNNotificationRequest(identifier: "Nudge \(whichNudge)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: nudgeDate, repeats: false))
                    
                    // Append this request to the Nudge
                    notificationRequests.append(request)
                }
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Load the stuff if there is any
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error assigning to appDelegate.")
            return
        }
        
        managedContext = appDelegate.persistentContainer.viewContext
          
        let nudgesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Nudge")
        let userFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            // See if there is saved data. If so, load it. If not, exit this function and continue with the program
            let testNudges = try (managedContext!.fetch(nudgesFetchRequest))
            if testNudges.count > 0
            {
                nudges = testNudges
                goal = try (managedContext!.fetch(userFetchRequest))[0].value(forKey: "goal") as! Int
                print("The goal is \(goal).")
                
                // Calculate the steps needed each week
                generateSteps(in: 3)
            } else {
                print("The user hasn't saved data yet")
                // User hasn't saved any data. Time to make it!
                // nudgesPerDay, this line of code will update it for us
                nudgesPerDay = hours.count
                
                // Calculate the steps needed each week
                generateSteps(in: 3)
                
                print (steps)
                
                // Create the array of Nudges
                populateNudges()
                
                // Add all the requests in the Nudge's array of requests
                let center = UNUserNotificationCenter.current()
                
                for thisRequest in notificationRequests
                {
                    center.add(thisRequest) { (error : Error?) in
                        if error != nil
                        {
                            // If there's a no permissions error, display an alert to make the user give permissions
                        } else {
                            print ("Added notification for \((thisRequest.trigger as! UNCalendarNotificationTrigger).dateComponents.date!) successfully")
                        }
                    }
                }
                print("Finished up notifications.")
            }
                
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
