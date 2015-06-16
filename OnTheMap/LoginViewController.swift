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
    @IBOutlet weak var signupLabel: UILabel!
    
    var origin: CGFloat!
    var newOrigin: CGFloat!
    
    /* Lifecycle */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set Text Field Delegate */
        email!.delegate = self
        password!.delegate = self
        
        /* original origin */
        origin = view.frame.origin.y
        
        /* Gradient color */
        self.configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Add Tap Gesture Recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
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

        // Set the origin back to original origin
        if view.frame.origin.y != origin {
            
            view.frame.origin.y = origin
        }
    }

    /* Actions */

    @IBAction func loginWithUdacityCredentials(sender: UIButton) {
        
        if email!.text.isEmpty || password!.text.isEmpty {
            
            self.debugLabel!.text = "You must enter username and password!"
            self.debugLabel!.backgroundColor = UIColor.redColor()
            
            self.view.endEditing(true)
            
            /* Fix the view */
            if self.view.frame.origin.y != origin {
                
                self.view.frame.origin.y = origin
            }
            
            return
        }
        
        Data.sharedInstance().username = email!.text!
        Data.sharedInstance().password = password!.text!
        
        UdacityClient.sharedInstance().authenticateWithUdacityCredentials { success, error in

            if success {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.completeLogin(sender)
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.displayError(error)
                }
            }
        }
    }
    
    func completeLogin(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.debugLabel!.text = "Login successful!"
            self.debugLabel!.backgroundColor = UIColor.greenColor()
            
            self.view.endEditing(true)
            
            /* Fix the view */
            if self.view.frame.origin.y != self.origin {
                
                self.view.frame.origin.y = self.origin
            }
            
            /* Segue to the Map and Table Tabbed View */
            self.performSegueWithIdentifier("TabbedViewSegue", sender: sender)
        }
    }
    
    func displayError(error: NSError?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if let error = error {
                
                self.debugLabel!.backgroundColor = UIColor.redColor()

                switch error.code {
                case 0:
                    self.debugLabel!.text = "Error. Check your Internet connection!"
                case 1:
                    self.debugLabel!.text = "Invalid username and/ or password!"
                default:
                    self.debugLabel!.text = "Error logging in!"
                }
                
                self.view.endEditing(true)
                
                /* Fix the view */
                if self.view.frame.origin.y != self.origin {
                    
                    self.view.frame.origin.y = self.origin
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

        if self.view.frame.origin.y == origin {

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
    
    func configureUI() {
        
        // color RGBs from http://www.rapidtables.com/web/color/RGB_Color.htm
        
        self.view.backgroundColor = UIColor.clearColor()
        
        // dark orange
        let darkOrange = UIColor(red: 255/255.0, green: 0.539, blue: 0.0, alpha: 1.0).CGColor

        // coral
        let coral = UIColor(red: 255/255.0, green: 0.498, blue: 0.278, alpha: 1.0).CGColor
        
        var backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [darkOrange, coral]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = self.view.frame
        
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // Orange red
        let orangeRed = UIColor(red: 255/255.0, green: 69/255.0, blue: 0/255.0, alpha: 1.0)

        // wheat
        let wheat = UIColor(red: 245/255.0, green: 222/255.0, blue: 179/255.0, alpha: 1.0)

        self.loginButton.backgroundColor = orangeRed
        self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        self.email!.textColor = orangeRed
        self.email!.backgroundColor = wheat
        
        self.password!.textColor = orangeRed
        self.password!.backgroundColor = wheat
        
        self.debugLabel!.textColor = UIColor.whiteColor()
        self.signupLabel!.textColor = UIColor.whiteColor()
    }
    
}

