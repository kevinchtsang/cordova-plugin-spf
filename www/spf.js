/*global cordova, module*/

module.exports = {
    startCalibration: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback);
    },
    stopCalibration: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback);
    },
    startMeasurement: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback);
    },
    stopMeasurement: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback);
    }
};
