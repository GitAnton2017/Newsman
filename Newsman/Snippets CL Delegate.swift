
import Foundation
import CoreLocation

extension SnippetsViewController: CLLocationManagerDelegate
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
        
        if let location = snippetLocation
        {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location)
            { (placemarks, error)
                in
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
      snippetLocation = locations.last
    }
}
