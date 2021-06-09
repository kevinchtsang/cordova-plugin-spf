document.addEventListener('deviceready', onDeviceReady, false);
document.getElementById("requestPermissionsButton").addEventListener("click", requestPermissionsButton);
document.getElementById("startCalibrationButton").addEventListener("click", startCalibrationButton);
document.getElementById("stopCalibrationButton").addEventListener("click", stopCalibrationButton);
document.getElementById("startMeasurementButton").addEventListener("click", startMeasurementButton);
document.getElementById("stopMeasurementButton").addEventListener("click", stopMeasurementButton);

function onDeviceReady () {
    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
}

// permission is required for android
function requestPermissionsButton () {
    console.log("requesting permissions");
    document.getElementById("peakflow").innerHTML = "get permission";

    var success = function (message) {
        alert(message);
    }

    var failure = function (message) {
        console.log(message)
        alert("Error calling SPF Plugin - Request Permissions");
    }
    cordova.plugins.spf.requestPermissions(success, failure);
}

function startCalibrationButton () {
    console.log("start calibration");
    document.getElementById("peakflow").innerHTML = "start calibration";

    var success = function (message) {
        alert(message);
    }

    var failure = function (message) {
        console.log(message)
        alert("Error calling SPF Plugin - Start Calibrate");
    }
    cordova.plugins.spf.startCalibration(success, failure);
}

function stopCalibrationButton () {
    console.log("stop calibration");
    document.getElementById("peakflow").innerHTML = "stop calibration";
    var success = function (message) {
        alert(message);
    }

    var failure = function () {
        alert("Error calling SPF Plugin - Stop Calibrate");
    }
    cordova.plugins.spf.stopCalibration(success, failure);
}

function startMeasurementButton () {
    console.log("start measurement");
    document.getElementById("peakflow").innerHTML = "start measurement";
    var success = function (message) {
        console.log(message);
        document.getElementById("peakflow").innerHTML = message;
    }

    var failure = function (message) {
        console.log(message)
        console.log("Error calling SPF Plugin - Start Measure");
    }
    cordova.plugins.spf.startMeasurement(success, failure);
}

function stopMeasurementButton () {
    console.log("stop measurement");
    var success = function (message) {
        alert(message);
    }

    var failure = function () {
        alert("Error calling SPF Plugin - Stop Measure");
    }
    cordova.plugins.spf.stopMeasurement(success, failure);
}

