//
//  Annotation.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/6/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D      // Required
    let title: String
    var subtitle: String?
    
    init(latitude: Double, longitude: Double, firstName: String, lastName: String, mediaURL: String?) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = firstName + " " + lastName

        if let mediaURL = mediaURL {
            self.subtitle = mediaURL
        } else {
            self.subtitle = nil
        }
        
        super.init()
    }
    
    /* Helper: Given an array of Student objects, convert them to an array of Annotation objects */
    class func annotationsFromStudents(students: [Student]) -> [Annotation] {
        var annotations = [Annotation]()
        
        for student in students {
            let annotation = Annotation(
                latitude: student.latitude,
                longitude: student.longitude,
                firstName: student.firstName,
                lastName: student.lastName,
                mediaURL: student.mediaURL
            )
            annotations.append(annotation)
        }
        
        return annotations
    }
}


