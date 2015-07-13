//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var dontHaveAnAccountLabel: UILabel!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var origin: CGFloat!
    var newOrigin: CGFloat!
    var backgroundGradient = CAGradientLayer()
    
    /* Lifecycle */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set Text Field Delegate */
        email!.delegate = self
        password!.delegate = self
        
        /* original origin */
        origin = view.frame.origin.y
        
        /* Gradient color */
        configureUI()
        
        fbLoginButton.delegate = self
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
        email!.text = ""
        password!.text = ""
        debugLabel!.text = "Login to Udacity"
        debugLabel!.backgroundColor = self.view.backgroundColor
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Check if user is already logged in?
        if NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID") != nil {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.performSegueWithIdentifier("TabbedViewSegue", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    /* Background gradient color in case of lanscape orienation */
    override func viewDidLayoutSubviews() {
        
        backgroundGradient.frame = view.bounds
    }
    
    /* Dismiss keyboard on tap */
    func handleSingleTap(recognizer: UIGestureRecognizer) {
    
        view.endEditing(true)

        // Set the origin back to original origin
        if view.frame.origin.y != origin {
            
            view.frame.origin.y = origin
        }
    }
    
    /* FBSDKLoginButtonDelegate */

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let error = error {
            
            println("error code: \(error.code)")
            println("error domain: \(error.domain)")
            println("error description: \(error.localizedDescription)")
            
        
        // In case user taps cancel button 
        // (i.e. does not want to give permission to login via facebook)
        } else if result.isCancelled {
            
            self.viewWillAppear(true)
        
        } else {
            
            NSUserDefaults.standardUserDefaults().setObject(FBSDKAccessToken.currentAccessToken().tokenString! , forKey: "FBAccessToken")
            UdacityClient.sharedInstance().authenticateWithFacebook { success, error in
                
                if success {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.completeLogin()
                    }
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.displayError(error)
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        println("loginButtonDidLogOut is called!")
    }

    /* Actions */

    @IBAction func loginWithUdacityCredentials(sender: UIButton) {
        
        if email!.text.isEmpty || password!.text.isEmpty {
            
            debugLabel!.text = "You must enter username and password!"
            debugLabel!.backgroundColor = UIColor.redColor()
            
            self.view.endEditing(true)
            
            /* Fix the view */
            if view.frame.origin.y != origin {
                
                view.frame.origin.y = origin
            }
            
            return
        }
        
        Data.sharedInstance().username = email!.text!
        Data.sharedInstance().password = password!.text!
        
        UdacityClient.sharedInstance().authenticateWithUdacityCredentials { success, error in

            if success {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.completeLogin()
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.displayError(error)
                }
            }
        }
    }
    
    func completeLogin() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.debugLabel!.text = "Login successful!"
            self.debugLabel!.backgroundColor = UIColor.greenColor()
            
            self.view.endEditing(true)
            
            /* Fix the view */
            if self.view.frame.origin.y != self.origin {
                
                self.view.frame.origin.y = self.origin
            }
            
            /* Segue to the Map and Table Tabbed View */
            self.performSegueWithIdentifier("TabbedViewSegue", sender: self)
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
    
    @IBAction func signup(sender: UIButton) {
        
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(url)
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
        
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {

        if view.frame.origin.y == origin {

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
            view.frame.origin.y = origin
            loginWithUdacityCredentials(loginButton)

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
        
        view.backgroundColor = UIColor.clearColor()
        
        // dark orange
        let darkOrange = UIColor(red: 255/255.0, green: 0.539, blue: 0.0, alpha: 1.0).CGColor

        // coral
        let coral = UIColor(red: 255/255.0, green: 0.498, blue: 0.278, alpha: 1.0).CGColor
        
        backgroundGradient.colors = [darkOrange, coral]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = self.view.frame
        
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // Orange red
        let orangeRed = UIColor(red: 255/255.0, green: 69/255.0, blue: 0/255.0, alpha: 1.0)

        // wheat
        let wheat = UIColor(red: 245/255.0, green: 222/255.0, blue: 179/255.0, alpha: 1.0)

        loginButton.backgroundColor = orangeRed
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        email!.textColor = orangeRed
        email!.backgroundColor = wheat
        
        password!.textColor = orangeRed
        password!.backgroundColor = wheat
        
        debugLabel!.textColor = UIColor.whiteColor()
        signupButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        dontHaveAnAccountLabel!.textColor = UIColor.whiteColor()
    }
}

