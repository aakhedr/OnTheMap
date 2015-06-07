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

        self.getSessionID(email, password: password) { success, sessionID, errorString in
            if success {
                
                self.sessionID = sessionID
                completionHandler(success: success, errorString: errorString)
                
            } else {
                
                completionHandler(success: success, errorString: errorString)
            }
        }
    }

    func getSessionID(email: String, password: String, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters and JSON body for the post method */
        var parameters = [
            "email": email,
            "password": password
        ]
        
        let jsonBody =
        [
            UdacityClient.JSONBodyKeys.Udacity:
                [
                    UdacityClient.JSONBodyKeys.Username: "\(email)",
                    UdacityClient.JSONBodyKeys.Password: "\(password)"
                ]
        ]
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(UdacityClient.Methods.session, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in

            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                let networkErrorString = String(_cocoaString: error)
                completionHandler(success: false, sessionID: nil, errorString: networkErrorString)
                
            } else {

                if let statusCode = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusCode) as? Int {
                    
                    if statusCode == 403 {
                        
                        let udacityErrorString = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Error) as! String
                        completionHandler(success: false, sessionID: nil, errorString: udacityErrorString)
                    }
                
                } else {

                    if let session = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? NSDictionary {
                        
                        if let sessionID = session.valueForKey(UdacityClient.JSONResponseKeys.ID) as? String {
                            
                            completionHandler(success: true, sessionID: sessionID, errorString: nil)
                        }
                    }
                }
            }
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Udacity error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        /* Exclude the first 5 characters as per Udacity docs */
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

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

