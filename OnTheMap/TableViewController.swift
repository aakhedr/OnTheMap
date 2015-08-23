//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var studentsTableView: UITableView!
    
    /* Lifecycle */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set the Table View Delegate and Data Source */
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        /* Set a human readible title for the view */
        title = "On The Map"
        
        /* reload table data (For refresh) */
        studentsTableView.reloadData()
    }
    
    /* Table View Data Source and Table View Delegate */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Data.sharedInstance().studentsInformation == nil {
            
            getStudentsLocations()
        }
        
        return Data.sharedInstance().studentsInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        /* Get the cell */
        let cellReuseIdentifier = "StudentCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        let student = Data.sharedInstance().studentsInformation[indexPath.row]
        
        /* Set the cell properties */
        cell.textLabel!.text = student.firstName + " " + student.lastName
        cell.imageView!.image = UIImage(named: "pin")

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = Data.sharedInstance().studentsInformation[indexPath.row]
        
        /* Open Safari at the media url of the selected student if valid */
        if ConfigUI.verifyURL(student.mediaURL) {
            
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)

        } else {
            
            let title = ""
            let message = "Sorry, This link cannot be opened."
            let actionTitle = "OK"
            
            ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }
    
    
    // So that app doesn't crash in case user taps this tab
    // before students are loaded in the mav view
    func getStudentsLocations() {
        
        ParseClient.sharedInstance().getStudentsLocations { error in
            
            if let error = error {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Parse. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                        
                    } else {
                        
                        let title = "Error!"
                        let message = "Error getting students information from Parse!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
    }

    /* Actions in ConfigUI.swift */
}
