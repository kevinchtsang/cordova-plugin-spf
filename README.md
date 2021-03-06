# Cordova SPF Plugin

Cordova Plugin for smart peak flow (spf) meter by [Smart Respiratory Products Ltd](https://smartasthma.com/).


## Installation
This source code is incomplete and needs the SPF library from Smart Respiratory Products.

Clone or download this repository and add the missing SPF libraries as follows:

```
plugin root folder
└───lib
    └───ios
    │   └───spf_lib_modes.h
    │   └───libSPF-iOS-Lib.a
    │   └───MicrophoneSignalProcess.h
    │   └───WaveWriter.h
    └───android
        └───SPFLib-3.6.7.aar
        └───spf-calibration-3.6.7.apk

```

Then you can add the plugin inside your cordova project with:

```
cordova plugin add ../path-to-plugin/ --variable MICROPHONE_USAGE_DESCRIPTION='This app needs the microphone to read the smart peak flow meter'
```

Before updating this plugin publicly please make sure to remove the SPF libraries or make sure you have the permission to distribute those files.


## Use

The library gets the signals from the external device and get the measure of the peak flow through the audio interface. The library currently does not check that the external device is plugged in or not

Prepare two callbacks, one for success, the other for errors:
```
var successCallback = function (data) { console.log('OK', data) }
var errorCallback = function (data) { console.error('ERR', data) }
```

The plugin needs permissions to access the audio interface. On Android, an explicit call is created:
```
cordova.plugins.spf.requestPermissions(successCallback, errorCallback)
```
If permissions are denied, the errorCallback is called, otherwise the successCallback is called.

On iOS, you need to call any other function below to also trigger the permission request.

Start the calibration:
```
cordova.plugins.spf.startCalibration(successCallback, errorCallback)
```
The calibration stops by itself, but if you need to stop it before, you can call:
```
cordova.plugins.spf.stopCalibration(successCallback, errorCallback)
```

Start the measurement:
```
cordova.plugins.spf.startMeasurement(successCallback, errorCallback)
```

The callback has for argument a JSON object that looks like:
```
{
    previousState: 'listening',
    state: 'computing',
    peakFlowRate: 450
}
```

Possible states are: listening, spinning, computing, calibrating, skipping, done, completed.
The peakFlowRate is only passed when the state is completed.

A typical sequence of state transitions is like this:

{ previousState: "listening", state: "spinning" }
{ previousState: "spinning", state: "listening" }
{ previousState: "listening", state: "spinning" }
{ previousState: "spinning", state: "listening" }
{ previousState: "listening", state: "spinning" }
{ previousState: "spinning", state: "computing"}
{ state: "completed", peakFlowRate: 436 }

The measurement stops automatically when the peakflow is detected. You can stopt it before by calling:
```
cordova.plugins.spf.stopMeasurement(successCallback, errorCallback)
```


## Prototype App
The index.html and index.js contains a prototype app that tests the plugin functions.
