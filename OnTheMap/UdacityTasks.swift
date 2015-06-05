//
//  UdacityTasks.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/4/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Already set in parameters 

        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.BaseURL + method
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
                
                println("new error: \(newError)")

                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
}

