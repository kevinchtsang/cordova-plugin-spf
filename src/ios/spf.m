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

- (bool) btConnection
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // activate session
    [session setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [session setActive:YES error:nil];
    
    // find inputs
    NSArray* inputs = [session availableInputs];
    NSPredicate *btPortPredicate = [NSPredicate predicateWithFormat:@"portType ==%@",
                                    @"BluetoothHFP"];
    NSArray *btInputs = [inputs filteredArrayUsingPredicate:btPortPredicate];
    if ([btInputs count] > 1) {
        NSLog(@"Too many Bluetooth");
        return NO;
    };
    
    // try to connect Bluetooth first
    for (AVAudioSessionPortDescription *input in inputs) {
        NSLog(@"port type = %@",input.portType);
        if ([input.portType isEqual:AVAudioSessionPortBluetoothHFP] && [input.portName  isEqual: @"SmartPeakFlow"]) {
            [session setPreferredInput:input error:nil];
            NSLog(@"Connected Bluetooth");
            return YES;
        };
    }
    
    // then try to connec to Jack
    for (AVAudioSessionPortDescription *input in inputs) {
        NSLog(@"port type = %@",input.portType);
        if ([input.portType isEqual:AVAudioSessionPortHeadsetMic]) {
            [session setPreferredInput:input error:nil];
            NSLog(@"Connected Headset mic");
            return YES;
        };
    }
    NSLog(@"No Connection");
    return NO;
}


- (void) requestPermissions:(CDVInvokedUrlCommand*)command
{
    myAsyncCallbackId = nil;
    
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            NSLog(@"mic ok");
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            break;
        case AVAudioSessionRecordPermissionDenied:
            NSLog(@"mic deny");
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_ERROR
                      messageAsString:@"Microphone Denied"];
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    NSLog(@"mic allow");
                    result = [CDVPluginResult
                              resultWithStatus:CDVCommandStatus_OK];
                } else {
                    NSLog(@"mic denied");
                    result = [CDVPluginResult
                              resultWithStatus:CDVCommandStatus_ERROR
                              messageAsString:@"Microphone Denied"];
                }
            }];
            break;
        default:
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_ERROR
                      messageAsString:@"Microphone Unknown"];
            break;
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) SPFstartCalibration:(CDVInvokedUrlCommand*)command
{
    bool connection = [self btConnection];
    
    // only calibrate if connection found
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
                  messageAsString:@"Error in Calibration: no connection found"];
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
    
    myAsyncCallbackId = command.callbackId;
    [self.commandDelegate runInBackground:^{
        [self btConnection];
        [[MicrophoneSignalProcess getInstance] startAnalyze:self modeChangeListener:self];
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_NO_RESULT];
        [result setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void) stopMeasurement:(CDVInvokedUrlCommand*)command
{
    myAsyncCallbackId = nil;
    
    [[MicrophoneSignalProcess getInstance] stopAnalyze];
//    [[MicrophoneSignalProcess getInstance] close];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
