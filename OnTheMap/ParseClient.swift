//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        
        super.init()
    }
    
    func getStudentsLocations(completionHandler: (result: [Student]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        // One set of parameters
        
        /* 2. Make the request */
        taskForGETMethod(Methods.BaseURLAndMethod) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {

                    var students = Student.studentsFromResults(results)
                    
                    completionHandler(result: students, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentsLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentsLocations"]))
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
