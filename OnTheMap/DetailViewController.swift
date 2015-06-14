//
//  DetailViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/14/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        /* Set a human readible title for the view */
        self.parentViewController!.title = "On The Map"
        
        /* reload table data (For refresh) */
        detailTableView.reloadData()
    }

    /* Table View Data Source and Table View Delegate */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Data.sharedInstance().studentsInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "DetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! CellDetailViewController
        let student = Data.sharedInstance().studentsInformation[indexPath.row]
        
        cell.studentFullName.text = student.firstName + " " + student.lastName
        cell.studentURL.text = student.mediaURL
        cell.studentLocationString.text = student.mapString
        
        // Modify this to include udacity or facebook image
        cell.studentImage.image = UIImage(named: "detail")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = Data.sharedInstance().studentsInformation[indexPath.row]
        
        if ConfigUI.verifyURL(student.mediaURL) {
            
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
            
        } else {
            
            let title = ""
            let message = "Sorry, This link cannot be opened."
            let actionTitle = "OK"
            
            ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }
    
    /* Actions in ConfigUI.swift */
}