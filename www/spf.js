/*global cordova, module*/

module.exports = {
    requestPermissions: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "SPF", "requestPermissions");
    },
    startCalibration: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "SPF", "startCalibration");
        cordova.exec(successCallback, errorCallback, "SPF", "SRPstartCalibration");
    },
    stopCalibration: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "SPF", "stopCalibration");
    },
    startMeasurement: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "SPF", "startMeasurement");
    },
    stopMeasurement: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "SPF", "stopMeasurement");
    }
};
