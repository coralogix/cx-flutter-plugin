## 0.0.1

* TODO: Describe initial release.

## 0.0.2
Version 0.0.2
Release Date: November 25, 2024

Enhancements
SDK Initialization Sampling: Introduced sdkSampler, allowing configuration of the SDK's initialization rate as a percentage (0-100%).

FPS Sampling Rate Configuration: Added mobileVitalsFPSSamplingRate to set the frequency of FPS sampling per hour, with a default of once every minute.

Instrumentation Control: Implemented instrumentations, enabling selective activation or deactivation of specific instruments during runtime. By default, all instrumentations are active.

IP Data Collection Toggle: Added collectIPData to control the collection of user IP addresses and geolocation data, defaulting to true.
