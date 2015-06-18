//
//  Data.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/13/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import MapKit

class Data: NSObject {
    
    var username: String!
    var password: String!
    
    var userID: String!
    var userFirstName: String!
    var userLastName: String!
    var mapString: String!
    var mediaURL: String!
    var region: MKCoordinateRegion!
    
    var previousLocationsExist: Bool!
    var objectID: String!
    var foundObjectIDs: [String]!
    
    var studentsInformation: [Student]!
    
    var accessToken: String!
    
    class func sharedInstance() -> Data {
        
        struct Singleton {
            
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }
}
