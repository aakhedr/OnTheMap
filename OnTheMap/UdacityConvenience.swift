//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func authenticateWithUdacityCredentials(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {

        self.getUserID(email, password: password) {userID, errorString in
            if let userID = userID {
                
                self.userID = userID
                
                completionHandler(success: true, errorString: nil)
                
            } else {
                
                completionHandler(success: false, errorString: errorString)
            }
        }
    }

    func getUserID(email: String, password: String, completionHandler: (userID: String?, errorString: String?) -> Void) {
        
        /* 1. JSON body for the post method */
        // No parameters needed! Only the json body is needed according to the docs!
        
        let jsonBody =
        [
            UdacityClient.JSONBodyKeys.Udacity:
                [
                    UdacityClient.JSONBodyKeys.Username: "\(email)",
                    UdacityClient.JSONBodyKeys.Password: "\(password)"
                ]
        ]
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(UdacityClient.Methods.Session, jsonBody: jsonBody) { JSONResult, error in

            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                let networkErrorString = String(_cocoaString: error)
                completionHandler(userID: nil, errorString: networkErrorString)
                
            } else {

                if let statusCode = JSONResult.valueForKey(JSONResponseKeys.StatusCode) as? Int {
                    
                    if statusCode == 403 {
                        
                        let udacityErrorString = JSONResult.valueForKey(JSONResponseKeys.Error) as! String
                        completionHandler(userID: nil, errorString: udacityErrorString)
                    }
                
                } else {

                    if let account = JSONResult.valueForKey(JSONResponseKeys.Account) as? NSDictionary {
                        
                        if let userID = account.valueForKey(JSONResponseKeys.Key) as? String {
                            
                            completionHandler(userID: userID, errorString: nil)
                        }
                    }
                }
            }
        }
    }
    
    func getUserPublicData(userID: String, completionHandler: (firstName: String?, lastName: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters */
        // userID
        
        /* 2. Make the request */
        let task = self.taskForGETMethod(UdacityClient.Methods.PublicData, userID: userID) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                let networkErrorString = String(_cocoaString: error)
                completionHandler(firstName: nil, lastName: nil, errorString: networkErrorString)
                
            } else {
                
                if let user = JSONResult.valueForKey(JSONResponseKeys.User) as? NSDictionary {
                    
                    if let userLastName = user.valueForKey(JSONResponseKeys.UserLastName) as? String {
                        
                        if let userFirstName = user.valueForKey(JSONResponseKeys.UserFirstName) as? String {
                            
                            completionHandler(firstName: userFirstName, lastName: userLastName, errorString: nil)
                            
                            println(userFirstName + " " + userLastName)
                        }
                    }
                }
            }
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            println("parsed result \(parsedResult)")
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                println("error 3: \(error)")
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Udacity error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
        
        var parsingError: NSError? = nil
        
        /* Exclude the first 5 characters as per Udacity docs */
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        println(NSString(data: newData, encoding: NSUTF8StringEncoding))

        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            
            completionHandler(result: nil, error: error)

        } else {

            completionHandler(result: parsedResult, error: nil)
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
        
            static var sharedInstance = UdacityClient()
        }

        return Singleton.sharedInstance
    }
}

