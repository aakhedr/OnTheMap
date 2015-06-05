//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            
            // Present the next view controller here!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
