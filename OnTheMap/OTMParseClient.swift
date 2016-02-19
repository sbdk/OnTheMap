//
//  OTMParseClient.swift
//  OnTheMap
//
//  Created by Li Yin on 2/17/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation

extension OTMClient {
    
    //functions using Parse API
    func getStudentLocations(completionHandler: (success: Bool, result: [[String : AnyObject]]?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.HTTPMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(success: false, result: nil, errorString: "Can't connect to Parse Server")
                print("Can't connect to Parse Server: \(error)")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                completionHandler(success: false, result: nil, errorString: "Parse returned a invalid response")
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            guard let data = data else {
                completionHandler(success: false, result: nil, errorString: "No data was returned from Parse Server")
                print("No data was returned from Parse Server")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: false, result: nil, errorString: "Can't parse returned JSON data")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                completionHandler(success: false, result: nil, errorString: "Can't find user info on Parse Server")
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            completionHandler(success: true, result: results, errorString: nil)
        }
        task.resume()
    }
    
    func postStudentLocations(mediaURL: String?, completionHandler: (success: Bool, result: String?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String:AnyObject] = [
            OTMClient.JSONBodyKeys.uniqueKey: udacityAccountID!,
            OTMClient.JSONBodyKeys.firstName: udacityFirstName!,
            OTMClient.JSONBodyKeys.lastName: udacityLastName!,
            OTMClient.JSONBodyKeys.mapString: udacityUserMapString!,
            OTMClient.JSONBodyKeys.mediaURL: mediaURL!,
            OTMClient.JSONBodyKeys.latitude: udacityUserLatitude!,
            OTMClient.JSONBodyKeys.longitude: udacityUserLongitude!
        ]
        
        do{
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        //request.HTTPBody = "{\"uniqueKey\": \"\(udacityAccountID!)\", \"firstName\": \"\(udacityFirstName!)\", \"lastName\": \"\(udacityLastName!)\",\"mapString\": \"\(udacityUserMapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(udacityUserLatitude!), \"longitude\": \(udacityUserLongitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, errorString: "Can't connect to server, please check your network connection and try again later")
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: false, result: nil, errorString: "Can't parse JSON result")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let result = parsedResult["objectId"] as? String else {
                print("Cannot find key 'objectId' in \(parsedResult)")
                completionHandler(success: false, result: nil, errorString: "Can't find objectId info")
                return
            }
            completionHandler(success: true, result: result, errorString: nil)
        }
        task.resume()
    }
    
    func queryStudentPostings(completionHandler: (success: Bool, result: [[String : AnyObject]]?, errorString: String?) -> Void){
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(udacityAccountID!)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, errorString: "Can't connect to Parse Server")
                print("Can't connect to Parse Server:\(error)")
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                completionHandler(success: false, result: nil, errorString: "Parse returned a invalid response")
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            guard let data = data else {
                completionHandler(success: false, result: nil, errorString: "No data was returned from Parse Server")
                print("No data was returned from Parse Server")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: false, result: nil, errorString: "Can't parse returned JSON data")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                completionHandler(success: false, result: nil, errorString: "Can't find user info on Parse Server")
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            completionHandler(success: true, result: results, errorString: nil)
        }
        task.resume()
    }
    
    func updateStudentPosting(objectId: String, mediaURL: String?, completionHandler: (success: Bool, result: String?, errorString: String?) -> Void){
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String:AnyObject] = [
            OTMClient.JSONBodyKeys.uniqueKey: udacityAccountID!,
            OTMClient.JSONBodyKeys.firstName: udacityFirstName!,
            OTMClient.JSONBodyKeys.lastName: udacityLastName!,
            OTMClient.JSONBodyKeys.mapString: udacityUserMapString!,
            OTMClient.JSONBodyKeys.mediaURL: mediaURL!,
            OTMClient.JSONBodyKeys.latitude: udacityUserLatitude!,
            OTMClient.JSONBodyKeys.longitude: udacityUserLongitude!
        ]
        
        do{
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, errorString: "Can't connect to server, please check your network connection and try again later")
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: false, result: nil, errorString: "Can't parse JSON result")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let result = parsedResult["updatedAt"] as? String else {
                print("Cannot find key 'objectId' in \(parsedResult)")
                completionHandler(success: false, result: nil, errorString: "Can't find objectId info")
                return
            }
            print("Update Successful, \(result)")
            completionHandler(success: true, result: result, errorString: nil)
        }
        task.resume()
    }
    
}