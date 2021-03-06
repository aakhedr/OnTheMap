//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var studentsMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /* View lifecycle */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set Map View Delegate */
        studentsMapView.delegate = self
        
        /* Show world map initially */
        let initialLocation = MKCoordinateRegionForMapRect(MKMapRectWorld)
        studentsMapView.region = initialLocation
        
        /* Activity Indicator */
        activityIndicator!.hidesWhenStopped = true
        
        /* Load up Student objects from Parse */
        
        activityIndicator.startAnimating()
        view.alpha = 0.8
        
        ParseClient.sharedInstance().getStudentsLocations { error in
            
            if let error = error {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if error.code == 0 {
                        
                        let title = "Network Error!"
                        let message = "Error connecting to Parse. Check your Internet connection!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)

                    } else {
                        
                        let title = "Error!"
                        let message = "Error getting students information from Parse!"
                        let actionTitle = "OK"
                        
                        ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
                    }
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let annotations = Annotation.annotationsFromStudents(Data.sharedInstance().studentsInformation)
                    
                    // Remove existing (if any) and then add the new! ---- for Refresh()
                    if (self.studentsMapView.annotations != nil) {
                        
                        self.studentsMapView.removeAnnotations(self.studentsMapView.annotations)
                    }
                    
                    self.studentsMapView.addAnnotations(annotations)
                    
                    self.view.alpha = 1.0
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Set a human readible title for the view */
        title = "On The Map"
        
        navigationController?.tabBarItem.title = "Map"
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
    }
    
    /* Map View Delegate */

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let annotation = annotation as? Annotation {
            
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    
                    dequeuedView.annotation = annotation
                    view = dequeuedView

            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            
            return view
        }
        
        return nil
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let annotation = view.annotation as! Annotation
        
        /* Open Safari at the media url of the selected student if valid! */

        if ConfigUI.verifyURL(annotation.subtitle!) {
            UIApplication.sharedApplication().openURL(NSURL(string: annotation.subtitle!)!)

        } else {
            
            let title = ""
            let message = "Sorry, This link cannot be opened."
            let actionTitle = "OK"
            
            ConfigUI.configureAndPresentAlertController(self, title: title, message: message, actionTitle: actionTitle)
        }
    }
    
    /* Actions in ConfigUI.swift */
}
