//
//  spf.m
//  spf
//
//  Created by Kevin Tsang on 10/12/2020.
//  Copyright © 2020 Kevin. All rights reserved.
//

#import "spf.h"

@implementation spf

- (void) startCalibrationSRP:(CDVInvokedUrlCommand*)command
{
    
    
//    id <OnCalibrationFinished> onFinish;
    NSObject<OnCalibrationFinished>* onFinish;
    [[MicrophoneSignalProcess getInstance] startCalibration:onFinish];
//    int status = [onFinish status];
    
    CDVPluginResult* result;
    if (onFinish == 0) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"Error in Calibration"];
    } else {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) stopCalibrationSRP:(CDVInvokedUrlCommand*)command
{
    [[MicrophoneSignalProcess getInstance] stopCalibration];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) startMeasurementSRP:(CDVInvokedUrlCommand*)command
{
//    id <OnPeakFound> peak;
    NSObject<OnPeakFound>* peakFound;
    NSObject<OnModeChanges>* mode;

    bool peak = [[MicrophoneSignalProcess getInstance] startAnalyze:peakFound modeChangeListener:mode];
    
    
    CDVPluginResult* result;
    if (peak == 0) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"Error in Measurement"];
    } else {
        NSString* message = [NSString stringWithFormat:@"%i",peak];
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK
                  messageAsString:message];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) stopMeasurementSRP:(CDVInvokedUrlCommand*)command
{
    
    [[MicrophoneSignalProcess getInstance] stopAnalyze];
    [[MicrophoneSignalProcess getInstance] close];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
