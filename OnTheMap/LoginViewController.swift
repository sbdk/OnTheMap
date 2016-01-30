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
            
            OTMClient.sharedInstance().creatUdacitySession(emailTextField.text!, passwordText: passwordTextField.text!) {(success, accountID, errorString) in
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loginActivityIndicatorView.stopAnimating()
                    //self.loginActivityView.hidden = true
                }

                if success {
                    
                    OTMClient.sharedInstance().udacityAccountID = accountID
                    print("get Udacity Account ID: \(accountID)")
                    self.completeLogin()
                    
                } else {
                    
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                    print(errorString)
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
}

//keyboard configration
extension LoginViewController {
    
    
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
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

    
    /*func prepareTextField(textField: UITextField){
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
        
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notifiction: NSNotification) {
        
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        
    }
    
    func dismissAnyVisibleKeyboards() {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            self.view.endEditing(true)
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
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
    }*/
    
}



