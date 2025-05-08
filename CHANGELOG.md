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

## 0.0.3
Version 0.0.3
Release Date December 15, 2024

Android implementation added

## 0.0.4
Version 0.0.4
Release Date: February 10, 2025

Fixed bug preventing data to be sent if no custom url was set on Android.

## 0.0.5
Version 0.0.5
Release Date: April 8, 2025

Fix issue related to CustomDomainUrl was removed. 
Native SDK upgraded to 1.0.18

## 0.0.6
Version 0.0.6
Release Date: April 24, 2025

Fix Crash related to URLSessionInstrumentation.
Navigation instument was removed form CoralogixOptions 
Native SDK upgraded to 1.0.20

## 0.0.7
Version 0.0.7
Release Date: May 8, 2025

Implemented the following:
* Before Send
* getLabels()
* getSessionId()
* isInitialized()
* setApplicationContext()

Native SDK upgraded to 1.0.21