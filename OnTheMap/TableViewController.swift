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
    var students = [Student]()
    var userID: Int!
    
    /* Lifecycle */

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Set the Table View Delegate and Data Source */
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        
        /* Load up Student objects from Parse */
        ParseClient.sharedInstance().getStudentsLocations { students, error in
            if let students = students {
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                    
                    /* reload table view data */
                    self.studentsTableView!.reloadData()
                }
            } else {
                println("error: \(error)")
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        /* Set a human readible title for the view */
        self.parentViewController!.title = "On The Map"

    }
    
    /* Table View Delegate and Table View Data Source */
    
    func tableView(tableView: UITableView, numberOfRowsInSection seciont: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        /* Get the cell */
        let cellReuseIdentifier = "StudentCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        let student = students[indexPath.row]
        
        /* Set the cell properties */
        cell.textLabel!.text = student.firstName + " " + student.lastName
        cell.imageView!.image = UIImage(named: "pin")

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]

        /* Open Safari at the media url of the selected student */
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
    }


}
