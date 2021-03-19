package kevinchtsang.cordova.spf;

import android.Manifest;
import android.content.pm.PackageManager;
import android.util.Log;

import com.synthnet.spf.MicrophoneSignalProcess;
import com.synthnet.spf.SPFMode;
import com.synthnet.spf.SignalProcess;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class SPF extends CordovaPlugin {

    private static final String TAG = "cordova-plugin-spf";
    private static final int REQUEST_DYN_PERMS = 199;

    private CallbackContext authReqCallbackCtx;

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {

        if (action.equals("requestPermissions")) {
            authReqCallbackCtx = callbackContext;
            cordova.requestPermissions(this, REQUEST_DYN_PERMS, new String[]{Manifest.permission.RECORD_AUDIO, Manifest.permission.MODIFY_AUDIO_SETTINGS});
        } else if (action.equals("startCalibration")) {
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    MicrophoneSignalProcess.getInstance().startCalibration(new SignalProcess.OnCalibrated() {
                        @Override
                        public void onCalibrated(int status) {
                            MicrophoneSignalProcess.getInstance().stopCalibration();
                            callbackContext.success();
                        }
                    });
                }
            });
        } else if(action.equals("stopCalibration")) {
            MicrophoneSignalProcess.getInstance().stopCalibration();
            callbackContext.success();
        } else if (action.equals("startMeasurement")) {
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    MicrophoneSignalProcess.getInstance().startAnalyze(
                            new SignalProcess.OnPeakFound() {
                                @Override
                                public void onResult(int peakFlowRate) {
                                    Log.d("SPF-Lib", "Peak Flow Rate: " + peakFlowRate);
                                    try {
                                        JSONObject retval = new JSONObject();
                                        retval.put("state", "completed");
                                        retval.put("peakFlowRate", peakFlowRate);
                                        callbackContext.success(retval);
                                    } catch (Exception ex) {
                                        callbackContext.error(ex.getMessage());
                                    }
                                }
                            },
                            new SignalProcess.OnModeChanged() {
                                @Override
                                public void onModeChanged(SPFMode previousMode, SPFMode mode) {
                                    // The SPFMode enum has three values that are related to finding a peak: MODE_LISTEN, MODE_UP and MODE_TRACKING.
                                    // The processing starts in listening mode.
                                    // When the blade starts spinning the mode changes to "up mode" and the callback is invoked with MODE_LISTEN and MODE_UP.
                                    // If there was no actual blow but the blade stops again we get back to the listening mode. The callback is invoked again but this time previousMode is MODE_UP and mode is MODE_LISTEN.
                                    // If there was a blow and a peak flow value can be determined then the up mode transitions to tracking mode and when the blade stops, tracking mode transitions to listening mode.
                                    // Note, that it's very important to wait for the blade to stop (getting back to listening mode) before starting a new blow.
                                    Log.d("SPF-Lib", "Processing has transitioned from " + previousMode +
                                            " to " + mode);
                                    try {
                                        JSONObject retval = new JSONObject();
                                        if (mode == SPFMode.MODE_LISTENING) {
                                            retval.put("state", "listening");
                                        } else if (mode == SPFMode.MODE_UP) {
                                            retval.put("state", "spinning");
                                        } else if (mode == SPFMode.MODE_TRACKING) {
                                            retval.put("state", "computing");
                                        } else if (mode == SPFMode.MODE_CALIBRATION) {
                                            retval.put("state", "calibrating");
                                        } else if (mode == SPFMode.MODE_SKIP) {
                                            retval.put("state", "skipping");
                                        } else if (mode == SPFMode.MODE_DONE) {
                                            retval.put("state", "done");
                                        }

                                        if (previousMode == SPFMode.MODE_LISTENING) {
                                            retval.put("previousState", "listening");
                                        } else if (previousMode == SPFMode.MODE_UP) {
                                            retval.put("previousState", "spinning");
                                        } else if (previousMode == SPFMode.MODE_TRACKING) {
                                            retval.put("previousState", "computing");
                                        } else if (previousMode == SPFMode.MODE_CALIBRATION) {
                                            retval.put("previousState", "calibrating");
                                        } else if (previousMode == SPFMode.MODE_SKIP) {
                                            retval.put("previousState", "skipping");
                                        } else if (previousMode == SPFMode.MODE_DONE) {
                                            retval.put("previousState", "done");
                                        }
                                        callbackContext.success(retval);
                                    } catch (Exception ex) {
                                        callbackContext.error(ex.getMessage());
                                    }
                                }
                            }
                    );
                }
            });

        } else if(action.equals("stopMeasurement")) {
            MicrophoneSignalProcess.getInstance().stopAnalyze();
            callbackContext.success();
        }

        return true;
    }

    // called when the dynamic permissions are asked
    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        if (requestCode == REQUEST_DYN_PERMS) {
            for (int i = 0; i < grantResults.length; i++) {
                if (grantResults[i] == PackageManager.PERMISSION_DENIED) {
                    String errmsg = "Permission denied ";
                    for (String perm : permissions) {
                        errmsg += " " + perm;
                    }
                    authReqCallbackCtx.error("Permission denied: " + permissions[i]);
                    return;
                }
            }
            // all dynamic permissions accepted!
            Log.i(TAG, "All dynamic permissions accepted");
            authReqCallbackCtx.success();
        }
    }
}