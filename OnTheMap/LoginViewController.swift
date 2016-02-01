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
    @IBOutlet weak var loginActivityIndicatorView: UIActivityIndicatorView!

    
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginActivityIndicatorView.hidden = true
        loginActivityIndicatorView.hidesWhenStopped = true
        //subscribeToKeyboarNotifications()
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()


    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //unsubscribeFromKeyboarNotifications()
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        
        prepareTextField(emailTextField)
        prepareTextField(passwordTextField)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        //dismissAnyVisibleKeyboards()
        self.view.endEditing(true)
        if emailTextField.text!.isEmpty {
            OTMClient.sharedInstance().presentAlertView("Email can't be empty", hostView: self)
        } else if passwordTextField.text!.isEmpty {
            OTMClient.sharedInstance().presentAlertView("Password can't be empty", hostView: self)
        } else {
            loginActivityIndicatorView.hidden = false
            loginActivityIndicatorView.startAnimating()
            
            OTMClient.sharedInstance().loginWithUdacityCredential(self, emailInput: emailTextField.text!, passwordInput: passwordTextField.text!){(success, errorString) in
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loginActivityIndicatorView.stopAnimating()
                    self.passwordTextField.text = ""
                }
                if success {
                    
                    self.completeLogin()
                    
                } else {
                    
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                    
                }
            
            }
            
           /* OTMClient.sharedInstance().creatUdacitySession(emailTextField.text!, passwordText: passwordTextField.text!) {(success, accountID, errorString) in
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loginActivityIndicatorView.stopAnimating()
                    self.passwordTextField.text = ""
                }

                if success {
                    
                    dispatch_async(dispatch_get_main_queue()){
                        OTMClient.sharedInstance().udacityAccountID = accountID
                        print("get Udacity Account ID: \(accountID)")
                    }
                    
                    
                    OTMClient.sharedInstance().getStudentInfoFromUdacity(accountID!){(success, result, errorString) in
                        
                        if success {
                            dispatch_async(dispatch_get_main_queue()){
                                OTMClient.sharedInstance().udacityFirstName = result!["first_name"]!
                                OTMClient.sharedInstance().udacityLastName = result!["last_name"]!
                            }
                            print("get Udacity FirstName: \(result!["first_name"]!) and LastName:\(result!["last_name"]!)")
                            self.completeLogin()
                            
                        } else {
                            
                            OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                        }
                        
                    }
        
                } else {
                    
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                    print(errorString)
                }
            } */
        }
    
    }
    
    @IBAction func udacitySignUpButtonTouch(sender: AnyObject) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
        
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationsTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
}



