//
//  CL Wrapper.swift
//  Newsman
//
//  Created by Anton2016 on 07.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

@propertyWrapper class GeoLocator: NSObject
{

 private var locationManager = CLLocationManager()
 private var currentLocation: CLLocation?
 
 
 override convenience init()
 {
  self.init(desiredAccuracy: kCLLocationAccuracyBest, distanceFilter:  20)
 }
 
 init(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance)
 {
  //Core Location Manager Settings ************************
  let locationManager = CLLocationManager()
  locationManager.desiredAccuracy = desiredAccuracy
  locationManager.distanceFilter = distanceFilter //meters
  self.locationManager = locationManager
  //*******************************************************
  
  super.init()
  
  locationManager.delegate = self
 }
 
 var wrappedValue: CLLocation? { currentLocation }
 
 var projectedValue: Single<String?>
 {
  Single.create
  { promise in
   self.getLocationString{ promise(.success($0))}
   return Disposables.create()
  }
 }

}


extension GeoLocator: CLLocationManagerDelegate
{
    
    func setLocationPermissions()
    {
     switch(CLLocationManager.authorizationStatus())
     {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse: fallthrough
        case .authorizedAlways: break
        case .denied: fallthrough
        case .restricted: break
        @unknown default: break
     }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
     switch(CLLocationManager.authorizationStatus())
     {
        case .notDetermined: break
        case .authorizedWhenInUse: locationManager.startUpdatingLocation()
        case .authorizedAlways: break
        case .denied: break
        case .restricted: break
        @unknown default: break
     }
    }
    
    func getLocationString(handler: @escaping (String?) -> Void)
    {
        if let location = currentLocation
        {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location)
            { (placemarks, error) in
                if error == nil, let placemark = placemarks?.first
                {
                    var location = ""
                    if let country    = placemark.country                 {location += country          }
                    if let region     = placemark.administrativeArea      {location += ", " + region    }
                    if let district   = placemark.subAdministrativeArea   {location += ", " + district  }
                    if let city       = placemark.locality                {location += ", " + city      }
                    if let subcity    = placemark.subLocality             {location += ", " + subcity   }
                    if let street     = placemark.thoroughfare            {location += ", " + street    }
                    if let substreet  = placemark.subThoroughfare         {location += ", " + substreet }
                    
                    OperationQueue.main.addOperation {handler(location)}
                }
                else
                {
                    OperationQueue.main.addOperation{handler(nil)}
                }
                
            }
            
        }
        else
        {
            OperationQueue.main.addOperation{handler(nil)}
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
     print ("CORE LOCATION ERROR!\nLocation manager could not detect location\n\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
      currentLocation = locations.last
    }
}

