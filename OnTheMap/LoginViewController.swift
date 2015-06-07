//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let textFieldDelegate = TextFieldDelegte()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        email!.delegate = textFieldDelegate
        password!.delegate = textFieldDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func loginWithUdacityCredentials(sender: UIButton) {
        if email!.text == "" || password!.text == "" {
            self.debugLabel!.text = "You must enter a username and password!"
            self.debugLabel!.backgroundColor = UIColor.redColor()
            return
        }
        UdacityClient.sharedInstance().authenticateWithUdacityCredentials(email!.text, password: password!.text) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            self.debugLabel!.text = "Logged in to Udacity"
            self.debugLabel!.backgroundColor = UIColor.greenColor()
            
            // Present the next view controller
            let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
            self.presentViewController(nextController, animated: true, completion: nil)
        }
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue()) {
            if let errorString = errorString {
                self.debugLabel!.text = errorString
                self.debugLabel!.backgroundColor = UIColor.redColor()
            }
        }
    }

    /* Keyboard notificatinos */
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        if email!.editing || password!.editing {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            
            return keyboardSize.CGRectValue().height
            
        } else {
            // Otherwise do not move view up (editing topTextField)
            return 0
        }
    }


}

