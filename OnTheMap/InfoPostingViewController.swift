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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    //dismiss keyboard when user touch screen (other than keyboard area)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
    }
    
}
