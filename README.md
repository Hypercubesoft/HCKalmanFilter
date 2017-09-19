[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/HCKalmanFilter.svg)](http://cocoapods.org/pods/HCKalmanFilter)
[![License](https://img.shields.io/cocoapods/l/HCKalmanFilter.svg?style=flat)](http://cocoapods.org/pods/HCKalmanFilter)
[![Platform](https://img.shields.io/cocoapods/p/HCKalmanFilter.svg?style=flat)](http://cocoapods.org/pods/HCKalmanFilter)
![Swift](https://img.shields.io/badge/%20in-swift%203.1-orange.svg)

![logo](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/HCKalmanFilterLogo.png)

**HCKalmanFilter** 是用 **Swift** 语言开发的开尔曼滤波算法的iOS实现库. HCKalmanFilter 库实现的开尔曼滤波算法用于处理从GPS接收器收到到的测量信号所画出的GPS轨迹的修正问题。该问题产生于当GPS信号差或精度太小时，GPS接收器接收到的坐标会产生大幅震荡的情况。如果你有类似问题或你需要一个柔顺丝滑的轨迹时，那么这个库就是你的正确选择。

![screenshot](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/Screenshots/HCKalmanFilterSC1.png)

![screenshot](https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/Images/Screenshots/HCKalmanFilterSC2.png)


## Getting Started

* 下载 HCKalmanFilter 项目并运行其中包含的实例iPhone App进行体验。
* 阅读安装向导，使用指南，也可以进一步学习算法本身(https://en.wikipedia.org/wiki/Kalman_filter)

## Installing

[CocoaPods](https://cocoapods.org/) 是用于Objective-C和Swift的依赖管理器，它可以帮你实现第三方库的安装使用的自动化，简化工作。使用该工具可以把 HCKalmanFilter安装到你的工程中。

### Podfile

要通过 CocoaPods集成 **HCKalmanFilter** 到你的Xcode项目中，需要在项目的 Podfile文件中加入以下配置语句:

```
target 'TargetName' do
  use_frameworks!
  pod 'HCKalmanFilter'
end
```

然后执行以下命令:

```
$ pod install
```

### With source code

下载本资源库, 然后把 HCKalmanAlgorithm 目录添加到你的项目里。


## 用法
**1.** 首先 import HCKalmanFilter 模块

```swift
import HCKalmanFilter
```

**2.** 初始化 HCKalmanFilter 对象

```swift
let hcKalmanFilter = HCKalmanAlgorithm(initialLocation: myInitialLocation)
```
* **myInitialLocation** 是轨迹的开始位置.


**3.** 调整 **rValue** 参数（若有必要）. **rValue** 参数 用于 噪声协方差矩阵. 默认值是29.0, 这是解决GPS 问题的推荐值, 用这个值可以提供最理想的精确度。但是你可以根据需要来调整这个值, 越高的 **rVaule** 参数越能提供更加平滑的轨迹，反之亦然。

```swift
hcKalmanFilter.rValue = 35.0
```

**4.** 在每一次GPS测量坐标出来后，需要根据当前坐标调用HCKalmanFilter对象的 **processState** 方法。

```swift
let kalmanLocation = hcKalmanFilter.processState(currentLocation: myCurrentLocation)
```
* **currentLocation** 是CLLocation，代表从GPS接收器收到的当前实际坐标.
* **kalmanLocation** 是一个CLLocation对象，是HCKalmanFilter算法对 **currentLocation** 经过计算后的坐标。然后你可以进一步使用这个修正过的坐标（ (比如在地图上画轨迹) 

**5.** 当你需要结束先前的轨迹并重新开始一段新轨迹的时候, 需要根据这次的开始位置调用**resetKalman** 方法, 然后再继续调用processState。

```swift
hcKalmanFilter.resetKalman(newStartLocation: myNewStartLocation)
```

* **myNewStartLocation** 是 CLLocation 对象，表示重新开始该算法时从GPS接收器接收到的当前坐标。
调用上述函数后, 你可以继续 **第 4 步**的动作。


### 完整示例

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

**HCKalmanFilter** 由 [Hypercube](http://hypercubesoft.com/)拥有并负责维护。

If you find any bug, please report it, and we will try to fix it ASAP.
