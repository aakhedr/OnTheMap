//
//  ParseConvenience.swift
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
    
    func taskForGETMethod(urlString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // Added to the request below
        
        /* 2/3. The NSURL and configure the request */
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.addValue(ParseClient.Parameters.ParseApplicationID, forHTTPHeaderField: ParseClient.Parameters.ParseApplicationID_KEY)
        request.addValue(ParseClient.Parameters.RESTAPIKey, forHTTPHeaderField: ParseClient.Parameters.RESTAPIKey_Key)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler */
            if let error = downloadError {
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
            } else {
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
}
