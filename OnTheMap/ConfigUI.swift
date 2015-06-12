//
//  ConfigUI.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/6/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class ConfigUI: NSObject, UIAlertViewDelegate {
    
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
        
        UdacityClient.sharedInstance().logOutFromUdacitySession { success, error in
            
            if success {
                
                self.targetView.dismissViewControllerAnimated(true, completion: nil)
                
            } else {

                println("error domain: \(error!.domain)")
                println("error code: \(error!.code)")
                println("error info: \(error!.userInfo![NSLocalizedDescriptionKey]!)")

                // Add interface to let the user retry
                var alertController: UIAlertController!
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error!.code == 0 {
                        
                        let title = "Network error!"
                        let message = "Error connecting to Udacity. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
                        
                    } else {
                        
                        let title = "Error connecting to Udacity!"
                        let message = "Please contact app administator!"
                        let actionTitle = "OK"
                        
                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
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
                
                println("error domain: \(error!.domain)")
                println("error code: \(error!.code)")
                println("error info: \(error!.userInfo![NSLocalizedDescriptionKey]!)")

                var alertController: UIAlertController!
                
                dispatch_async(dispatch_get_main_queue()) {

                    if error!.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Parse. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)

                    } else {
                        
                        let title = "Error connecting to Parse!"
                        let message = "Please contact app administator!"
                        let actionTitle = "OK"
                        
                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
    }
    
    func pin() {
        
        let userID = UdacityClient.sharedInstance().userID!
        UdacityClient.sharedInstance().getUserPublicData(userID) { userFirstName, userLastName, error in
            
            if let error = error {
            
                println("error domain: \(error.domain)")
                println("error code: \(error.code)")
                println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                
                // Add interface to let the user retry
                var alertController: UIAlertController!
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Udacity. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)

                    } else {
                        
                        let title = "Error connecting to Parse!"
                        let message = "Please contact app administator!"
                        let actionTitle = "OK"

                        self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
                    }
                }

            } else {
                
                /* Present the Information Posting View Controller modally */
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let informationPostingViewContorller = self.targetView.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                    
                    /* Set information posting view controller properties */
                    informationPostingViewContorller.userFirstName = userFirstName
                    informationPostingViewContorller.userLastName = userLastName
                    
                    self.targetView.presentViewController(informationPostingViewContorller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func configureAndPresentAlertController(title: String, message: String, actionTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        
        self.targetView.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Shared Instance */
    class func sharedInstance() -> ConfigUI {
        
        struct Singleton {
            
            static var sharedInstance = ConfigUI()
        }
        
        return Singleton.sharedInstance
    }
}
