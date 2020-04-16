//
//  LocationManager.swift
//  stopcorona-tracker
//
//  Created by Kristijan Ivanov on 4/16/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject {
    
    var lastLocation: CLLocation?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocationCoordinate2D?
    var lat : Float?
    var lon : Float?
    var locationManagerCallback: ((CLLocation?) -> ())?
    
    static let shared: LocationManager = {
        let instance = LocationManager()
        return instance
    }()
    
    func getLocationWithCompletionHandler(completion: @escaping (CLLocation?) -> ()) -> Void {
        if locationManager != nil {
            locationManager?.stopUpdatingLocation()
            locationManager?.delegate = nil
            locationManager = nil
        }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        let requestWhenInUseSelector = NSSelectorFromString("requestWhenInUseAuthorization")
        let requestAlwaysSelector = NSSelectorFromString("requestAlwaysAuthorization")
        
        if (locationManager?.responds(to: requestWhenInUseSelector))! {
            
            locationManager?.requestWhenInUseAuthorization()
            
        }else if (locationManager?.responds(to: requestAlwaysSelector))!{
            
            locationManager?.requestAlwaysAuthorization()
        }
        locationManager?.startUpdatingLocation()
        locationManagerCallback = completion
    }
}


extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last
        currentLocation = self.lastLocation?.coordinate
        locationManagerCallback?(self.lastLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
