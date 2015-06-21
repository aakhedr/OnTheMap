//
//  Data.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/13/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import MapKit

class Data: NSObject {
    
    // Set in loginWithUdacityCredentials (LoginViewController.swift)
    var username: String!
    var password: String!
    
    // Set in authenticateWithUdacityCredentials (UdacityConvenience.swift)
    var userID: String!     // checked
    
    // Set in getUserPublicData (UdacityConvenience.swift)
    var userFirstName: String!  // checked
    var userLastName: String!   // checked

    // Set in textFieldDidEndEditing (InformationPostingViewController.swift)
    var mapString: String!      // checked

    // Set in saveURL (WebViewController.swift) and textViewDidEndEditing InformationPostingViewController.swift)
    var mediaURL: String!       // checked
    
    // Set in findOnTheMapAction (InformationPostingViewController.swift)
    var region: MKCoordinateRegion!     // checked
    
    // Set in queryUserLocations (ParseConvenience.swift)
    var previousLocationsExist: Bool!
    
    // Set in postUserLocation (ParseConvenience.swift)
    var objectID: String!       // checked
    
    // Set in queryUserLocations (ParseConvenience.swift)
    var foundObjectIDs: [String]!   // checked
    
    // Set twice: 1) viewWillAppear (MapViewController.swift). 2) refresh [table views] (ConfigUI.swift).
    var studentsInformation: [Student]!     // checked
    
    // Set in loginButton (LoginViewController.swift)
    var accessToken: String!    // checked
    
    /* Shared Instance */
    class func sharedInstance() -> Data {
        
        struct Singleton {
            
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }
}
