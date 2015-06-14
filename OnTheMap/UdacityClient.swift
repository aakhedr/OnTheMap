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
    
    func taskForDELETEMethod(mehod: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // No parameters according to Udacity docs!
        
        /* 2. Build the URL */
        let urlString = Parameters.BaseURL + mehod
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
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

