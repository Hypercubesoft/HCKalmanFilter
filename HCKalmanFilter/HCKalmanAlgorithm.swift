//
//  HCKalmanAlgorithm.swift
//  KalmanFilter
//
//  Created by Hypercube on 4/27/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation
import MapKit
import Surge

open class HCKalmanAlgorithm
{
    //MARK: - HCKalmanAlgorithm properties
    
    /// The dimension M of the state vector.
    private let stateMDimension = 6
    
    /// The dimension N of the state vector.
    private let stateNDimension = 1
    
    /// Acceleration variance magnitude for GPS
    /// =======================================
    /// **Sigma** value is  value for Acceleration Noise Magnitude Matrix (Qt).
    /// Recommended value for **sigma** is 0.0625, this value is optimal for GPS problem,
    /// it was concluded by researches.
    private let sigma = 0.0625
    
    
    /// Value for Sensor Noise Covariance Matrix
    /// ========================================
    /// Default value is 29.0, this is the recommended value for the GPS problem, with this value filter provides optimal accuracy.
    /// This value can be adjusted depending on the needs, the higher value
    /// of **rVaule** variable will give greater roundness trajectories, and vice versa.
    open var rValue: Double {
        set
        {
            _rValue = newValue
        }
        get
        {
            return _rValue
        }
    }
    
    private var _rValue: Double = 29.0
    
    
    /// Previous State Vector
    /// =====================
    /// **Previous State Vector** is mathematical representation of previous state of Kalman Algorithm.
    private var xk1:HCMatrixObject
    
    
    /// Covariance Matrix for Previous State
    /// ====================================
    /// **Covariance Matrix for Previous State** is mathematical representation of covariance matrix for previous state of Kalman Algorithm.
    private var Pk1:HCMatrixObject
    
    
    /// Prediction Step Matrix
    /// ======================
    /// **Prediction Step Matrix (A)** is mathematical representation of prediction step of Kalman Algorithm.
    /// Prediction Matrix gives us our next state. It takes every point in our original estimate and moves it to a new predicted location,
    /// which is where the system would move if that original estimate was the right one.
    private var A:HCMatrixObject
    
    
    /// Acceleration Noise Magnitude Matrix
    /// ===================================
    /// **Acceleration Noise Magnitude Matrix (Qt)** is mathematical representation of external uncertainty of Kalman Algorithm.
    /// The uncertainty associated can be represented with the “world” (i.e. things we aren’t keeping track of)
    /// by adding some new uncertainty after every prediction step.
    private var Qt:HCMatrixObject
    
    
    /// Sensor Noise Covariance Matrix
    /// ==============================
    /// **Sensor Noise Covariance Matrix (R)** is mathematical representation of sensor noise of Kalman Algorithm.
    /// Sensors are unreliable, and every state in our original estimate might result in a range of sensor readings.
    private var R:HCMatrixObject
    
    /// Measured State Vector
    /// =====================
    /// **Measured State Vector (zt)** is mathematical representation of measuerd state vector of Kalman Algorithm.
    /// Value of this variable was readed from sensor, this is mean value to the reading we observed.
    private var zt:HCMatrixObject!
    
    /// Time of last measurement
    /// ========================
    /// This time is used for calculating the time interval between previous and last measurements
    private var previousMeasureTime = Date()
    
    /// Previous State Location
    private var previousLocation = CLLocation()
    
    
    //MARK: - HCKalmanAlgorithm initialization
    
    /// Initialization of Kalman Algorithm Constructor
    /// ==============================================
    /// - parameters:
    ///   - initialLocation: this is CLLocation object which represent initial location
    ///                      at the moment when algorithm start
    public init(initialLocation: CLLocation)
    {
        self.previousMeasureTime = Date()
        self.previousLocation = CLLocation()
        
        self.xk1 = HCMatrixObject(rows: stateMDimension, columns: stateNDimension)
        self.Pk1 = HCMatrixObject(rows: stateMDimension, columns: stateMDimension)
        self.A = HCMatrixObject(rows: stateMDimension, columns: stateMDimension)
        self.Qt = HCMatrixObject(rows: stateMDimension, columns: stateMDimension)
        self.R = HCMatrixObject(rows: stateMDimension, columns: stateMDimension)
        self.zt = HCMatrixObject(rows: stateMDimension, columns: stateNDimension)
        
        initKalman(initialLocation: initialLocation)
    }
    
    //MARK: - HCKalmanAlgorithm functions
    
    /// Initialization of Kalman Algorithm Function
    /// ===========================================
    /// This set up Kalman filter matrices to the default values
    /// - parameters:
    ///   - initialLocation: this is CLLocation object which represent initial location
    ///                      at the moment when algorithm start
    private func initKalman(initialLocation: CLLocation)
    {
        // Set timestamp for start of measuring
        previousMeasureTime = initialLocation.timestamp
        
        // Set initial location
        previousLocation = initialLocation
        
        // Set Previous State Matrix
        // xk1 -> [ initial_lat  lat_velocity = 0.0  initial_lon  lon_velocity = 0.0 initial_altitude altitude_velocity = 0.0 ]T
        xk1.setMatrix(matrix: [[initialLocation.coordinate.latitude],[0.0],[initialLocation.coordinate.longitude],[0.0],[initialLocation.altitude],[0.0]])
        
        // Set initial Covariance Matrix for Previous State
        Pk1.setMatrix(matrix: [[0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0]])
        
        // Prediction Step Matrix initialization
        A.setMatrix(matrix: [[1,0,0,0,0,0],[0,1,0,0,0,0],[0,0,1,0,0,0],[0,0,0,1,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1]])
        
        // Sensor Noise Covariance Matrixinitialization
        R.setMatrix(matrix: [[_rValue,0,0,0,0,0],[0,_rValue,0,0,0,0],[0,0,_rValue,0,0,0],[0,0,0,_rValue,0,0],[0,0,0,0,_rValue,0],[0,0,0,0,0,_rValue]])
    }
    
    /// Restart Kalman Algorithm Function
    /// ===========================================
    /// This restart Kalman filter matrices to the default values
    /// - parameters:
    ///   - newStartLocation: this is CLLocation object which represent location
    ///                       at the moment when algorithm start again
    open func resetKalman(newStartLocation: CLLocation)
    {
        self.initKalman(initialLocation: newStartLocation)
    }
    
    /// Process Current Location
    /// ========================
    ///  This function is a main. **processState** will be processed current location of user by Kalman Filter
    ///  based on previous state and other parameters, and it returns corrected location
    /// - parameters:
    ///   - currentLocation: this is CLLocation object which represent current location returned by GPS.
    ///                      **currentLocation** is real position of user, and it will be processed by Kalman Filter.
    /// - returns: CLLocation object with corrected latitude, longitude and altitude values
    
    open func processState(currentLocation: CLLocation) -> CLLocation
    {
        // Set current timestamp
        let newMeasureTime = currentLocation.timestamp
        
        // Convert measure times to seconds
        let newMeasureTimeSeconds = newMeasureTime.timeIntervalSince1970
        let lastMeasureTimeSeconds = previousMeasureTime.timeIntervalSince1970
        
        // Calculate timeInterval between last and current measure
        let timeInterval = newMeasureTimeSeconds - lastMeasureTimeSeconds
        
        // Calculate and set Prediction Step Matrix based on new timeInterval value
        A.setMatrix(matrix: [[1,Double(timeInterval),0,0,0,0],[0,1,0,0,0,0],[0,0,1,Double(timeInterval),0,0],[0,0,0,1,0,0],[0,0,0,0,1,Double(timeInterval)],[0,0,0,0,0,1]])
        
        // Parts of Acceleration Noise Magnitude Matrix
        let part1 = sigma*(Double(pow(Double(timeInterval), Double(4)))/4.0)
        let part2 = sigma*(Double(pow(Double(timeInterval), Double(3)))/2.0)
        let part3 = sigma*(Double(pow(Double(timeInterval), Double(2))))
        
        // Calculate and set Acceleration Noise Magnitude Matrix based on new timeInterval and sigma values
        Qt.setMatrix(matrix: [[part1,part2,0.0,0.0,0.0,0.0],[part2,part3,0.0,0.0,0.0,0.0],[0.0,0.0,part1,part2,0.0,0.0],[0.0,0.0,part2,part3,0.0,0.0],[0.0,0.0,0.0,0.0,part1,part2],[0.0,0.0,0.0,0.0,part2,part3]])
        
        // Calculate velocity components
        // This is value of velocity between previous and current location.
        // Distance traveled from the previous to the current location divided by timeInterval between two measurement.
        let velocityXComponent = (previousLocation.coordinate.latitude - currentLocation.coordinate.latitude)/timeInterval
        let velocityYComponent = (previousLocation.coordinate.longitude - currentLocation.coordinate.longitude)/timeInterval
        let velocityZComponent = (previousLocation.altitude - currentLocation.altitude)/timeInterval
        
        // Set Measured State Vector; current latitude, longitude, altitude and latitude velocity, longitude velocity and altitude velocity
        zt.setMatrix(matrix: [[currentLocation.coordinate.latitude],[velocityXComponent],[currentLocation.coordinate.longitude],[velocityYComponent],[currentLocation.altitude],[velocityZComponent]])
        
        // Set previous Location and Measure Time for next step of processState function.
        previousLocation = currentLocation
        previousMeasureTime = newMeasureTime
        
        // Return value of kalmanFilter
        return self.kalmanFilter()
    }
    
    /// Kalman Filter Function
    /// ======================
    /// This is additional function, which helps in the process of correcting location
    /// Here happens the whole mathematics related to Kalman Filter. Here is the essence.
    /// The algorithm consists of two parts - Part of Prediction and Part of Update State
    ///
    /// Prediction part performs the prediction of the next state based on previous state, prediction matrix (A) and takes into consideration
    /// external uncertainty factor (Qt). It returns predicted state and covariance matrix -> xk, Pk
    ///
    /// Next step is Update part. It combines predicted state with sensor measurement. Update part first calculate Kalman gain (Kt).
    /// Kalman gain takes into consideration sensor noice. Next based on this value, value of predicted state and value of measurement,
    /// algorithm can calculate new state, and function return corrected latitude, longitude and altitude values in CLLocation object.
    private func kalmanFilter() -> CLLocation
    {
        let xk = A*xk1
        let Pk = ((A*Pk1)!*A.transpose()!)! + Qt
        
        let tmp = Pk!+R
        
        // Kalman gain (Kt)
        let Kt = Pk!*(tmp?.inverseMatrix())!
        
        let xt = xk! + (Kt! * (zt - xk!)!)!
        let Pt = (HCMatrixObject.getIdentityMatrix(dim: stateMDimension) - Kt!)! * Pk!
        
        self.xk1 = xt!
        self.Pk1 = Pt!
        
        let lat = xk1.matrix[0,0]
        let lon = xk1.matrix[2,0]
        let altitude = xk1.matrix[4,0]
        
        let kalmanCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat,longitude: lon), altitude: altitude, horizontalAccuracy: self.previousLocation.horizontalAccuracy, verticalAccuracy: self.previousLocation.verticalAccuracy, course:self.previousLocation.course, speed:self.previousLocation.speed, timestamp: previousMeasureTime)

        return kalmanCLLocation
    }
}
