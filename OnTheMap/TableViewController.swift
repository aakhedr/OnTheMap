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
        self.parentViewController!.title = "On The Map"
    }
    
    /* Table View Delegate and Table View Data Source */
    
    func tableView(tableView: UITableView, numberOfRowsInSection seciont: Int) -> Int {
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
        
        /* Open Safari at the media url of the selected student */
        if ((student.mediaURL.lowercaseString.rangeOfString("http") != nil) || (student.mediaURL.lowercaseString.rangeOfString("wwww") != nil)) {
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
        } else {
            let title = "No link here!"
            let message = "Sorry, this student did not share a link!"
            let actionTitle = "OK"
            
            ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }
}
