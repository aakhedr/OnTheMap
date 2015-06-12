//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudentsLocations(completionHandler: (result: [Student]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            ParseClient.Parameters.Limit : 1000
        ]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.BaseURLAndMethod, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(result: nil, error: NSError(domain: "getStudentsLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

            } else {

                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {

                    var students = Student.studentsFromResults(results)
                    completionHandler(result: students, error: nil)
                
                } else {
                
                    completionHandler(result: nil, error: NSError(domain: "getStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse results array"]))
                }
            }
        }
    }
    
    func postUserLocation(userID: String, userFirstName: String, userLastName: String, mapString: String, meidaURL: String, latitude: Double, longitude: Double,  completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the JSON body */
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: userID,
            JSONResponseKeys.FirstName: userFirstName,
            JSONResponseKeys.LastName: userLastName,
            JSONResponseKeys.MapString: mapString,
            JSONResponseKeys.MediaURL: meidaURL,
            JSONResponseKeys.Latitude: latitude,
            JSONResponseKeys.Longitude: longitude
        ]
        
        /* 2. Make the request */
        let task = self.taskForPOSTMethod(Methods.BaseURLAndMethod, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(data: nil, error: NSError(domain: "postUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

            } else {
                
                if let objectID = JSONResult.valueForKey(JSONResponseKeys.ObjectId) as? String {
                    
                    self.objectID = objectID
                    completionHandler(data: JSONResult, error: nil)

                } else {
                    
                    completionHandler(data: nil, error: NSError(domain: "postUserLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse object id as String"]))
                }
            }
        }
    }
    
    func updateUserLocation(userID: String, userFirstName: String, userLastName: String, mapString: String, meidaURL: String, latitude: Double, longitude: Double,  completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Specify the parameters and the JSON body */
        let parameters: [String : AnyObject] = [
            JSONResponseKeys.ObjectId: self.objectID
        ]
        
        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: userID,
            JSONResponseKeys.FirstName: userFirstName,
            JSONResponseKeys.LastName: userLastName,
            JSONResponseKeys.MapString: mapString,
            JSONResponseKeys.MediaURL: meidaURL,
            JSONResponseKeys.Latitude: latitude,
            JSONResponseKeys.Longitude: longitude
        ]
        
        /* 2. Make the request */
        let task = self.taskForPUTMethod(Methods.BaseURLAndMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(data: nil, error: NSError(domain: "updateUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))
                
            } else {
                
                if let objectID = JSONResult.valueForKey(JSONResponseKeys.ObjectId) as? String {
                    
                    completionHandler(data: JSONResult, error: nil)
                    
                } else {
                    
                    completionHandler(data: nil, error: NSError(domain: "updateUserLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse object id as String"]))
                }
            }
        }
    }
    
    func queryUserLocation(uniqueKey: String, completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let parameters = [
            "": ""
        ]
        
        /* 2. Make the request */
        let task = self.taskForGETMethod("https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22726279495%22%7D", parameters: parameters) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(data: nil, error: NSError(domain: "queyUserLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "network error"]))

            } else {
                
                if let resultsArray = JSONResult.valueForKey(JSONResponseKeys.Results) as? NSArray {
                    
                    for element in resultsArray {
                        
                        if let foundObjectID = element.valueForKey(JSONResponseKeys.UniqueKey) as? String {
                            
                            self.foundObjectID.append(foundObjectID)
                            completionHandler(data: JSONResult, error: nil)
                        
                        } else {
                            
                            completionHandler(data: nil, error: NSError(domain: "queryUserLocation", code: 2, userInfo: [NSLocalizedDescriptionKey: "could not parse found object ID to String"]))
                        }
                    }
                    
                } else {
                    
                    completionHandler(data: nil, error: NSError(domain: "queyUserLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse results array"]))
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
