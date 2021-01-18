# Cordova SPF Plugin
Cordova Plugin for smart peak flow (spf) based on [cordova-plugin-hello](https://github.com/don/cordova-plugin-hello).

The plugin will use the library provided by [Smart Respiratory Products Ltd](https://smartasthma.com/)

The library and binary files will need to be added and organised as follows:
```
com.example.spf
└───SpfPlugin
│   └───lib
│   │   └───spf_lib_modes.h
│   └───libSPF-iOS-Lib.a
│   └───MicrophoneSignalProcess.h
│   └───spf.h
│   └───spf.m
│   └───WaveWriter.h
```
If running with xcode, add the `libSPF-iOS-Lib.a` to "Link Binary with Library" under the "Build Phases" settings of your xcode app.

If cordova is not compling, it may be due to iOS version. Try to use an older version, for example iOS 6.0.0
```
cordova platform remove ios
cordova platform add ios@6.0.0
```
