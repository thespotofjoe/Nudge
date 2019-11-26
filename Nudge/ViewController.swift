//
//  ViewController.swift
//  Nudge
//
//  Created by Joseph Buchoff on 11/6/19.
//  Copyright © 2019 The Spot of Joe. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController
{
    // Properties
    var goal = 1
    
    // Outlets
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Frequency"
        
        // Update the label in case we've loaded a previous goal
        number.text = "\(goal)"
    }
    
    // Mirror the stepper's value in the label
    //      to show the user
    @IBAction func valueChanged(_ sender: Any)
    {
        // Update goal with the new number.
        goal = Int(stepper!.value)
        
        // Update the label to show the user the current goal.
        number.text = "\(goal)"
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        
        // Delete previous Users and goals
        let userFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let otherUsers = try (managedContext.fetch(userFetchRequest))
            for user in otherUsers
            {
                managedContext.delete(user)
            }
        } catch {}
            
        // Add the new User/goal combo
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        let user = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        user.setValue(goal, forKeyPath: "goal")
          
        // Save CoreData with the new goal
        do
        {
            try managedContext.save()
            print("Saved the goal to CoreData.")
        } catch let error as NSError {
            print("Could not save the goal to CoreData. \(error), \(error.userInfo)")
        }
    }
    
    // Pass goal picked by user to SecondViewController when the user goes to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        if let nextView: SecondViewController = segue.destination as? SecondViewController
        {
            nextView.goal = goal
        }
    }
}

