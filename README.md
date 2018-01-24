[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/HCKalmanFilter.svg)](http://cocoapods.org/pods/HCKalmanFilter)
[![License](https://img.shields.io/cocoapods/l/HCKalmanFilter.svg?style=flat)](http://cocoapods.org/pods/HCKalmanFilter)
[![Platform](https://img.shields.io/cocoapods/p/HCKalmanFilter.svg?style=flat)](http://cocoapods.org/pods/HCKalmanFilter)
![Swift](https://img.shields.io/badge/%20in-swift%203.1-orange.svg)

![logo](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/HCKalmanFilterLogo.png)

**HCKalmanFilter** is a delightful library for iOS written in **Swift**. HCKalmanFilter library was created for the implementation of Kalman filter algorithm for the problem of GPS tracking and correction of trajectories obtained based on the measurement of the GPS receiver. The problem occurs in the case of a large oscillation of the coordinates received from the GPS receiver when the accuracy is very small or the GPS signal is very bad. If you have this kind of problem and you need a fluid trajectory of movement without big peaks and deviations, this library is the right choice for you.

![screenshot](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/Screenshots/HCKalmanFilterSC1.png)

![screenshot](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/Screenshots/HCKalmanFilterSC2.png)

## Change Log

# 1.2.0

* In this version, we have upgraded the matrix processing functions within our class HCMatrixObject which now use core functions of the [Surge Library](https://github.com/mattt/Surge). It will greatly accelerate the processing of data and lead to faster results being obtained by the algorithm.
* We fixed small bug because of which it was not possible to build the example project.

# 1.1.0

* In this version, we added another new functionality in addition to small bug fixes.

* At the request of the HCKalmanFilter library user, we decided that in addition to the correction values for latitude and longitude, we should add the correction of the **altitude**.

Now you can easily get the corrected value for altitude in the following way:

```swift
...
let kalmanLocation = hcKalmanFilter.processState(currentLocation: myLocation)
print(kalmanLocation.altitude)
...

```

## Getting Started

* Download HCKalmanFilter Sample project, open HCKalmanFilter Sample folder via Terminal and run the following command:

    ```
    $ pod install
    ```
    This will install all necessary dependencies for this sample project. After you have installed all necessary dependencies, open HCKalmanFilter Sample.xcworkspace and try out the included iPhone example app.

* Read the Installation guide, Usage guide, or [other articles on the Wiki about Kalman Filter Algorithm](https://en.wikipedia.org/wiki/Kalman_filter)

## Installing

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like HCKalmanFilter in your projects.

### Podfile

To integrate **HCKalmanFilter** into your Xcode project using CocoaPods, specify it in your Podfile:

```
target 'TargetName' do
  use_frameworks!
  pod 'HCKalmanFilter'
end
```

Then, run the following command:

```
$ pod install
```

### With source code

Download repository, then add HCKalmanAlgorithm directory to your project.


## Usage
**1.** First import HCKalmanFilter module

```swift
import HCKalmanFilter
```

**2.** After installing and importing Kalman Filter library it is necessary to initialize the HCKalmanFilter object before using it.

```swift
let hcKalmanFilter = HCKalmanAlgorithm(initialLocation: myInitialLocation)
```
* **myInitialLocation** is the location where the tracking starts.


**3.** if necessary, it is possible to correct the value of the **rValue** parameter. **rValue** parameter is value for Sensor Noise Covariance Matrix. The default value is 29.0, this is the recommended value for the GPS problem, with this value filter provides optimal accuracy. This value can be adjusted depending on the needs, the higher value of **rVaule** variable will give greater roundness trajectories, and vice versa.

```swift
hcKalmanFilter.rValue = 35.0
```

**4.** After initialization and eventual correction of **rValue** parameter, after each next measurement of the coordinates from the GPS receiver, it is necessary to call **processState** function of the HCKalmanFilter object with current coordinates.

```swift
let kalmanLocation = hcKalmanFilter.processState(currentLocation: myCurrentLocation)
```
* **currentLocation** is CLLocation object which represents the actual coordinates received from the GPS receiver.
* **kalmanLocation** is CLLocation object which represents coordinates obtained by processing **currentLocation** with HCKalmanFilter algorithm. You can now use the corrected coordinates for further purposes (for example, to plot the path of the object you are tracking...) 

**5.** In case you need to stop tracking and then restart it, it is necessary to call **resetKalman** function with new start location, before continuing with the processing of the measured coordinates.

```swift
hcKalmanFilter.resetKalman(newStartLocation: myNewStartLocation)
```

* **myNewStartLocation** is CLLocation object which represents the actual coordinates received from the GPS receiver at the moment of restarting the algorithm.

After calling the restart function, you can continue to **repeat the steps under the number 4**.


### Example of usage

```swift
var resetKalmanFilter: Bool = false
var hcKalmanFilter: HCKalmanAlgorithm?

...

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
{
    var myLocation: CLLocation = locations.first!
    
    if hcKalmanFilter == nil {
       self.hcKalmanFilter = HCKalmanAlgorithm(initialLocation: myLocation)
    }
    else {
        if let hcKalmanFilter = self.hcKalmanFilter {
            if resetKalmanFilter == true {
                hcKalmanFilter.resetKalman(newStartLocation: myLocation)
                resetKalmanFilter = false
            }
            else {
                let kalmanLocation = hcKalmanFilter.processState(currentLocation: myLocation)
                print(kalmanLocation.coordinate)
            }
        }
    }
}

```

## Credits

**HCKalmanFilter** is owned and maintained by the [Hypercube](http://hypercubesoft.com/).

If you find any bug, please report it, and we will try to fix it ASAP.
