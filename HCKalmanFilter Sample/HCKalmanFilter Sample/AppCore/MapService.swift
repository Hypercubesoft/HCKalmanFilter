//
//  MapService.swift
//  KalmanFilter
//
//  Created by Hypercube on 1/19/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit
import GoogleMaps

class MapService: NSObject, CLLocationManagerDelegate
{
    static var isRecordingLocation: Bool = false
    var isTrackingLocation: Bool = false
    var didFindMyLocation: Bool = false
    var locationManager: CLLocationManager = CLLocationManager()
    var lastLocation: CLLocation? = nil
    var pathLengths: [Float] = []
    
    var paths: [GMSMutablePath] = []
    var realPaths: [GMSMutablePath] = []
    
    var altidtudes: [Double] = []
    var realsAltidtudes: [Double] = []
    var allAltidtudes: [Double] = []
    var allRealsAltidtudes: [Double] = []
    
    var startTimes: [Date] = []
    var endTimes: [Date] = []
    
    var resetKalmanFilter: Bool = false
    
    static var desiredAccuracyParam = kCLLocationAccuracyBestForNavigation
    static var randomError: Bool = false
    
    var kalmanFilter: HCKalmanAlgorithm?
    
    static let myMapService: MapService = {
        let instance = MapService()
        return instance
    }()

    
    // MARK: - Map setup and manipulation.
    class func setCamera(_ lat: CLLocationDegrees, long: CLLocationDegrees, mapView: GMSMapView)
    {
        mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15.0)
    }
    class func setCameraToCurrentLocation(_ mapView: GMSMapView)
    {
        mapView.camera = GMSCameraPosition.camera(withLatitude: (myMapService.lastLocation?.coordinate.latitude)!,
                                                  longitude: (myMapService.lastLocation?.coordinate.longitude)!, zoom: 15.0)
    }
    
    // MARK: - Walking.
    class func startWalk()
    {
        myMapService.resetKalmanFilter = true
        // Start new path.
        startNewPath()
        
        // Add to the last path if needed.
        if let last = myMapService.lastLocation {
            addNewPointToLastPath(last.coordinate.latitude,
                                  long: last.coordinate.longitude)
            addNewKalmanPointToLastPath(last.coordinate.latitude,
                                  long: last.coordinate.longitude)
        }
        
        // Set current time for this path.
        let currentTime = Date()
        myMapService.startTimes.append(currentTime)
    }
    
    class func endWalk()
    {
        let currentTime = Date()
        myMapService.endTimes.append(currentTime)
    }
    
    class func getWlakingTime() -> TimeInterval
    {
        var timePassed: TimeInterval = 0
        if myMapService.startTimes.count > 1 {
            for i in 0...myMapService.startTimes.count - 2 {
                timePassed += myMapService.endTimes[i].timeIntervalSince(myMapService.startTimes[i])
            }
        }
        timePassed += Date().timeIntervalSince(myMapService.startTimes.last!)
        return timePassed
    }
    
    // MARK: - Location manipulation.
    class func resetAll(){
        myMapService.pathLengths.removeAll()
        myMapService.paths.removeAll()
        myMapService.realPaths.removeAll()
        myMapService.altidtudes.removeAll()
        myMapService.realsAltidtudes.removeAll()
        myMapService.allAltidtudes.removeAll()
        myMapService.allRealsAltidtudes.removeAll()
        myMapService.startTimes.removeAll()
        myMapService.endTimes.removeAll()
    }
    
    class func startTrackingLocation()
    {
        if !myMapService.isTrackingLocation {
            myMapService.locationManager.delegate = myMapService.self
            myMapService.locationManager.requestLocation()
            myMapService.locationManager.requestWhenInUseAuthorization()
            myMapService.locationManager.requestAlwaysAuthorization()
            myMapService.locationManager.allowsBackgroundLocationUpdates = true
            myMapService.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            myMapService.locationManager.startUpdatingLocation()
            myMapService.isTrackingLocation = true
        }
    }
    
    class func changeAccuracy(accuracy: Int)
    {
        switch accuracy {
        case 0:
            desiredAccuracyParam = kCLLocationAccuracyBestForNavigation
        case 1:
            desiredAccuracyParam = kCLLocationAccuracyBest
        case 2:
            desiredAccuracyParam = kCLLocationAccuracyNearestTenMeters
        case 3:
            desiredAccuracyParam = kCLLocationAccuracyHundredMeters
        case 4:
            desiredAccuracyParam = kCLLocationAccuracyKilometer
        case 5:
            desiredAccuracyParam = kCLLocationAccuracyThreeKilometers
        default:
            desiredAccuracyParam = kCLLocationAccuracyBestForNavigation
        }
        
        myMapService.locationManager.desiredAccuracy = desiredAccuracyParam
    }
    
    class func stopTrackingLocation()
    {
        if myMapService.isTrackingLocation {
            myMapService.locationManager.stopUpdatingLocation()
            myMapService.isTrackingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var myLocation: CLLocation = locations.first!
        
        if MapService.randomError
        {
            let randInt = Int(arc4random_uniform(100))
            let rand = Double(randInt-50)
            let random = 0.0005*rand/100.0
            let error = arc4random_uniform(100) % 5 == 0
            
            myLocation = error ? CLLocation(latitude: myLocation.coordinate.latitude + random, longitude: myLocation.coordinate.longitude + random) : myLocation
        }
        
        if lastLocation != nil {
            let distance = myLocation.distance(from: lastLocation!)
            if MapService.isRecordingLocation {
                print("distance: " + distance.description + " accuracy: " + "\(myLocation.horizontalAccuracy)" + "speed: " + "\(myLocation.speed) " + "altitude: " + "\(myLocation.altitude)") }
            
            if distance < 0.5 {
                return }
            
            if MapService.isRecordingLocation {
                pathLengths[pathLengths.count - 1] += Float(distance) }
        }
        
        lastLocation = myLocation
        
        if MapService.isRecordingLocation {
            print(myLocation.coordinate)
        }
        
        // Add to the last path if needed.
        if MapService.isRecordingLocation {
            if kalmanFilter == nil {
                self.kalmanFilter = HCKalmanAlgorithm(initialLocation: myLocation)
            }
            else
            {
                if let kalmanFilter = self.kalmanFilter
                {
                    if self.resetKalmanFilter == true
                    {
                        self.altidtudes.removeAll()
                        self.realsAltidtudes.removeAll()
                        
                        kalmanFilter.resetKalman(newStartLocation: myLocation)
                        self.resetKalmanFilter = false
                    }
                    else
                    {
                        let realAltitude = myLocation.altitude
                        
                        let kalmanLocation = kalmanFilter.processState(currentLocation:myLocation)
                        
                        self.addNewAltitudeValues(realAltitude: realAltitude, kalmanAltitude: kalmanLocation.altitude)
                        
                        print(kalmanLocation.coordinate)
                        
                        MapService.addNewPointToLastPath(myLocation.coordinate.latitude,
                                                         long: myLocation.coordinate.longitude)
                        
                        MapService.addNewKalmanPointToLastPath((kalmanLocation.coordinate.latitude),
                                                               long: (kalmanLocation.coordinate.longitude))
                    }
                }
            }
        }
        
        // Notify all observers that there is a new location.
        AppNotify.postNotification("locationUpdated")
    }
    
    func addNewAltitudeValues(realAltitude: Double, kalmanAltitude: Double)
    {
        let maxNumberOfElementsInArray = 5
        
        self.allRealsAltidtudes.append(realAltitude)
        self.allAltidtudes.append(kalmanAltitude)
        
        if self.realsAltidtudes.count > maxNumberOfElementsInArray
        {
            let subArray = getLast(array: self.realsAltidtudes, count: maxNumberOfElementsInArray-1)
            self.realsAltidtudes = subArray
            self.realsAltidtudes.append(realAltitude)
        }
        else
        {
            self.realsAltidtudes.append(realAltitude)
        }
        
        if self.altidtudes.count > maxNumberOfElementsInArray
        {
            let subArray = getLast(array: self.altidtudes, count: maxNumberOfElementsInArray-1)
            self.altidtudes = subArray
            self.altidtudes.append(kalmanAltitude)
        }
        else
        {
            self.altidtudes.append(kalmanAltitude)
        }
    }
    
    func getLast<T>(array: [T], count: Int) -> [T] {
        if count >= array.count {
            return array
        }
        let first = array.count - count
        return Array(array[first..<first+count])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MapService - locationManager - fail")
    }
    
    class func getWalkingDistance() -> Float
    {
        var distance: Float = 0
        for num in myMapService.pathLengths {
            distance += num
        }
        return distance
    }
    class func degreeToRadian(angle:CLLocationDegrees) -> CGFloat
    {
        return ((CGFloat(angle)) / 180.0 * CGFloat(Double.pi))
    }
    class func radianToDegree(radian:CGFloat) -> CLLocationDegrees
    {
        return CLLocationDegrees(radian * CGFloat(180.0 / Double.pi))
    }
    class func middlePointOfThePath(path: GMSMutablePath) -> CLLocationCoordinate2D
    {
        var coordinates: [CLLocationCoordinate2D] = []
        let numOfItems = path.count()
        for i in 0...numOfItems-1 {
            coordinates.append(path.coordinate(at: i))
        }
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var z: CGFloat = 0.0
        
        for coordinate in coordinates
        {
            let lat:CGFloat = degreeToRadian(angle: coordinate.latitude)
            let lon:CGFloat = degreeToRadian(angle: coordinate.longitude)
            
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon);
            z = z + sin(lat);
        }
        
        x = x/CGFloat(coordinates.count)
        y = y/CGFloat(coordinates.count)
        z = z/CGFloat(coordinates.count)
        
        let resultLon: CGFloat = atan2(y, x)
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        let resultLat: CGFloat = atan2(z, resultHyp)
        
        let newLat = radianToDegree(radian: resultLat)
        let newLon = radianToDegree(radian: resultLon)
        
        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    }
    
    // MARK: - Create, Update and Draw polyline on map.
    class func drawAllPolylinesOnMap(_ mapView: GMSMapView)
    {
        // Real Paths
        for path in myMapService.paths {
            createMarker(path.coordinate(at: 0).latitude, long: path.coordinate(at: 0).longitude, mapView: mapView, type: 0, start: true)
            if path.count() > 0 {
               createMarker(path.coordinate(at: path.count() - 1).latitude, long: path.coordinate(at: path.count() - 1).longitude, mapView: mapView, type: 0, start: false)
            }
            
            drawRealPolyline(mapView, path: path)
        }
        
        // Kalman Paths
        for path in myMapService.realPaths {
            createMarker(path.coordinate(at: 0).latitude, long: path.coordinate(at: 0).longitude, mapView: mapView, type: 1, start: true)
            if path.count() > 0 {
                createMarker(path.coordinate(at: path.count() - 1).latitude, long: path.coordinate(at: path.count() - 1).longitude, mapView: mapView, type: 1, start: false)
            }
            
            drawKalmanPolyline(mapView, path: path)
        }
    }
    class func createMarker(_ lat: CLLocationDegrees, long: CLLocationDegrees, mapView: GMSMapView, type: Int, start: Bool)
    {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        if type == 0 {
            if start
            {
                marker.icon = UIImage(named: "real_map_start_pin")
            }
            else
            {
                marker.icon = UIImage(named: "real_map_end_pin")
            }
            
        } else if type == 1 {
            if start
            {
                marker.icon = UIImage(named: "kalman_map_start_pin")
            }
            else
            {
                marker.icon = UIImage(named: "kalman_map_end_pin")
            }
        }
        
        marker.map = mapView
    }
    class func createMarkerCurrentPosition(_ mapView: GMSMapView)
    {
        mapView.clear()
        createMarker((myMapService.lastLocation?.coordinate.latitude)!,
                     long: (myMapService.lastLocation?.coordinate.longitude)!,
                     mapView: mapView,
                     type: 0, start: false)
    }
    class func startNewPath()
    {
        myMapService.pathLengths.append(0)
        myMapService.paths.append(GMSMutablePath())
        myMapService.realPaths.append(GMSMutablePath())
    }
    class func addNewPointToLastPath(_ lat: CLLocationDegrees, long: CLLocationDegrees)
    {
        if let path = myMapService.paths.last {
            path.add(CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
    }
    
    class func addNewKalmanPointToLastPath(_ lat: CLLocationDegrees, long: CLLocationDegrees)
    {
        if let path = myMapService.realPaths.last {
            path.add(CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
    }
    
    class func drawRealPolyline(_ mapView: GMSMapView, path: GMSMutablePath)
    {
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 44.0/255.0, green: 150.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        polyline.strokeWidth = 3
        polyline.map = mapView
    }
    
    class func drawKalmanPolyline(_ mapView: GMSMapView, path: GMSMutablePath)
    {
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(red: 230.0/255.0, green: 125.0/255.0, blue: 4.0/255.0, alpha: 1.0)
        polyline.strokeWidth = 3
        polyline.map = mapView
    }
}
