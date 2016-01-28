//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    
    struct Constants {
        
        static let UdacityFacebookID: String = "365362206864879"
        static let UdacityFacebookURLSchemeSuffix: String = "onthemap"
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    }
    
    
    struct Methods {
        
        static let UdacitySession = "https://www.udacity.com/api/session"
        static let UdacityGetUserData = "https://www.udacity.com/api/users/<user_id>"
        static let ParseStudentLocation = "https://api.parse.com/1/classes/StudentLocation"
        static let ParseUpdateLocation = "https://api.parse.com/1/classes/StudentLocation/<objectId>"
    }
    
    struct ParseResponseKeys {
        
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
    }
}