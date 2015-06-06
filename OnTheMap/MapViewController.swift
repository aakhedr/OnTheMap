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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        studentsMapView.delegate = self
    }
    
    var students = [Student]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Set a human readible title for the view */
        self.parentViewController!.title = "On The Map"
        
        /* Show world map */
        let initialLocation = MKCoordinateRegionForMapRect(MKMapRectWorld)
        studentsMapView.region = initialLocation
        studentsMapView.delegate = self
        
        /* Configure naviagation bar buttons */
        ConfigUI.sharedInstance().configureNavBarButtons(self)
        
        ParseClient.sharedInstance().getStudentsLocations { students, error in
            if let students = students {
                self.students = students
//                dispatch_async(dispatch_get_main_queue()) {
//                    
//                    // Add Annotation here
//                    for student in self.students {
//                        self.studentsMapView.addAnnotation(student)
//                    }
//                }
            } else {
                println("error: \(error)")
            }
        }
    }


    


}
