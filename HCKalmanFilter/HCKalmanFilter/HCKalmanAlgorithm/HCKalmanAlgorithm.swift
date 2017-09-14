//
//  HCKalmanAlgorithm.swift
//  HCKalmanFilter
//
//  Created by Hypercube on 4/27/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation
import MapKit

open class HCKalmanAlgorithm
{
    //MARK: - HCKalmanAlgorithm properties
    
    /// The dimension M of the state vector.
    private let stateMDimension = 4
    
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
    /// **Sensor Noise Covariance Matrix (R)** is mathematical representation of sensor noice of Kalman Algorithm.
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
        
        self.xk1 = HCMatrixObject(n: stateMDimension, m: stateNDimension)
        self.Pk1 = HCMatrixObject(n: stateMDimension, m: stateMDimension)
        self.A = HCMatrixObject(n: stateMDimension, m: stateMDimension)
        self.Qt = HCMatrixObject(n: stateMDimension, m: stateMDimension)
        self.R = HCMatrixObject(n: stateMDimension, m: stateMDimension)
        self.zt = HCMatrixObject(n: stateMDimension, m: stateNDimension)
        
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
        previousLocation = CLLocation(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)
        
        // Set Previous State Matrix
        // xk1 -> [ initial_lat  lat_velocity = 0.0  initial_lon  lon_velocity = 0.0 ]T
        xk1.setMatrix(matrix: [[initialLocation.coordinate.latitude],[0.0],[initialLocation.coordinate.longitude],[0.0]])
        
        // Set initial Covariance Matrix for Previous State
        Pk1.setMatrix(matrix: [[0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0]])
        
        // Prediction Step Matrix initialization
        A.setMatrix(matrix: [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
        
        // Sensor Noise Covariance Matrixinitialization
        R.setMatrix(matrix: [[_rValue,0,0,0],[0,_rValue,0,0],[0,0,_rValue,0],[0,0,0,_rValue]])
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
    /// - returns: CLLocation object with corrected latitude and longitude values
    
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
        A.setMatrix(matrix: [[1,Double(timeInterval),0,0],[0,1,0,0],[0,0,1,Double(timeInterval)],[0,0,0,1]])
        
        // Set Acceleration Noise Magnitude Matrix based on new timeInterval and sigma values
        Qt.setMatrix(matrix: self.accelerationNoiseMagnitudeMatrix(timeInterval))
        
        // Calculate velocity components separated by the axes (x and y). 
        // This is value of velocity between previous and current location.
        // Distance traveled from the previous to the current location divided by timeInterval between two measurement.
        let velocityXComponent = (previousLocation.coordinate.latitude - currentLocation.coordinate.latitude)/timeInterval
        let velocityYComponent = (previousLocation.coordinate.longitude - currentLocation.coordinate.longitude)/timeInterval
        
        // Set Measured State Vector; current latitude and longitude and velocity separated by the latitude velocity and longitude velocity
        zt.setMatrix(matrix: [[currentLocation.coordinate.latitude],[velocityXComponent],[currentLocation.coordinate.longitude],[velocityYComponent]])
        
        // Set previous Location and Measure Time for next step of processState function.
        previousLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        previousMeasureTime = newMeasureTime
        
        // Return value of kalmanFilter
        return self.kalmanFilter()
    }
    
    /// Calculate Acceleration Noise Magnitude Matrix based on new timeInterval and sigma values
    private func accelerationNoiseMagnitudeMatrix(_ timeInterval:TimeInterval) -> [[Double]]
    {
        var matrix = [[Double]]()
        matrix.append([sigma*(Double(pow(Double(timeInterval), Double(4)))/4.0),sigma*(Double(pow(Double(timeInterval), Double(3)))/2.0),0,0])
        matrix.append([sigma*(Double(pow(Double(timeInterval), Double(3)))/2.0),sigma*(Double(pow(Double(timeInterval), Double(2)))),0,0])
        matrix.append([0,0,sigma*(Double(pow(Double(timeInterval), Double(4)))/4.0),sigma*(Double(pow(Double(timeInterval), Double(3)))/2.0)])
        matrix.append([0,0,sigma*(Double(pow(Double(timeInterval), Double(3)))/2.0),sigma*(Double(pow(Double(timeInterval), Double(2))))])
        return matrix
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
    /// algorithm can calculate new state, and function return corrected latitude and longitude values in CLLocation object.
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
        
        let lat = xk1.matrix[0][0]
        let lon = xk1.matrix[2][0]
        
        return CLLocation(latitude: lat, longitude: lon)
    }
}
