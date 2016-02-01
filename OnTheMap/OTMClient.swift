//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class OTMClient: NSObject {
    
    //Shared info
    var session: NSURLSession
    var udacitySessionID: String? = nil
    var udacityAccountID: String? = nil
    var udacityFirstName: String? = nil
    var udacityLastName: String? = nil
    var udacityUserLatitude: Double? = nil
    var udacityUserLongitude: Double? = nil
    var udacityUserMapString: String? = nil
    var parseObjectId: String? = nil
    
    var Persons: [OTMPerson] = [OTMPerson]()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
    //functions using Udacity API
    func creatUdacitySession(emailText: String?, passwordText: String?, completionHandler: (success: Bool, accountID: String?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailText!)\", \"password\": \"\(passwordText!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(success: false, accountID: nil, errorString: "Can't connect to server, please check your network condition and try again later")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response?*/
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                completionHandler(success: false, accountID: nil, errorString: "account don't exist or wrong Email/Password")
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                print("Login successful")
            } catch {
                parsedResult = nil
                completionHandler(success: false, accountID: nil, errorString: "Invalid data returned from server")
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let account = parsedResult["account"] as? [String:AnyObject] else {
                completionHandler(success: false, accountID: nil, errorString: "Can't find account info from returned data")
                print("Cannot find account info \(parsedResult)")
                return
            }
            
            guard let accountID = account["key"] as? String else {
                completionHandler(success: false, accountID: nil, errorString: "Can't find account ID from returned data")
                print("Cannot find account ID from returned data")
                return
            }
            
            completionHandler(success: true, accountID: accountID, errorString: nil)
            
        }
        task.resume()
    }
    
    func getStudentInfoFromUdacity(accountID: String, completionHandler: (success: Bool, result: [String : AnyObject]?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(accountID)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, errorString: "no user data returned from Uacity")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? NSDictionary
                print("Parse returned user data successful")
            } catch {
                parsedResult = nil
                completionHandler(success: false, result: nil, errorString: "can't parse Udacity JSON data")
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            guard let userDict = parsedResult["user"] as? [String : AnyObject] else {
                completionHandler(success: false, result: nil, errorString: "Can't find user info on Udacity Server")
                print("Cannot find account info \(parsedResult)")
                return
            }
            completionHandler(success: true, result: userDict, errorString: nil)
        }
        task.resume()
    }
    
    func logoutUdacitySession(hostView: UIViewController, completionHandler: (success: Bool, errorString: String?) ->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "error")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }

    //functions using Parse API
    func getStudentLocations(completionHandler: (success: Bool, result: [[String : AnyObject]]?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
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
        request.HTTPBody = "{\"uniqueKey\": \"\(udacityAccountID!)\", \"firstName\": \"\(udacityFirstName!)\", \"lastName\": \"\(udacityLastName!)\",\"mapString\": \"\(udacityUserMapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(udacityUserLatitude!), \"longitude\": \(udacityUserLongitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
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
    
    
    func presentAlertView(errorString: String, hostView: UIViewController) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            hostView.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}