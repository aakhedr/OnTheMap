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
    
    var locationString: String!
    var region: MKCoordinateRegion!
    var userFirstName: String!
    var userLastName: String!
    var annotation: Annotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Center text horizontally and vertically */
        nonEditableTextView.textAlignment = NSTextAlignment.Center
        nonEditableTextView.editable = false        // Initially
        
        /* Set the text field delegate */
        locationTextField.delegate = self
        
        /* Set the map view delegate */
        userMapView.delegate = self
        userMapView.hidden = true       // Initially
        
        /* Add Tap Gesture Recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        /* Set text view delegate */
        nonEditableTextView.delegate = self
    }
    
    func configureAndPresentAlertController(title: String, message: String, actionTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Actions */
    
    @IBAction func findOnTheMapAction(sender: UIButton) {
        
        if sender.currentTitle! == "Find on the map" {
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationString!) { placemarks, error in
                
                if let error = error {
                    
                    println("error domain: \(error.domain)")
                    println("error code: \(error.code)")
                    println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                    
                    /* Make an alert with the failiure reason */
                    var alertController: UIAlertController!
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if let errorReason = error.userInfo![NSLocalizedFailureReasonErrorKey] as? String {
                            
                            alertController = UIAlertController(title: "Network Error!", message: errorReason, preferredStyle: UIAlertControllerStyle.Alert)
                            
                        } else {
                            
                            alertController = UIAlertController(title: "Network Error!", message: "Could not find this location on the map!", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    let placemarks = placemarks as! [CLPlacemark]
                    self.region = self.getTheRegion(placemarks)
                    self.alterTheView()

                    self.annotation = Annotation(latitude: self.region.center.latitude, longitude: self.region.center.longitude, firstName: self.userFirstName, lastName: self.userLastName, mediaURL: nil)
                    self.userMapView.addAnnotation(self.annotation)
                }
            }
        }
    }
    
    @IBAction func submit(sender: UIButton) {
    
        if sender.currentTitle! == "Submit" && nonEditableTextView.text! != "Enter a link to share!" {
            
            let userID = UdacityClient.sharedInstance().userID!
            ParseClient.sharedInstance().userLocationsExist(userID) { success, error in
                
                if success {
                    
                    // Update all user locations on the map
                    self.updateUserLocations()
                    

                } else if (!success && (error == nil)) {
                    
                    // Submit a new location
                    self.submitNewLoaction()
                }
            }
            
        } else if sender.currentTitle! == "Submit" && nonEditableTextView.text! == "Enter a link to share!" {
            
            let title = "Share a link!"
            let message = "You must share a link t submit your location."
            let actionTitle = "OK"
            
            self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
        }
    }

    func updateUserLocations() {
        
        if let region = region {
            ParseClient.sharedInstance().updateUserLocations(UdacityClient.sharedInstance().userID!, userFirstName: userFirstName!, userLastName: userLastName!, mapString: locationString!, meidaURL: nonEditableTextView.text!, latitude: region.center.latitude, longitude: region.center.longitude) { result, error in
                
                if let error = error {
                    
                    println("error domain: \(error.domain)")
                    println("error code: \(error.code)")
                    println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")
                    
                } else {
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    func submitNewLoaction() {
        
        if let region = region {
        
            ParseClient.sharedInstance().postUserLocation(UdacityClient.sharedInstance().userID!, userFirstName: userFirstName!, userLastName: userLastName!, mapString: locationString, meidaURL: nonEditableTextView.text!, latitude: region.center.latitude, longitude: region.center.longitude) { result, error in
                
                if let error = error {
                    
                    println("error domain: \(error.domain)")
                    println("error code: \(error.code)")
                    println("error info: \(error.userInfo![NSLocalizedDescriptionKey]!)")

                    /* Make an alert with the failiure reason */
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if error.code == 0 {
                            
                            let title = "Network Error!"
                            let message = "Error connecting to Parse. Check your Internet connection!"
                            let actionTitle = "OK"
                            
                            self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)

                        } else {
                            
                            let title = "Unkown Error!"
                            let message = "Please contact app administator!"
                            let actionTitle = "OK"
                            
                            self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
                        }
                    }
                    
                } else {
                    
                    if let parsedData = result as? NSDictionary {
                        
                        if let code = parsedData.valueForKey(ParseClient.JSONResponseKeys.Code) as? Int {
                            
                            if code == 142 {
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    self.nonEditableTextView.text = "You must enter a link here!"
                                }
                            }
                            
                        } else {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.annotation.subtitle = self.nonEditableTextView.text!
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    }
                }
            }

        } else {
            
            println("Problem with getting the region (in submit)")
            
            let title = "Unkown Error!"
            let message = "Could not find this location on the map!"
            let actionTitle = "OK"
            
            self.configureAndPresentAlertController(title, message: message, actionTitle: actionTitle)
        }
    }

    @IBAction func cancel(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        userMapView.setRegion(regions[0], animated: true)
        
        return regions[0]
    }
    
    func alterTheView() {
        
        locationTextField.hidden = true
        userMapView.hidden = false
        nonEditableTextView.backgroundColor = UIColor.blueColor()
        findOnTheMapButton.setTitle("Submit", forState: UIControlState.Normal)
        
        nonEditableTextView.editable = true       // Enable user to type his/ her URL
        nonEditableTextView.textColor = UIColor.whiteColor()
        nonEditableTextView.text = "Enter a link to share!"
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        locationString = locationTextField!.text!
    }
    
    /* Tap Gesture Recognizer Delegate */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        return locationTextField!.isFirstResponder()
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
