//
//  ConfigUI.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/6/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class ConfigUI: NSObject {
    
    var targetView: UIViewController!
    
    /* Add Buttons and actions */
    func configureNavBarButtons(viewController: UIViewController) {
        
        targetView = viewController
        
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "logout")
        
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Refresh,
            target: self,
            action: "refresh")
        
        let pinButton = UIBarButtonItem(
            image: UIImage(named: "pin"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "pin")
        
        viewController.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
        viewController.parentViewController!.navigationItem.rightBarButtonItems = [
            refreshButton,
            pinButton
        ]
    }
    
    /* Actions */
    
    func logout() {
        
        println("logout")
    }
    
    func refresh() {
        
        ParseClient.sharedInstance().getStudentsLocations { students, error in
            
            if let students = students {
                
                let newStudents = students
                if self.targetView is MapViewController {
                    
                    let mapViewController = self.targetView as! MapViewController
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        /* Update Annotations */
                        let annotations = Annotation.annotationsFromStudents(newStudents)
                        mapViewController.studentsMapView.addAnnotations(annotations)
                    }
                } else {

                    let tableViewController = self.targetView as! TableViewController
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        /* Reload table data */
                        tableViewController.students = newStudents
                        tableViewController.studentsTableView.reloadData()
                    }
                }
            } else {
                
                println("error: \(error)")
            }
        }
    }
    
    func pin() {
        
        let userID = UdacityClient.sharedInstance().userID!
        UdacityClient.sharedInstance().getUserPublicData(userID) { userFirstName, userLastName, error in
            
            if let error = error {
                
                println("error: \(error)")

            } else {
                
                ParseClient.sharedInstance().postUserLocation(userID, userFirstName: userFirstName!, userLastName: userLastName!) { data, error in

                    if let error = error {
                        
                        println("error: \(error)")

                    } else {
                        
                        println("location posted!")
                        
                        /* Present the Information Posting View Controller modally */
                        
                        let informationPostingViewContorller = self.targetView.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                        self.targetView.presentViewController(informationPostingViewContorller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /* Shared Instance */
    class func sharedInstance() -> ConfigUI {
        
        struct Singleton {
            
            static var sharedInstance = ConfigUI()
        }
        
        return Singleton.sharedInstance
    }
}
