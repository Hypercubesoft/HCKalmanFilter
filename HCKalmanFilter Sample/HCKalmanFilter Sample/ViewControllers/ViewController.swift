//
//  ViewController.swift
//  KalmanFilter
//
//  Created by Hypercube on 4/26/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import ActionSheetPicker_3_0

class ViewController: UIViewController {
    
    var isLocationSet: Bool = false
    var stopLocationUpdate: Bool = true
    var isCameraSet: Bool = false
    var placesClient: GMSPlacesClient!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var errorAddingLabel: UILabel!
    @IBOutlet weak var startTrackingView: UIView!
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var clearAllView: UIView!
    @IBOutlet weak var clearAllButton: UIButton!
    
    var trackingIsActive:Bool = false
    var errorAdding:Bool = false
    var accuracySelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        self.startTrackingView.backgroundColor = UIColor(red: 48.0/255.0, green: 71.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        self.startTrackingButton.setTitle("Start tracking", for: .normal)
        
        self.clearAllView.alpha = 0.5
        self.clearAllButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MapService.resetAll()
        MapService.startTrackingLocation()
        stopLocationUpdate = true
        
        // Observe if user location updated.
        AppNotify.observeNotification(self, selector: #selector(locationUpdated), name: "locationUpdated")
    }

    override func viewWillDisappear(_ animated: Bool) {
        if stopLocationUpdate {
            MapService.stopTrackingLocation()
        }
        
        // Remove observers.
        AppNotify.removeObserver(self)
    }
    
    @objc func locationUpdated()
    {
        isLocationSet = true
        
        if isCameraSet == false
        {
            MapService.setCameraToCurrentLocation(mapView)
            isCameraSet = true
        }
    
        MapService.createMarkerCurrentPosition(mapView)
        MapService.drawAllPolylinesOnMap(mapView)
        //MapService.stopTrackingLocation()
    }
    
    @IBAction func startTrackingButtonPressed(_ sender: Any)
    {
        if trackingIsActive == false
        {
            self.clearAllView.alpha = 0.5
            self.clearAllButton.isEnabled = false
            
            trackingIsActive = true
            self.startTrackingView.backgroundColor = UIColor(red: 230.0/255.0, green: 125.0/255.0, blue: 4.0/255.0, alpha: 1.0)
            self.startTrackingButton.setTitle("Finish tracking", for: .normal)
            
            if isLocationSet
            {
                //stopLocationUpdate = false
                MapService.startWalk()
                MapService.isRecordingLocation = true
            }
        }
        else
        {
            self.clearAllView.alpha = 1.0
            self.clearAllButton.isEnabled = true
            
            trackingIsActive = false
            self.startTrackingView.backgroundColor = UIColor(red: 48.0/255.0, green: 71.0/255.0, blue: 95.0/255.0, alpha: 1.0)
            self.startTrackingButton.setTitle("Start tracking", for: .normal)
            
            self.startTrackingButton.isEnabled = true
            
            MapService.isRecordingLocation = false
            MapService.endWalk()
            
            var realResults = UserDefaults.standard.array(forKey: "MeasureResultsReal")
            realResults?.append(MapService.myMapService.allRealsAltidtudes)
            UserDefaults.standard.set(realResults, forKey: "MeasureResultsReal")
            
            var kalmanResults = UserDefaults.standard.array(forKey: "MeasureResultsKalman")
            kalmanResults?.append(MapService.myMapService.allAltidtudes)
            UserDefaults.standard.set(kalmanResults, forKey: "MeasureResultsKalman")
            
            MapService.myMapService.allRealsAltidtudes.removeAll()
            MapService.myMapService.allAltidtudes.removeAll()
        }
    }
    
    @IBAction func changeAccuracyButtonPressed(_ sender: UIButton)
    {
        ActionSheetStringPicker.show(withTitle: "Select accuracy precision : ", rows: ["Best For Navigation", "Best", "Nearest Ten Meters", "Hundred Meters","Kilometer","Three Kilometers"], initialSelection: accuracySelectedIndex, doneBlock: {
            picker, value, index in
            
            self.accuracySelectedIndex = value
            self.accuracyLabel.text = "GPS Accuracy : \(index as! String)"
            MapService.changeAccuracy(accuracy: self.accuracySelectedIndex)
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func changeRandomErrorAddingButtonPressed(_ sender: UIButton)
    {
        var newLabelString = ""
        if errorAdding
        {
            newLabelString = "Add random error : NO"
            errorAdding = false
            MapService.randomError = false
        }
        else
        {
            newLabelString = "Add random error : YES"
            errorAdding = true
            MapService.randomError = true
        }
        
        self.errorAddingLabel.text = newLabelString
    }
    
    @IBAction func clearAllButtonPressed(_ sender: UIButton)
    {
        MapService.resetAll()
        MapService.drawAllPolylinesOnMap(mapView)
    }
    
    @IBAction func hypercubeButtonPressed(_ sender: UIButton)
    {
        let url = URL(string: "http://hypercubesoft.com/")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

