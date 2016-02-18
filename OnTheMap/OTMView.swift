//
//  OTMView.swift
//  OnTheMap
//
//  Created by Li Yin on 2/17/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    func presentAlertView(errorString: String, hostView: UIViewController) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertController = UIAlertController(title: "Error!", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            hostView.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func presentOverwriteAlertView(hostView: UIViewController){
        
        let alertController = UIAlertController(title: nil, message: "You have already posted a student location. Would you like to overwrite your current location?", preferredStyle: UIAlertControllerStyle.Alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Destructive, handler: {(action) in OTMClient.sharedInstance().presentPostingView(hostView)})
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(overwriteAction)
        
        hostView.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentPostingView(hostView: UIViewController){
        
        let controller = hostView.storyboard?.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        hostView.presentViewController(controller, animated: true, completion: nil)
    }
}