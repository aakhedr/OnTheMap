//
//  DetailViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/14/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var studentSearchBar: UISearchBar!
    
    var filteredStudents = [Student]()
    var isBeingSearched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        studentSearchBar.delegate = self
        
        let scopes = [
            "First Name",
            "Last Name",
            "Location"
        ]
        
        studentSearchBar.scopeButtonTitles = scopes
        
        if Data.sharedInstance().studentsInformation == nil {
            
            if Data.sharedInstance().studentsInformation == nil {
                
                ParseClient.sharedInstance().getStudentsLocations { students, error in
                    
                    if let students = students {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            Data.sharedInstance().studentsInformation = students
                        }
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if error!.code == 0 {
                                
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        /* Set a human readible title for the view */
        parentViewController!.title = "On The Map"
        
        /* reload table data (For refresh) */
        detailTableView.reloadData()

        studentSearchBar.showsScopeBar = false
}

    /* Table View Data Source and Table View Delegate */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isBeingSearched {
            
            return filteredStudents.count
        
        } else {
            
            return Data.sharedInstance().studentsInformation.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "DetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! CellDetailViewController
        
        var student: Student
        if isBeingSearched {

            student = filteredStudents[indexPath.row]
        
        } else {
            
            student = Data.sharedInstance().studentsInformation[indexPath.row]
        }
        
        cell.studentFullName.text = student.firstName + " " + student.lastName
        cell.studentURL.text = student.mediaURL
        cell.studentLocationString.text = student.mapString
        
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
    
    func filterContentForSearchText(searchText: String, scope: String = "First Name") {
        
        self.filteredStudents = Data.sharedInstance().studentsInformation.filter { student in

            var searchByString = ""
            switch scope {
                
                case "Last Name":
                    searchByString = student.lastName
                
                case "Location":
                    searchByString = student.mapString

                default:
                    searchByString = student.firstName

            }
            
            let stringMatch = searchByString.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            return stringMatch != nil
        }
    }
    
    /* Search Bar Delegate */

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        isBeingSearched = true

        let scopes = studentSearchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[studentSearchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchText, scope: selectedScope)
        detailTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        studentSearchBar.showsScopeBar = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        isBeingSearched = false
        studentSearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        isBeingSearched = false
        searchBar.resignFirstResponder()
        detailTableView.reloadData()
        studentSearchBar.showsScopeBar = false
    }

    /* Actions in ConfigUI.swift */
}