//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Li Yin on 1/26/16.
//  Copyright © 2016 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
   
    var session = NSURLSession.sharedSession()
    var annotations = [MKPointAnnotation]()
    //var parsedLocationData: [[String:AnyObject]]? = [[String:AnyObject]]()
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        OTMClient.sharedInstance().getStudentLocations() {(success, results, errorString) in
            if results != nil {
                dispatch_async(dispatch_get_main_queue()){
                self.generateAnnotations(results!)
                print("\(results)")
                }
            } else {
                OTMClient.sharedInstance().presentAlertView("Get location data failed, \(errorString)!", hostView: self)
                print(errorString)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = false
            pinView!.pinTintColor = UIColor.orangeColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func logoutButtonTouch(sender: AnyObject) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        OTMClient().logoutUdacitySession(self) {(success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    @IBAction func refreshButtonTouch(sender: AnyObject) {
        
        //first remove all current annotaions
        let annonationsToRemove = self.mapView.annotations.filter{ $0 !== self.mapView.userLocation}
        self.mapView.removeAnnotations(annonationsToRemove)
        print("All currnt annoations have been removed")
        
        OTMClient.sharedInstance().getStudentLocations() {(success, results, errorString) in
            
            if results != nil {
                dispatch_async(dispatch_get_main_queue()){
                    self.generateAnnotations(results!)
                    print("reload data finish")
                }
            } else {
                OTMClient.sharedInstance().presentAlertView("Get location data failed, \(errorString)!", hostView: self)
                print(errorString)
            }
        }
    }
    
    @IBAction func pinButtonTouch(sender: AnyObject) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    func generateAnnotations(JSONResults: [[String : AnyObject]]) {
            
            for dictionary in JSONResults {
                
                let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let firstName = dictionary["firstName"] as! String
                let lastName = dictionary["lastName"] as! String
                let mediaURL = dictionary["mediaURL"] as! String
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
    }
}
