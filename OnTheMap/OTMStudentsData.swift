//
//  OTMStudentsData.swift
//  OnTheMap
//
//  Created by Li Yin on 2/1/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation

class OTMStudentsData {
    
    var studentData = [OTMPerson]()
    
    class func sharedInstance() -> OTMStudentsData {
        
        struct Singleton {
            static var sharedInstance = OTMStudentsData()
        }
        return Singleton.sharedInstance
    }
}