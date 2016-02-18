//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InfoPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var infoPostingMapView: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var addressInputTextField: UITextField!
    @IBOutlet weak var URLInputTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var sumbitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var session: NSURLSession!
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        infoPostingMapView.hidden = true
        promptLabel.hidden = false
        addressInputTextField.hidden = false
        URLInputTextField.hidden = true
        findOnTheMapButton.hidden = false
        sumbitButton.hidden = true
    }
    
    //hide status bar for bigger editing area
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
        addressInputTextField.delegate = self
        URLInputTextField.delegate = self
    }
    
    @IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        forwardGeocoding(self, addressInput: addressInputTextField.text!) {(success, coordinate) in
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
            }
            if success {
                
                self.infoPostingMapView.hidden = false
                self.promptLabel.hidden = true
                self.addressInputTextField.hidden = true
                self.URLInputTextField.hidden = false
                self.findOnTheMapButton.hidden = true
                self.sumbitButton.hidden = false
                
                //store Geocoding data and MapString into shared instance
                OTMClient.sharedInstance().udacityUserLatitude = coordinate?.latitude
                OTMClient.sharedInstance().udacityUserLongitude = coordinate?.longitude
                OTMClient.sharedInstance().udacityUserMapString = self.addressInputTextField.text!
                
                //use geoCodeing result to genearte Annotation on MapView
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate!
                annotation.title = self.addressInputTextField.text
                let locationRegion = MKCoordinateRegionMakeWithDistance(coordinate!, 5000, 5000)
                self.infoPostingMapView.setRegion(locationRegion, animated: true)
                self.infoPostingMapView.addAnnotation(annotation)
                
            } else {
                
            }
        }
    }

    @IBAction func sumbitButtonTouch(sender: AnyObject) {
        
        if URLInputTextField.text!.isEmpty {
            
            OTMClient.sharedInstance().presentAlertView("Link can't be empty, please provide your link", hostView: self)
            
        } else {
            OTMClient.sharedInstance().postStudentLocations(URLInputTextField.text!){ (success, result, errorString) in
                
                if success {
                    
                    OTMClient.sharedInstance().parseObjectId = result
                    print("Post info sucessful, get Parse ObjectId: \(result)")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
                }
            }
        }
    }
    
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func forwardGeocoding(hostView: UIViewController, addressInput: String, completionHandler: (success: Bool, coordinate: CLLocationCoordinate2D?) -> Void) {
        CLGeocoder().geocodeAddressString(addressInput, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                completionHandler(success: false, coordinate: nil)
                OTMClient.sharedInstance().presentAlertView("Can't find your location, please provide more detailed info", hostView: hostView)
                return
            }
            if placemarks?.count > 0 {
                
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
         
                completionHandler(success: true, coordinate: coordinate)
                
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                if placemark?.areasOfInterest?.count > 0 {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print(areaOfInterest)
                } else {
                    print("No area of interest found.")
                }
                
            }
        })
    }
    
    @IBAction func showHistoryButtonTouch(sender: AnyObject) {
        
        OTMClient.sharedInstance().queryStudentPostings{(success, result, errorString) in
        
            if success {
                print(result)
            } else {
                OTMClient.sharedInstance().presentAlertView(errorString!, hostView: self)
            }
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    //dismiss keyboard when user touch screen (other than keyboard area)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
    }
    
}
