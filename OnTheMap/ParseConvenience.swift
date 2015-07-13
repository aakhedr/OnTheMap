//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudentsLocations(completionHandler: (error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            ParseClient.Parameters.Limit : 1000
        ]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.BaseURLAndMethod, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(error: NSError(domain: "getStudentsLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))
                
            } else {
                
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {

                    Data.sharedInstance().studentsInformation = Student.studentsFromResults(results)
                    completionHandler(error: nil)
                
                } else {
                    
                    completionHandler(error: NSError(domain: "getStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse results array"]))
                }
            }
        }
    }
    
    func postUserLocation(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the JSON body */
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!,
            JSONResponseKeys.FirstName: Data.sharedInstance().userFirstName,
            JSONResponseKeys.LastName: Data.sharedInstance().userLastName,
            JSONResponseKeys.MapString: Data.sharedInstance().mapString,
            JSONResponseKeys.MediaURL: Data.sharedInstance().mediaURL,
            JSONResponseKeys.Latitude: Data.sharedInstance().region.center.latitude,
            JSONResponseKeys.Longitude: Data.sharedInstance().region.center.longitude
        ]
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(Methods.BaseURLAndMethod, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(data: nil, error: NSError(domain: "postUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))
            
            } else {
                
                if let objectID = JSONResult.valueForKey(JSONResponseKeys.ObjectId) as? String {
                    
                    Data.sharedInstance().objectID = objectID
                    completionHandler(data: JSONResult, error: nil)
                
                } else {
                    
                    completionHandler(data: nil, error: NSError(domain: "postUserLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse object id as String"]))
                }
            }
        }
    }
    
    func updateUserLocations(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the parameters and the JSON body */
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!,
            JSONResponseKeys.FirstName: Data.sharedInstance().userFirstName,
            JSONResponseKeys.LastName: Data.sharedInstance().userLastName,
            JSONResponseKeys.MapString: Data.sharedInstance().mapString,
            JSONResponseKeys.MediaURL: Data.sharedInstance().mediaURL,
            JSONResponseKeys.Latitude: Data.sharedInstance().region.center.latitude,
            JSONResponseKeys.Longitude: Data.sharedInstance().region.center.longitude
        ]
        
        /* 2. Make the request (several request because I submitted many locations */
        for foundObjectID in Data.sharedInstance().foundObjectIDs {
            
            let task = self.taskForPUTMethod(Methods.BaseURLAndMethod, objectID: foundObjectID, jsonBody: jsonBody) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if let error = error {
                    
                    completionHandler(data: nil, error: NSError(domain: "updateUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

                } else {
                    
                    if let updatedAt = JSONResult.valueForKey(JSONResponseKeys.UpdatedAt)  as? String {
                        
                        completionHandler(data: JSONResult, error: nil)

                    } else {
                        
                        completionHandler(data: nil, error: NSError(domain: "updateUserLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse updated at as Strong"]))
                    }
                }
            }
        }
    }
    
    func queryUserLocations(completionHandler: (data: AnyObject!, success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let uniqueKey = NSUserDefaults.standardUserDefaults().stringForKey("UdacityUserID")!
        let parameters = [
            ParseClient.Parameters.Where: "{\"uniqueKey\":\"\(uniqueKey)\"}"
        ]
        
        /* 2. Make the request */
        let task = self.taskForGETMethod(ParseClient.Methods.BaseURLAndMethod, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(data: nil, success: false, error: NSError(domain: "queyUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

            } else {
                
                if let resultsArray = JSONResult.valueForKey(JSONResponseKeys.Results) as? NSArray {
                    
                    var foundObjectIDs = [String]()

                    for element in resultsArray {
                        
                        if let foundObjectID = element.valueForKey(JSONResponseKeys.ObjectId) as? String {
                            
                            foundObjectIDs.append(foundObjectID)
                        
                        } else {

                            completionHandler(data: nil, success: false, error: NSError(domain: "queryUserLocation", code: 2, userInfo: [NSLocalizedDescriptionKey: "could not parse 1 found object ID to String"]))
                        }
                    }

                    Data.sharedInstance().foundObjectIDs = foundObjectIDs

                    if foundObjectIDs.isEmpty {
                        
                        Data.sharedInstance().previousLocationsExist = false
                        completionHandler(data: nil, success: false, error: nil)
                        
                    } else {
                        
                        Data.sharedInstance().previousLocationsExist = true
                        completionHandler(data: JSONResult, success: true, error: nil)
                    }
                    
                } else {
                    
                    println(JSONResult)
                    completionHandler(data: nil, success: false, error: NSError(domain: "queyUserLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse results array"]))
                }
            }
        }
    }
    
    func userLocationsExist(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        ParseClient.sharedInstance().queryUserLocations { result, success, error in
            
            if let error = error {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                if success {
                    
                    completionHandler(success: true, error: nil)
                
                } else {
                    
                    completionHandler(success: false, error: nil)
                }
            }
        }
    }
    
    func deleteUserLocations(foundObjectIDs: [String], completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        for i in 0...foundObjectIDs.count - 1 {
            
            self.taskForDELETEMethod(Methods.BaseURLAndMethod, objectID: foundObjectIDs[i]) { result, error in
                
                if let error = error {
                    
                    completionHandler(success: false, error: NSError(domain: "deleteUserLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error"]))
                
                } else {
                    
                    completionHandler(success: true, error: nil)
                }
            }
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[ParseClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Parse Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)

        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            
            static var sharedInstance = ParseClient()
        }

        return Singleton.sharedInstance
    }

}
