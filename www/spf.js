/*global cordova, module*/

module.exports = {
    startCalibrationSRP: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "spf", "startCalibrationSRP");
    },
    stopCalibrationSRP: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "spf", "stopCalibrationSRP");
    },
    startMeasurementSRP: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "spf", "startMeasurementSRP");
    },
    stopMeasurementSRP: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "spf", "stopMeasurementSRP");
    }
};
