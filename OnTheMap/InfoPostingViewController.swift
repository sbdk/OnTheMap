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

class InfoPostingViewController: UIViewController {
    
    @IBOutlet weak var infoPostingMapView: MKMapView!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var addressInputTextField: UITextField!
    @IBOutlet weak var URLInputTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var sumbitButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        infoPostingMapView.hidden = true
        promptLabel.hidden = false
        addressInputTextField.hidden = false
        URLInputTextField.hidden = true
        findOnTheMapButton.hidden = false
        sumbitButton.hidden = true
    
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
        
        infoPostingMapView.hidden = false
        promptLabel.hidden = true
        addressInputTextField.hidden = true
        URLInputTextField.hidden = false
        findOnTheMapButton.hidden = true
        sumbitButton.hidden = false
    }

    @IBAction func sumbitButtonTouch(sender: AnyObject) {
        
        
    }
}
