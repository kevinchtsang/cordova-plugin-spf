//
//  spf.m
//  spf
//
//  Created by Kevin Tsang on 10/12/2020.
//  Copyright © 2020 Kevin. All rights reserved.
//

#import "spf.h"

@implementation spf

CDVPluginResult* result;
static NSString* myAsyncCallbackId = nil;

- (void)onFinish:(int)status {
    [[MicrophoneSignalProcess getInstance] stopCalibration];
    
    if (status == 0) {
//    if (status == YES) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"Error in Calibration"];
    } else {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:result callbackId:myAsyncCallbackId];
    
    myAsyncCallbackId = nil;
}

- (void)onResult:(int)peak {
    NSLog(@"Peak Flow Rate: %i", peak);
    [[MicrophoneSignalProcess getInstance] stopAnalyze];
    
    id sharedKeySet = [NSDictionary sharedKeySetForKeys:@[@"previousState", @"state", @"peakFlowRate"]];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeySet];

    retval[@"state"] = @"completed";
    retval[@"peakFlowRate"] = [NSNumber numberWithInt:peak];
    if (peak == 0) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"Error in Measurement"];
    } else {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK
                  messageAsDictionary:retval];
        [self.commandDelegate sendPluginResult:result callbackId:myAsyncCallbackId];
        myAsyncCallbackId = nil;
    }
}

- (void)onModeChanged:(spf_mode)previousMode andNewMode:(spf_mode) mode {
    NSLog(@"Processing has transitioned from %u to %u", previousMode, mode);
    
    id sharedKeySet = [NSDictionary sharedKeySetForKeys:@[@"previousState", @"state", @"peakFlowRate"]];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeySet];
    
    if (mode == (spf_mode) MODE_LISTENING) {
        retval[@"state"] = @"listening";
    } else if (mode == (spf_mode) MODE_UP) {
        retval[@"state"] = @"spinning";
    } else if (mode == (spf_mode) MODE_TRACKING) {
        retval[@"state"] = @"computing";
    } else if (mode == (spf_mode) MODE_CALIBRATION) {
        retval[@"state"] = @"calibrating";
    } else if (mode == (spf_mode) MODE_SKIP) {
        retval[@"state"] = @"skipping";
    } else if (mode == (spf_mode) MODE_DONE) {
        retval[@"state"] = @"done";
    }

    if (previousMode == (spf_mode) MODE_LISTENING) {
        retval[@"previousState"] = @"listening";
    } else if (previousMode == (spf_mode) MODE_UP) {
        retval[@"previousState"] = @"spinning";
    } else if (previousMode == (spf_mode) MODE_TRACKING) {
        retval[@"previousState"] = @"computing";
    } else if (previousMode == (spf_mode) MODE_CALIBRATION) {
        retval[@"previousState"] = @"calibrating";
    } else if (previousMode == (spf_mode) MODE_SKIP) {
        retval[@"previousState"] = @"skipping";
    } else if (previousMode == (spf_mode) MODE_DONE) {
        retval[@"previousState"] = @"done";
    }
    
//    if (mode == 0) {
//        retval[@"state"] = @"listening";
//    } else if (mode == 1) {
//        retval[@"state"] = @"spinning";
//    } else if (mode == 2) {
//        retval[@"state"] = @"computing";
//    } else if (mode == 5) {
//        retval[@"state"] = @"calibrating";
//    } else if (mode == 4) {
//        retval[@"state"] = @"skipping";
//    } else if (mode == 6) {
//        retval[@"state"] = @"done";
//    }
//
//    if (previousMode == 0) {
//        retval[@"previousState"] = @"listening";
//    } else if (previousMode == 1) {
//        retval[@"previousState"] = @"spinning";
//    } else if (previousMode == 2) {
//        retval[@"previousState"] = @"computing";
//    } else if (previousMode == 5) {
//        retval[@"previousState"] = @"calibrating";
//    } else if (previousMode == 4) {
//        retval[@"previousState"] = @"skipping";
//    } else if (previousMode == 6) {
//        retval[@"previousState"] = @"done";
//    }
//    if (myAsyncCallbackId == nil) {
//        CDVPluginResult* result = [CDVPluginResult
//                                   resultWithStatus:CDVCommandStatus_ERROR
//                                   messageAsString:@"Error in Mode Change"];
//    } else {
//    if (myAsyncCallbackId != nil) {
    result = [CDVPluginResult
              resultWithStatus:CDVCommandStatus_OK
              messageAsDictionary:retval];
    
    [result setKeepCallbackAsBool:TRUE];
    
    [self.commandDelegate sendPluginResult:result callbackId:myAsyncCallbackId];
}

// internal function that acquires the Bluetooth microphone if available first and the regular one otherwise
- (bool) connectMicrophone
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // activate session
    [session setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [session setActive:YES error:nil];
    
    // find inputs
    NSArray* inputs = [session availableInputs];
    NSPredicate *btPortPredicate = [NSPredicate predicateWithFormat:@"portType ==%@",@"BluetoothHFP"];
    NSArray *btInputs = [inputs filteredArrayUsingPredicate:btPortPredicate];
    if ([btInputs count] > 1) {
        NSLog(@"Too many Bluetooth microphones connected");
        return NO;
    };
    
    // try to connect Bluetooth first
    for (AVAudioSessionPortDescription *input in inputs) {
        NSLog(@"port type = %@",input.portType);
        if ([input.portType isEqual:AVAudioSessionPortBluetoothHFP] && [input.portName  isEqual: @"SmartPeakFlow"]) {
            [session setPreferredInput:input error:nil];
            NSLog(@"Bluetooth SmartPeakFlow connected");
            return YES;
        };
    }
    
    // then try to connect to Jack
    for (AVAudioSessionPortDescription *input in inputs) {
        NSLog(@"port type = %@",input.portType);
        if ([input.portType isEqual:AVAudioSessionPortHeadsetMic]) {
            [session setPreferredInput:input error:nil];
            NSLog(@"Regular mic connected");
            return YES;
        };
    }
    NSLog(@"No microphone available");
    return NO;
}


- (void) requestPermissions:(CDVInvokedUrlCommand*)command
{
    // myAsyncCallbackId = command.callbackId;
    result = [CDVPluginResult
              resultWithStatus:CDVCommandStatus_NO_RESULT];
    // [result setKeepCallbackAsBool:TRUE];

    switch ([[AVAudioSession sharedInstance] recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        case AVAudioSessionRecordPermissionDenied:
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_ERROR
                      messageAsString:@"Access to microphone denied"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        case AVAudioSessionRecordPermissionUndetermined:
            [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    // need to wait for this result
                    result = [CDVPluginResult
                              resultWithStatus:CDVCommandStatus_OK];
                } else {
                    result = [CDVPluginResult
                              resultWithStatus:CDVCommandStatus_ERROR
                              messageAsString:@"Access to microphone denied"];
                }
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                // myAsyncCallbackId = nil;
            }];
            return;
    };
}

- (void) SPFstartCalibration:(CDVInvokedUrlCommand*)command
{
    bool connection = [self connectMicrophone];
    
    // only calibrate if connection to mic found
    if (connection) {
        myAsyncCallbackId = command.callbackId;
        [self.commandDelegate runInBackground:^{
            [[MicrophoneSignalProcess getInstance] startCalibration:self];
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_NO_RESULT];
            [result setKeepCallbackAsBool:TRUE];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    } else {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"No suitable microphone connection found"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void) stopCalibration:(CDVInvokedUrlCommand*)command
{
    myAsyncCallbackId = nil;
    
    [[MicrophoneSignalProcess getInstance] stopCalibration];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) startMeasurement:(CDVInvokedUrlCommand*)command
{
    bool connection = [self connectMicrophone];
    
    // only measure if connection to mic found
    if (connection) {
        myAsyncCallbackId = command.callbackId;
        [self.commandDelegate runInBackground:^{
            [self connectMicrophone];
            [[MicrophoneSignalProcess getInstance] startAnalyze:self modeChangeListener:self];
            CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_NO_RESULT];
            [result setKeepCallbackAsBool:TRUE];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    } else {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"No suitable microphone connection found"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void) stopMeasurement:(CDVInvokedUrlCommand*)command
{    
    [[MicrophoneSignalProcess getInstance] stopAnalyze];
//    [[MicrophoneSignalProcess getInstance] close];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    myAsyncCallbackId = nil;
}

@end
