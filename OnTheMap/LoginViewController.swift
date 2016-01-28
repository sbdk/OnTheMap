//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var debugInfo = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboarNotifications()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboarNotifications()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        prepareTextField(emailTextField)
        prepareTextField(passwordTextField)
        
        
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        //dismissAnyVisibleKeyboards()
        self.view.endEditing(true)
        if emailTextField.text!.isEmpty {
            debugInfo = "Email Address Empty"
            presentAlertView()
        } else if passwordTextField.text!.isEmpty {
            debugInfo = "Password Empty"
            presentAlertView()
        } else {
            
            creatUdacitySession()

            //self.creatUdacitySession()
        }
    
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
          self.debugInfo = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationsTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
   
    func creatUdacitySession() {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                self.debugInfo = "Can't varify account info"
                self.presentAlertView()
                return
            }
            
            /* GUARD: Did we get a successful 2XX response?*/
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugInfo = "Account not found or invalid credentials."
                    self.presentAlertView()
                }
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
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                print("Login successful")
            } catch {
                parsedResult = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugInfo = "Could not parse the data as JSON"
                    self.presentAlertView()
                }
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let account = parsedResult["account"] as? [String:AnyObject] else {
                
                print("Cannot find account info \(parsedResult)")
                return
            }
            
            guard let accountID = account["key"] as? String else {
                print("Cannot find account ID")
                return
            }
            
            self.appDelegate.udacityAccountID = accountID
            print("get Udacity Account ID: \(accountID)")
            self.completeLogin()

        }
        task.resume()
    }
    
}

extension LoginViewController{
    
    func configureUI() {
   
    }
    
    func presentAlertView() {
        
        let alertController = UIAlertController()
        alertController.title = "Error!"
        alertController.message = debugInfo
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

//keyboard configration
extension LoginViewController {
    
    func prepareTextField(textField: UITextField){
        textField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        textField.clearsOnBeginEditing = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
    }
    
    func keyboardWillHide(notifiction: NSNotification) {
        
    }
    
    func dismissAnyVisibleKeyboards() {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            self.view.endEditing(true)
        }
        
    }

    
    func subscribeToKeyboarNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboarNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
}



