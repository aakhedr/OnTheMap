//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/4/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    var session: NSURLSession
    
    var userID: String? = nil
    var userFirstName: String? = nil
    var userLastName: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        
        super.init()
    }    
    
    func taskForPOSTMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Already set in jsonBody 

        /* 2. Build the URL */
        let urlString = Parameters.BaseURL + method
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                print("error 1 in taskForPOSTMethod UdacityClient: \(error)")
                
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                
                println("error 2 in taskForPOSTMethod UdacityClient: \(newError)")
                
                completionHandler(result: nil, error: newError)
                
            } else {
                                
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(method: String, userID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // userID
        
        /* 2. Build the URL */
        let urlString = Parameters.BaseURL + method + userID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
                
            } else {
                
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
}

