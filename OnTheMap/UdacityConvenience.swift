//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/3/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func authenticateWithUdacityCredentials(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {

        self.getUserID(email, password: password) {userID, error in
            
            if let userID = userID {
                
                self.userID = userID
                
                completionHandler(success: true, error: nil)
                
            } else {
                
                /* Pass the exact NSError from getUserID */
                completionHandler(success: false, error: NSError(domain: "getUserID", code: error!.code, userInfo: [NSLocalizedDescriptionKey: error!.userInfo![NSLocalizedDescriptionKey]!]))
            }
        }
    }

    func getUserID(email: String, password: String, completionHandler: (userID: String?, error: NSError?) -> Void) {
        
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
                
                completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))
                
            } else {

                if let statusCode = JSONResult.valueForKey(JSONResponseKeys.StatusCode) as? Int {
                    
                    if statusCode == 403 {
                        
                        let udacityErrorString = JSONResult.valueForKey(JSONResponseKeys.Error) as! String
                        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 1, userInfo: [NSLocalizedDescriptionKey: udacityErrorString]))
                    }
                
                } else {

                    if let account = JSONResult.valueForKey(JSONResponseKeys.Account) as? NSDictionary {
                        
                        if let userID = account.valueForKey(JSONResponseKeys.Key) as? String {
                            
                            completionHandler(userID: userID, error: nil)

                        } else {
                            
                            completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 3, userInfo: [NSLocalizedDescriptionKey: "could not parse userID as String"]))
                        }

                    } else {
                        
                        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 2, userInfo: [NSLocalizedDescriptionKey: " could not parse account dictinaory"]))
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
                
                completionHandler(firstName: nil, lastName: nil, errorString: "Network Error")
                
            } else {
                
                if let user = JSONResult.valueForKey(JSONResponseKeys.User) as? NSDictionary {
                    
                    if let userLastName = user.valueForKey(JSONResponseKeys.UserLastName) as? String {
                        
                        if let userFirstName = user.valueForKey(JSONResponseKeys.UserFirstName) as? String {
                            
                            completionHandler(firstName: userFirstName, lastName: userLastName, errorString: nil)
                        }
                    }
                }
            }
        }
    }
    
    func logOutFromUdacitySession(completionHandler: ((success: Bool, error: NSError?) -> Void)) {
        
        /* Specify the parameters */
        let method = Methods.Session
        
        /* 2. Make the request */
        let task = self.taskForDELETEMethod(method) { JSONResult, error in
            
            /* 3. Send the desited value(s) to completion handler */
            if let error = error {
                
                completionHandler(success: false, error: NSError(domain: "logOutFromUdacitySession", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

            } else {
                
                if let sessionDictioanry = JSONResult.valueForKey(JSONResponseKeys.Session) as? NSDictionary {
                    
                    if let id = sessionDictioanry.valueForKey(JSONResponseKeys.ID) as? String {
                        
                        completionHandler(success: true, error: nil)

                    } else {
                        
                        completionHandler(success: false, error: NSError(domain: "logoutFromUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse id string"]))
                    }

                } else {
                    
                    completionHandler(success: false, error: NSError(domain: "logoutFromUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey: "could not parse session dictinoary"]))
                }
            }
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity error", code: 0, userInfo: userInfo)
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

