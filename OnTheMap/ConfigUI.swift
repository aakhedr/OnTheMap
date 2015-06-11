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
                dispatch_async(dispatch_get_main_queue()) {
                    
                    var alertController: UIAlertController!
                    
                    if error!.code == 0 {
                        
                        alertController = UIAlertController(title: "Network error!", message: "Error connecting to Udacity. Check your Internet connection!", preferredStyle: UIAlertControllerStyle.Alert)

                    } else {
                        
                        alertController = UIAlertController(title: "Error connecting to Udacity!", message: "Please contact app administator!", preferredStyle: UIAlertControllerStyle.Alert)
                    }

                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        alertController.addAction(okAction)
                        
                    self.targetView.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func refresh() {
        
        ParseClient.sharedInstance().getStudentsLocations { students, error, errorString in
            
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
                
                println("error in refresh: \(error)")
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
                dispatch_async(dispatch_get_main_queue()) {
                    
                    var alertController: UIAlertController!
                    
                    if error.code == 0 {
                        
                        alertController = UIAlertController(title: "Network Error!", message: "Error connecting to Udacity. Check your Internet connection!", preferredStyle: UIAlertControllerStyle.Alert)

                    } else {
                        
                        alertController = UIAlertController(title: "Error connecting to Parse!", message: "Please contact app administator!", preferredStyle: UIAlertControllerStyle.Alert)
                    }

                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.targetView.presentViewController(alertController, animated: true, completion: nil)
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
    
    /* Shared Instance */
    class func sharedInstance() -> ConfigUI {
        
        struct Singleton {
            
            static var sharedInstance = ConfigUI()
        }
        
        return Singleton.sharedInstance
    }
}
