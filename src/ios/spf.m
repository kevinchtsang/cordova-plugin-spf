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
    [[MicrophoneSignalProcess getInstance] startCalibration:self];
    
    NSInteger status = [[MicrophoneSignalProcess onFinish] status];
    
    if (status == 0) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Error in Calibration"];
    } else {
        CDVPluginResult* result = [CDVPluginResult
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
    [[MicrophoneSignalProcess getInstance] startAnalyze:self modeChangeListener:self];
    
    NSInteger peak = [[MicrophoneSignalProcess onResult] peak];
    
    if (status == 0) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Error in Measurement"];
    } else {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:peak];
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
