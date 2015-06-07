//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/4/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

extension UdacityClient {
    
    /*Constants */
    struct Constants {
        
        static let BaseURL = "https://www.udacity.com/"
    }
    
    /* Methods */
    struct Methods {
        
        static let session = "api/session"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    /* JSON Response Keys */
    struct JSONResponseKeys {
        
        static let Session = "session"
        static let ID = "id"
        static let StatusCode = "status"
        static let Error = "error"
        static let StatusMessage = "status_message"
    }
    
}
