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
        
        creatAt = dictionary[OTMClient.JSONResponseKeys.createdAt] as! String
        updateAt = dictionary[OTMClient.JSONResponseKeys.updatedAt] as! String
        firstName = dictionary[OTMClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.lastName] as! String
        latitude = dictionary[OTMClient.JSONResponseKeys.latitude] as! Double
        longitude = dictionary[OTMClient.JSONResponseKeys.longitude] as! Double
        mediaURL = dictionary[OTMClient.JSONResponseKeys.mediaURL] as! String
        mapString = dictionary[OTMClient.JSONResponseKeys.mapString] as! String
        objectId = dictionary[OTMClient.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.uniqueKey] as! String
        
    }
    
    static func personsFromResults(results: [[String : AnyObject]]) -> [OTMPerson] {
        
        var persons = [OTMPerson]()
        for result in results {
            persons.append(OTMPerson(dictionary: result))
        }
        
        return persons
    }
}
