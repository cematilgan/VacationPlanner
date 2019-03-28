//
//  LocationPermissionViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-18.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class LocationPermissionViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enableButtonTapped(_ sender: UIButton) {
        LocationManager.instance.delegate = self
        LocationManager.instance.enableLocationServices()
    }
    
    @IBAction func notNowButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segues.toIntroduction, sender: self)
    }

    func moveToNextScreen(){
            performSegue(withIdentifier: Constants.Segues.toIntroduction, sender: self)
    } 
}

extension LocationPermissionViewController: VacationPlannerLocationManagerDelegate {
    func authorizationStatusChanged(authorization status: Bool) {
        if status {
            moveToNextScreen()
        }
    }
}

