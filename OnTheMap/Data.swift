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
    
    // Set in getUserPublicData (UdacityConvenience.swift)
    var userFirstName: String!  // checked
    var userLastName: String!   // checked

    // Set in textFieldDidEndEditing (InformationPostingViewController.swift)
    var mapString: String!      // checked

    // Set in submit InformationPostingViewController.swift)
    var mediaURL: String!       // checked
    
    // Set in findOnTheMapAction (InformationPostingViewController.swift)
    var region: MKCoordinateRegion!     // checked
    
    // Set in queryUserLocations (ParseConvenience.swift)
    var previousLocationsExist: Bool!
    
    // Set in postUserLocation (ParseConvenience.swift)
    var objectID: String!       // checked
    
    // Set in queryUserLocations (ParseConvenience.swift)
    var foundObjectIDs: [String]!   // checked
    
    // Set in getStudentsLocations (ParseConvience.swift)
    var studentsInformation: [Student]!     // checked
    
    /* Shared Instance */
    class func sharedInstance() -> Data {
        
        struct Singleton {
            
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }
}
