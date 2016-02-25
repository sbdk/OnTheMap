//
//  OTMFBClient.swift
//  OnTheMap
//
//  Created by Li Yin on 2/24/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation

extension OTMClient {
    
    
    func creatFacebookSession(FacebookAccessToken: String?, completionHandler: (success: Bool, accountID: String?, errorString: String?) -> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(FacebookAccessToken!);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(success: false, accountID: nil, errorString: "Can't connect to server, please check your network condition and try again later")
                return
            }
            
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


            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
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
    
    
}