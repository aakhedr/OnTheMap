//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension ParseClient {
    
    /* Parameters */
    struct Parameters {
        
        static let ParseApplicationID =
            "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey =
            "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApplicationID_KEY =
            "X-Parse-Application-Id"
        static let RESTAPIKey_Key =
            "X-Parse-REST-API-Key"
        static let Limit = "limit"
    }
    
    /* Methods */
    struct Methods {
        
        static let BaseURLAndMethod =
            "https://api.parse.com/1/classes/StudentLocation"
    }
        
    /* JSON Resonse Keys */
    struct JSONResponseKeys {
        
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Code = "code"
        
        static let StatusMessage = "status_message"
        static let Results = "results"
        /*
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
        */
    }

}