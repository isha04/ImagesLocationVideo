//
//  ViewController.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/7/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {
    
    
    var userLatitude: CLLocationDegrees = 0.0
    var userLongitude: CLLocationDegrees = 0.0
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 18.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
        addMap()
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 0.10
        placesClient = GMSPlacesClient.shared()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    func addMap() {
        let camera = GMSCameraPosition.camera(withLatitude: userLatitude, longitude: userLongitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.setMinZoom(12, maxZoom: mapView.maxZoom)
        
        //Adding marker to map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(userLatitude, userLongitude)
        marker.map = mapView
        self.view = mapView
        mapView.isHidden = true
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        userLongitude = location.coordinate.longitude
        userLatitude = location.coordinate.latitude
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            alertWithTitle(title: "Unauthorised use of Location", message: "This app is not authorized to use location services")
        case .denied:
            alertWithTitle(title: "Location access denied", message: "Please enable location permissions for this app in Settings")
            mapView.isHidden = false
        case .notDetermined:
            alertWithTitle(title: "", message: "Please enable location permissions for this app in Settings")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
//    func vCardURL(from coordinate: CLLocationCoordinate2D, with name: String?) -> URL {
//        let vCardFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Shared Location.loc.vcf")
//    
//        let vCardString = [
//            "BEGIN:VCARD",
//            "VERSION:3.0",
//            //"PRODID:-//Apple Inc.//iPhone OS 10.3.2//EN",
//            "N:;My Location;;;",
//            "FN:My Location",
//            "item1.URL;type=pref:https://maps.apple.com/?ll=50.359890\\,12.934560&q=My%20Location&t=m",
//            "item1.X-ABLabel:map url",
//            "END:VCARD"
//            ].joined(separator: "\n")
//    
//        do {
//            try vCardString.write(toFile: vCardFileURL.path, atomically: true, encoding: .utf8)
//        } catch let error {
//            print("Error, \(error.localizedDescription), saving vCard: \(vCardString) to file path: \(vCardFileURL.path).")
//        }
//    
//        print(vCardString)
//        return vCardFileURL
//    }
    
}


