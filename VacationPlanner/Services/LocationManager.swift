//
//  LocationManager.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-18.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import GooglePlaces

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let instance = LocationManager()
    
    private var locationManager = CLLocationManager()
    var delegate: VacationPlannerLocationManagerDelegate?
    var currentLocation: CLLocation? {
        return locationManager.location
    }
    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
  
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            delegate?.authorizationStatusChanged(authorization: true)
        }
    }
}

protocol VacationPlannerLocationManagerDelegate {
    func authorizationStatusChanged(authorization status: Bool)
}
