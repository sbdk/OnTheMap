//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var personsTableView: UITableView!
    
    var persons: [OTMPerson] = [OTMPerson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        OTMClient.sharedInstance().getStudentLocations{(success, results, errorString) in
            
            if results != nil{
                dispatch_async(dispatch_get_main_queue()){
                    self.persons = OTMPerson.personsFromResults(results!)
                    self.personsTableView.reloadData()
                }
                
                
            } else {
                
                print(errorString)
            }
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let person = persons[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonsTableViewCell") as UITableViewCell!
        
        cell.textLabel!.text = person.firstName + " " + person.lastName
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return persons.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40.0
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let person = persons[indexPath.row]
        let app = UIApplication.sharedApplication()
        if let URL = NSURL(string: person.mediaURL) {
            app.openURL(URL)
        } else {
            
        }
    }
    
    @IBAction func logoutButtonTouch(sender: AnyObject) {
        
        OTMClient().logoutUdacitySession()
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }

        
    }
    
}


