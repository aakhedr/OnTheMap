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
        
        /* Add and configure Tap Gesture Recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)

        /* Set Text Field Delegate */
        email!.delegate = self
        password!.delegate = self
        
        /* original origin */
        origin = view.frame.origin.y
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        /* In case of logout from the tabbed view */
        self.email!.text = ""
        self.password!.text = ""
        self.debugLabel!.text = "Login to Udacity"
        self.debugLabel!.backgroundColor = self.view.backgroundColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    /* Actions */

    @IBAction func loginWithUdacityCredentials(sender: UIButton) {
        
        if email!.text.isEmpty || password!.text.isEmpty {
        
            self.debugLabel!.text = "You must enter username and password!"
            self.debugLabel!.backgroundColor = UIColor.redColor()
            
            return
        }
        
        UdacityClient.sharedInstance().authenticateWithUdacityCredentials(email!.text, password: password!.text) { (success, errorString) in
        
            if success {
        
                self.completeLogin(sender)
            
            } else {
            
                self.displayError(errorString)
            }
        }
    }
    
    func completeLogin(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.debugLabel!.text = "Logged in to Udacity"
            self.debugLabel!.backgroundColor = UIColor.greenColor()
            
            /* Segue to the Map and Table Tabbed View */
            self.performSegueWithIdentifier("TabbedViewSegue", sender: sender)
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

    /* Dismiss keyboard in case of a tap */
    func handleSingleTap(recognizer: UIGestureRecognizer) {
        
        view.endEditing(true)
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

