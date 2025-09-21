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

## 0.0.8
Version 0.0.8
Release Date: May 27, 2025

Added Android support for newly added methods:
* getLabels()
* getSessionId()
* isInitialized()
* setApplicationContext()
* Disable swizzeling for iOS (NetworkOnly)

Added Android support for the beforeSend callback
Breaking changes:
* The 'CxExporterOptions' class 'beforeSend' callback is now asynchronous.

Native iOS SDK upgraded to 1.0.22
Native Android SDK upgraded to 2.4.3

## 0.0.9
Version 0.0.9
Release Date: May 28, 2025

* Added Android support for the `beforeSend` operation
* Bug fixes and improvements

Native Android SDK upgraded to 2.4.4

## 0.0.10
Version 0.0.10
Release Date: June 17, 2025

* Bug fixes - beforeSend not sending instrumentaion in android and iOS
* Crash fix on Android

Native Android SDK upgraded to 2.4.41
Native iOS SDK upgraded to 1.0.23

## 0.0.11
Version 0.0.11
Release Date: June 22, 2025

* Bug fixes
Native iOS SDK upgraded to 1.0.24

## 0.0.12
Version 0.0.12
Release Date:

* New Feature add support for proxyUrl
* New Feature traceParentInHeader (iOS Only)
Native iOS SDK upgraded to 1.0.26

## 0.0.13
Version 0.0.13
Release Date: July 24, 2025

* fix: Android plugin now respect setting the userActions interaction to false and thus actually turning it off
Native Android SDK upgraded to 2.4.44

## 0.0.14
Version 0.0.14
Release Date: Aug 10, 2025

Native iOS SDK upgraded to 1.1.2

## 0.0.15
Version 0.0.15
Release Date: Spt 21, 2025

Native iOS SDK upgraded to 1.2.5
