//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!

    
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
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
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            
            print("Facebook not logged in")
            
        } else {
            
            print("Facebook already logged in")
        }
        
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = ["public_profile","email","user_friends"]
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        //dismissAnyVisibleKeyboards()
        self.view.endEditing(true)
        
        
        if emailTextField.text!.isEmpty {
            OTMClient.sharedInstance().presentAlertView("Email can't be empty", hostView: self)
        } else if passwordTextField.text!.isEmpty {
            OTMClient.sharedInstance().presentAlertView("Password can't be empty", hostView: self)
        } else {
            //update UI
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            loginActivityIndicatorView.hidden = false
            loginActivityIndicatorView.startAnimating()
            
            OTMClient.sharedInstance().loginWithUdacityCredential(self, emailInput: emailTextField.text!, passwordInput: passwordTextField.text!){(success, errorString) in
                
                dispatch_async(dispatch_get_main_queue()){
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.loginActivityIndicatorView.stopAnimating()
                    self.passwordTextField.text = ""
                }
                if success {
                    
                    self.completeLogin()
                    
                } else {
                    
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                }
            }
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
    
    
    //FBSDKLoginButtonDelegate implementation
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if(error != nil){
            print(error.localizedDescription)
            OTMClient.sharedInstance().presentAlertView(error.localizedDescription, hostView: self)
            return
        }
        
        if let userToken = result.token {
            
            OTMClient.sharedInstance().FBAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            print("Token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            print("User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            OTMClient.sharedInstance().loginWithFacebookCredential(OTMClient.sharedInstance().FBAccessToken){(success, errorString) in
                
                if success {
                    
                    self.completeLogin()
                    
                } else {
                    
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                }
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
    
}



