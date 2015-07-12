//
//  ConfigUI.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/6/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ConfigUI: NSObject, UIAlertViewDelegate {
    
    var targetView: UIViewController!
    let loginManager = FBSDKLoginManager()
    
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
        
        let deleteButton = UIBarButtonItem(
            image: UIImage(named: "delete"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "delete")
        
        viewController.parentViewController!.navigationItem.leftBarButtonItems = [logoutButton, deleteButton]
        viewController.parentViewController!.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
    }
    
    /* Actions */
    
    func logout() {
        
        if NSUserDefaults.standardUserDefaults().stringForKey("FBAccessToken") != nil {
            
            loginManager.logOut()
            NSUserDefaults.standardUserDefaults().removeObjectForKey("FBAccessToken")
        }
        
        UdacityClient.sharedInstance().logOutFromUdacitySession { success, error in
            
            if success {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.targetView!.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("UdacityUserID")
                }
            
            } else {
                
                // Add interface to let the user know of the error
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error!.code == 0 {
                        
                        let title = "Network error!"
                        let message = "Error connecting to Udacity. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self.targetView, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
    }
    
    func refresh() {
        
        if targetView is MapViewController {
            
            targetView!.viewDidLoad()

        } else {
            
            ParseClient.sharedInstance().getStudentsLocations { students, error in

                if let students = students {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        Data.sharedInstance().studentsInformation = students
                        
                        /* Relaod the table data */
                        self.targetView!.viewWillAppear(true)
                    }
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if error!.code == 0 {
                            
                            let title = "Network Error!"
                            let message = "Error connecting to Parse. Check your Internet connection!"
                            let actionTitle = "OK"
                            
                            ConfigUI.configureAndPresentAlertController(self.targetView, title: title, message: message, actionTitle: actionTitle)
                        }
                    }
                }
            }
        }
    }
    
    func pin() {
        
        checkForPreviousLocations()
    }
    
    func checkForPreviousLocations() {
        
        ParseClient.sharedInstance().userLocationsExist { success, error in
            
            if success {
                
                // Present an alert
                let alertController = UIAlertController(
                    title: "",
                    message: "You have already posted either one or more locations. Would you like to overwrite the previous location(s)?",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                
                let overwriteButton = UIAlertAction(
                    title: "Overwrite",
                    style: UIAlertActionStyle.Default,
                    handler: { alert in

                        self.getUserPublicDataAndPresentInformationPostingViewController { error in
                        
                            if let error = error {
                                
                                println("error domain: \(error.domain)")
                                println("error code: \(error.code)")
                                println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")

                            } else {
                                
                                self.presentInformationPostingViewController()
                            }
                        }
                    }
                )
                
                let cancelButton = UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.Default,
                    handler: { alert in alertController.dismissViewControllerAnimated(true, completion: nil) }
                )
                
                alertController.addAction(overwriteButton)
                alertController.addAction(cancelButton)
                
                self.targetView.presentViewController(alertController, animated: true, completion: nil)
                
            } else if (!success && (error == nil)) {
                
                // Proceed to submit a new location
                self.getUserPublicDataAndPresentInformationPostingViewController { error in
                    
                    if let error = error {
                        println("error domain: \(error.domain)")
                        println("error code: \(error.code)")
                    }
                }
            
            } else if let error = error {
                
                println("error code: \(error.code)")
                println("error domain: \(error.domain)")
            }
        }
    }
    
    func getUserPublicDataAndPresentInformationPostingViewController(completionHandler: (error: NSError?) -> Void) {
        
        UdacityClient.sharedInstance().getUserPublicData { error in
            
            if let error = error {
                
                // Add interface to let the user retry
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Udacity. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self.targetView!, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            } else {
                
                self.presentInformationPostingViewController()
            }
        }
    }
    
    func presentInformationPostingViewController() {

        /* Present the Information Posting View Controller modally */
        dispatch_async(dispatch_get_main_queue()) {
            
            let informationPostingViewContorller = self.targetView.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            
            self.targetView!.presentViewController(informationPostingViewContorller, animated: true, completion: nil)
        }
    }
    
    func delete() {
        
        let title = "Delete?"
        let message = "Are you sure you want to delete all your previous locations?"

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let yesActionTitle = "Yes"
        let yesAction = UIAlertAction(
            title: yesActionTitle,
            style: UIAlertActionStyle.Default,
            handler: { alert in self.continueDelete() }
        )
        
        let cancelActionTitle = "Cancel"
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: UIAlertActionStyle.Default,
            handler: { alert in alertController.dismissViewControllerAnimated(true, completion: nil) }
        )
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        targetView!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func continueDelete() {
        
        ParseClient.sharedInstance().userLocationsExist { success, error in
            
            if let error = error {
                
                println("error domain: \(error.domain)")
                println("error code: \(error.code)")
            
            } else {
                
                if success {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        ParseClient.sharedInstance().deleteUserLocations(Data.sharedInstance().foundObjectIDs) { success, error in
                            
                            if let error = error {
                                
                                println("error domain: \(error.domain)")
                                println("error code: \(error.code)")
                            
                            } else {
                                
                                let title = ""
                                let message = "Previous location(s) deleted..."
                                let actionTitle = "OK"
                                
                                ConfigUI.configureAndPresentAlertController(self.targetView!, title: title, message: message, actionTitle: actionTitle)
                                
                                // And refresh
                                self.refresh()
                            }
                        }
                    }
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let title = ""
                        let message = "There are no previous locations stored to delete.\nPlease submit a location!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self.targetView!, title: title, message: message, actionTitle: actionTitle)
                    }
                }
            }
        }
    }
    
    class func configureAndPresentAlertController(viewController: UIViewController, title: String, message: String, actionTitle: String) {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let okAction = UIAlertAction(
            title: actionTitle,
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        
        alertController.addAction(okAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func verifyURL(urlString: String) -> Bool {
        
        if let url = NSURL(string: urlString) {
            
            if UIApplication.sharedApplication().canOpenURL(url) {
                
                return true
            }
        }
        
        return false
    }
    
    /* Shared Instance */
    class func sharedInstance() -> ConfigUI {
        
        struct Singleton {

            static var sharedInstance = ConfigUI()
        }
        
        return Singleton.sharedInstance
    }
}
