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
    
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        studentsMapView.delegate = self
        
        /* Show world map */
        let initialLocation = MKCoordinateRegionForMapRect(MKMapRectWorld)
        studentsMapView.region = initialLocation
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        ParseClient.sharedInstance().getStudentsLocations { students, error in
            if let students = students {
                self.students = students
                
                dispatch_async(dispatch_get_main_queue()) {

                    // Add Annotations here
                    let annotations = Annotation.annotationsFromStudents(self.students)
                    self.studentsMapView.addAnnotations(annotations)
                }
            } else {
                println("error: \(error)")
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Set a human readible title for the view */
        self.parentViewController!.title = "On The Map"
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
        
        /* Open Safari at the media url of the selected student */
        UIApplication.sharedApplication().openURL(NSURL(string: annotation.subtitle)!)
    }
}
