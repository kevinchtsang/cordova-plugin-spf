# Cordova SPF Plugin

Cordova Plugin for smart peak flow (spf) meter by [Smart Respiratory Products Ltd](https://smartasthma.com/).


## Usage
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
cordova plugin add ../path-to-plugin/
```

Before updating this plugin publicly please make sure to remove the SPF libraries or make sure you have the permission to distribute those files.

## Prototype App
The index.html and index.js contains a prototype app that tests the plugin functions.
