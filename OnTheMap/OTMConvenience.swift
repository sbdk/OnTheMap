//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Li Yin on 1/28/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {
    
    func logoutUdacitySession(hostView: UIViewController, completionHandler: (success: Bool, errorString: String?) ->Void) {
        
        
        //let controller = hostView.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        //hostView.presentViewController(controller, animated: true, completion: nil)
        //hostView.dismissViewControllerAnimated(true, completion: nil)
        
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
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandler(success: true, errorString: nil)
        }
        
        task.resume()
        
    }   

}
