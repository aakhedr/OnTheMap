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
    
    func taskForGETMethod(baseURLAndMethod: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // In parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURLAndMethod + ParseClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.addValue(Parameters.ParseApplicationID, forHTTPHeaderField: Parameters.ParseApplicationID_KEY)
        request.addValue(Parameters.RESTAPIKey, forHTTPHeaderField: Parameters.RESTAPIKey_KEY)
        
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
    
    func taskForPOSTMethod(baseURLAndMethod: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // No required parameters as per docs
        
        /* 2. The NSURL */
        let url = NSURL(string: baseURLAndMethod)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Parameters.ParseApplicationID, forHTTPHeaderField: Parameters.ParseApplicationID_KEY)
        request.addValue(Parameters.RESTAPIKey, forHTTPHeaderField: Parameters.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
                
            } else {
                
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(baseURLAndMethod: String, objectID: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // In parameters
        
        /* 2. Build the URL */
        let urlString = baseURLAndMethod + "/" + objectID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        var jsonifyError: NSError? = nil
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(Parameters.ParseApplicationID, forHTTPHeaderField: Parameters.ParseApplicationID_KEY)
        request.addValue(Parameters.RESTAPIKey, forHTTPHeaderField: Parameters.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* 5/6. Parse the data and use the data (happens in completion hander) */
            if let error = error {
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)

            } else {
                
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }

    func taskForDELETEMethod(baseURLAndMethod: String, objectID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        // In parameters
        
        /* 2. Build the URL */
        let urlString = baseURLAndMethod + "/" + objectID
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue(Parameters.ParseApplicationID, forHTTPHeaderField: Parameters.ParseApplicationID_KEY)
        request.addValue(Parameters.RESTAPIKey, forHTTPHeaderField: Parameters.RESTAPIKey_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* 5/6. Parse the data and use the data (happens in completion hander) */
            if let error = error {
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: error)
                
            } else {
                
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the task */
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}