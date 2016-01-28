//
//  OTMPerson.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation

struct OTMPerson {
    
    var creatAt = ""
    var updateAt = ""
    var firstName = ""
    var lastName = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    
    init(dictionary: [String : AnyObject]){
        
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mediaURL = dictionary["mediaURL"] as! String
        mapString = dictionary["mapString"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
        
    }
    
    static func personsFromResults(results: [[String : AnyObject]]) -> [OTMPerson] {
        
        var persons = [OTMPerson]()
        for result in results {
            persons.append(OTMPerson(dictionary: result))
        }
        
        return persons
    }
}
