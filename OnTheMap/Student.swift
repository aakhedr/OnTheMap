//
//  Student.swift
//  OnTheMap
//
//  Created by Ahmed Khedr on 6/5/15.
//  Copyright (c) 2015 Ahmed Khedr. All rights reserved.
//

struct Student {
    
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        firstName = (dictionary[ParseClient.JSONResponseKeys.FirstName] as! String)
        lastName = (dictionary[ParseClient.JSONResponseKeys.LastName] as! String)
        mapString = (dictionary[ParseClient.JSONResponseKeys.MapString] as! String)
        mediaURL = (dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String)
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
    }

    /* Helper: Given an array of dictionaries, convert them to an array of Student objects */
    static func studentsFromResults(results: [[String : AnyObject]]) -> [Student] {
        var students = [Student]()
        
        for result in results {
            students.append(Student(dictionary: result))
        }
    return students
    }
}
