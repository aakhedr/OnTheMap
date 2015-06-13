//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var origin: CGFloat!
    var newOrigin: CGFloat!
    
    /* Lifecycle */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set Text Field Delegate */
        email!.delegate = self
        password!.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Add Tap Gesture Recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        /* original origin */
        origin = view.frame.origin.y
        newOrigin = nil     // Everytime the view appears newOrigin is nil. Then it gets set in the method getKeyboardHeight
    
        /* In case of logout from the tab bar view */
        self.email!.text = ""
        self.password!.text = ""
        self.debugLabel!.text = "Login to Udacity"
        self.debugLabel!.backgroundColor = self.view.backgroundColor
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    /* Dismiss keyboard on tap */
    func handleSingleTap(recognizer: UIGestureRecognizer) {
    
        view.endEditing(true)
    }

    /* Actions */

    @IBAction func loginWithUdacityCredentials(sender: UIButton) {
        if email!.text.isEmpty || password!.text.isEmpty {
            self.debugLabel!.text = "You must enter username and password!"
            self.debugLabel!.backgroundColor = UIColor.redColor()
            
            return
        }
        
        Data.sharedInstance().username = email!.text!
        Data.sharedInstance().password = password!.text!
        
        UdacityClient.sharedInstance().authenticateWithUdacityCredentials { success, error in
            if success {
                self.completeLogin(sender)
            } else {
                self.displayError(error)
            }
        }
    }
    
    func completeLogin(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.debugLabel!.text = "Login successful!"
            self.debugLabel!.backgroundColor = UIColor.greenColor()
            
            /* Segue to the Map and Table Tabbed View */
            self.performSegueWithIdentifier("TabbedViewSegue", sender: sender)
        }
    }
    
    func displayError(error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            if let error = error {
                println("error domain: \(error.domain)")
                println("error code: \(error.code)")
                println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                
                self.debugLabel!.backgroundColor = UIColor.redColor()

                switch error.code {
                case 0:
                    self.debugLabel!.text = "Error. Check your Internet connection!"
                case 1:
                    self.debugLabel!.text = "Invalid username and/ or password!"
                default:
                    self.debugLabel!.text = "Error logging in!"
                }
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
        if newOrigin == nil {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            
            newOrigin = keyboardSize.CGRectValue().height / 2.0
            
            return newOrigin
        }
        
        return 0
    }

    /* Text Field Delegate */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == password! {
            textField.resignFirstResponder()
            self.view.frame.origin.y = origin
            self.loginWithUdacityCredentials(loginButton)
        } else {
            password!.becomeFirstResponder()
        }
        
        return true
    }
    
    /* Tap Gesture Recognizer Delegate */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return email!.isFirstResponder() || password!.isFirstResponder()
    }
}

