//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/4/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

extension UdacityClient {
    
    /*Constants */
    struct Parameters {
        
        static let BaseURL = "https://www.udacity.com/"
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    /* Methods */
    struct Methods {
        
        static let Session = "api/session"
        static let PublicData = "api/users/"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    /* JSON Response Keys */
    struct JSONResponseKeys {
        
        static let Account = "account"
        static let Key = "key"
        static let StatusCode = "status"
        static let Error = "error"
        static let User = "user"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        static let Session = "session"
        static let ID = "id"
        
        static let StatusMessage = "status_message"
    }
    
}
