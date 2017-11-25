
import Foundation
import CoreLocation

extension SnippetsViewController: CLLocationManagerDelegate
{
    
    func setLocationPermissions()
    {
      switch(CLLocationManager.authorizationStatus())
      {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse: fallthrough
        case .authorizedAlways: break
        case .denied: fallthrough
        case .restricted: break
      }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
      switch(CLLocationManager.authorizationStatus())
     {
        case .notDetermined:
          break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .authorizedAlways: break
        case .denied: break
        case .restricted: break
     }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
     print ("CORE LOCATION ERROR\n********Location manager could not detect location********\n\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
      snippetLocation = locations.last
        
      if let currentLocation = locations.last
      {
        let snippetCoordinate = currentLocation.coordinate
        print ("SNIPPET LOCATION*****************************")
        print ("LATITUDE: \(snippetCoordinate.latitude)")
        print ("LONGITUDE: \(snippetCoordinate.longitude)")
    
      }
    }
}
