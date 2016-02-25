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
    
    func loginWithUdacityCredential(hostView: UIViewController, emailInput: String?, passwordInput: String?, completionHandler:(success: Bool, errorString: String?) -> Void) {
        
        creatUdacitySession(emailInput, passwordText: passwordInput){(success, accountID, errorString) in
            
            if success {
                
                self.udacityAccountID = accountID
                print("get Udacity Account ID: \(accountID)")
                
                self.getStudentInfoFromUdacity(accountID!){(success, result, errorString) in
                    
                    if success {
                        
                        self.udacityFirstName = result!["first_name"] as? String
                        self.udacityLastName = result!["last_name"] as? String
                        print("get Udacity FirstName: \(result!["first_name"]!) and LastName:\(result!["last_name"]!)")
                        completionHandler(success: success, errorString: errorString)
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        
        }
    
    }
    
    func loginWithFacebookCredential(FacebookAccessToken: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        creatFacebookSession(FacebookAccessToken){(success, accountID, errorString) in
            
            if success {
                
                self.udacityAccountID = accountID
                print("get Udacity Account ID from Facebook Session: \(accountID)")
                
                self.getStudentInfoFromUdacity(accountID!){(success, result, errorString) in
                    
                    if success {
                        
                        self.udacityFirstName = result!["first_name"] as? String
                        self.udacityLastName = result!["last_name"] as? String
                        print("get Udacity FirstName: \(result!["first_name"]!) and LastName:\(result!["last_name"]!)")
                        completionHandler(success: success, errorString: errorString)
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
            
        }
    }
}
