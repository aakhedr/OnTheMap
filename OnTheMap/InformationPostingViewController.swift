//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/8/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nonEditableTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var userMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var verifyLinkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view and colors
        
        // gainsboro
        view.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        
        // royla blue
        locationTextField.backgroundColor = UIColor(red: 65/255.0, green: 105/255.0, blue: 225/255.0, alpha: 1.0)
        nonEditableTextView.textColor = UIColor(red: 65/255.0, green: 105/255.0, blue: 225/255.0, alpha: 1.0)
        findOnTheMapButton.setTitleColor(UIColor(red: 65/255.0, green: 105/255.0, blue: 225/255.0, alpha: 1.0), forState: UIControlState.Normal)
        
        /* Center text horizontally and vertically */
        nonEditableTextView.textAlignment = NSTextAlignment.Center
        nonEditableTextView.editable = false        // Initially
        
        /* Set the text field delegate */
        locationTextField.delegate = self
        
        /* Set the map view delegate */
        userMapView.delegate = self
        userMapView.hidden = true       // Initially
        verifyLinkButton.hidden = true  // Initially
        
        /* Add Tap Gesture Recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        /* Set text view delegate */
        nonEditableTextView.delegate = self
        
        /* Activity Indicator */
        activityIndicator.hidesWhenStopped = true
    }
    
    /* Actions */
    
    @IBAction func findOnTheMapAction(sender: UIButton) {
        
        if sender.currentTitle! == "Find on the map" {
            
            if locationTextField.text == "Enter your location here!" || locationTextField.text.isEmpty {
                
                let title = ""
                let message = "Enter your location in the form: City, (State), Country"
                let actionTitle = "OK"
                
                ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                
            } else if locationTextField.text != "Enter your location here!" && !locationTextField.text.isEmpty {
                
                appleMapsUserLocation()
            }
        }
    }
    
    func appleMapsUserLocation() {
        
        let geocoder = CLGeocoder()
        activityIndicator.startAnimating()
        
        geocoder.geocodeAddressString(locationTextField.text!) { placemarks, error in
            
            if let error = error {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Inform the user this location could not be found using Apple Maps
                    let title = "Unknown location to Apple Maps"
                    let message = "The location you entered is unkown to Apple Maps. Enter your location in the form: City, (State), Country"
                    let actionTitle = "OK"
                    
                    ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    self.activityIndicator.stopAnimating()
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.addUserLocation(placemarks)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func addUserLocation(placemarks: [AnyObject]) {
        
        let placemarks = placemarks as! [CLPlacemark]
        Data.sharedInstance().region = self.getTheRegion(placemarks)
        self.alterTheView()
        
        let annotation = Annotation(
            latitude: Data.sharedInstance().region.center.latitude,
            longitude: Data.sharedInstance().region.center.longitude,
            firstName: Data.sharedInstance().userFirstName!,
            lastName: Data.sharedInstance().userLastName!,
            mediaURL: nil)
        
        userMapView.setRegion(Data.sharedInstance().region, animated: true)
        userMapView.addAnnotation(annotation)
    }

    func getTheRegion(placemarks: [CLPlacemark]) -> MKCoordinateRegion? {
        
        var regions = [MKCoordinateRegion]()
        
        for placemark in placemarks {
            
            let coordinate: CLLocationCoordinate2D = placemark.location.coordinate
            let latitude: CLLocationDegrees = placemark.location.coordinate.latitude
            let longitude: CLLocationDegrees = placemark.location.coordinate.longitude
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            regions.append(MKCoordinateRegion(center: coordinate, span: span))
        }
        
        return regions.first
    }
    
    func alterTheView() {
        
        locationTextField.hidden = true
        userMapView.hidden = false
        nonEditableTextView.backgroundColor = UIColor(red: 65/255.0, green: 105/255.0, blue: 225/255.0, alpha: 1.0)
        findOnTheMapButton.setTitle("Submit", forState: UIControlState.Normal)
        
        nonEditableTextView.editable = true       // Enable user to type his/ her URL
        nonEditableTextView.textColor = UIColor.whiteColor()
        nonEditableTextView.text = "Enter a link and verify it!"
        verifyLinkButton.hidden = false
    }
    
    @IBAction func VerifyTheLink(sender: UIButton) {
        
        if ConfigUI.verifyURL(nonEditableTextView.text!) {
            
            Data.sharedInstance().mediaURL = nonEditableTextView.text
            
            let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
            
            /* Build the URL */
            let url = NSURL(string: Data.sharedInstance().mediaURL)!
            let request = NSURLRequest(URL: url)
            
            /* set the request */
            webViewController.request = request
            
            presentViewController(webViewController, animated: true, completion: nil)
            
        } else {
            
            let title = "Error!"
            let message = "Sorry, This link cannot be opened in Safari. Make sure it starts with 'http'"
            let actionTitle = "OK"
            
            ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }
    
    
    @IBAction func submit(sender: UIButton) {
        
        if sender.currentTitle! == "Submit" {
            
            if nonEditableTextView.text.isEmpty || nonEditableTextView.text == "Enter a link and verify it!" {
                
                let title = "Share a link!"
                let message = "You must share a link to submit your location."
                let actionTitle = "OK"
                
                ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
            
            } else if nonEditableTextView.text! != "Enter a link and verify it!" && !nonEditableTextView.text.isEmpty {
                
                Data.sharedInstance().mediaURL = nonEditableTextView.text
                if Data.sharedInstance().previousLocationsExist! {
                    
                    updateUserLocations()
                    
                } else {
                    
                    submitNewLoaction()
                }
            }
        }
    }

    func updateUserLocations() {
        
        ParseClient.sharedInstance().updateUserLocations { result, error in
            
            if let error = error {
                
                if error.code == 0 {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Parse. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    func submitNewLoaction() {
        
        ParseClient.sharedInstance().postUserLocation { result, error in
            
            if let error = error {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Parse. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Do something here to update Data.studentsInformation
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    @IBAction func cancel(sender: UIButton) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Dismiss keyboard in case of a tap! */
    func handleSingleTap(recognizer: UIGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    /* Text Field Delegate */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        textField.text = ""
        
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        
        Data.sharedInstance().mapString = textField.text!
    }
    
    /* Tap Gesture Recognizer Delegate */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        return locationTextField!.isFirstResponder() || nonEditableTextView.isFirstResponder()
    }
    
    /* Text View Delegate */
    
    // Dismisses the keyboard when done editing user media URL
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()

            return false
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        textView.text = ""
        
        return true
    }
}
