Pod::Spec.new do |s|

s.platform = :ios
s.name             = "HCKalmanFilter"
s.version          = "1.2.3"
s.summary          = "HCKalmanFilter is Swift implementation of Kalman filter algorithm intended to solve problem with GPS tracking"

s.description      = <<-DESC
HCKalmanFilter is a delightful library for iOS written in Swift. HCKalmanFilter library was created for the implementation of Kalman filter algorithm for the problem of GPS tracking and correction of trajectories obtained based on the measurement of the GPS receiver. The problem occurs in the case of a large oscillation of the coordinates received from the GPS receiver when the accuracy is very small or the GPS signal is very bad. If you have this kind of problem and you need a fluid trajectory of movement without big peaks and deviations, this library is the right choice for you.
DESC

s.homepage         = "https://github.com/Hypercubesoft/HCKalmanFilter"
s.license          = { :type => "MIT", :file => "LICENSE" }
s.author           = { "Hypercubesoft" => "office@hypercubesoft.com" }
s.source           = { :git => "https://github.com/Hypercubesoft/HCKalmanFilter.git", :tag => "#{s.version}"}

s.ios.deployment_target = "9.0"
s.source_files = "HCKalmanFilter/*"

s.dependency 'Surge', '~> 2.3.0'

end