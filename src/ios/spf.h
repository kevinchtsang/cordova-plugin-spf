//
//  spf.h
//  spf
//
//  Created by Kevin Tsang on 10/12/2020.
//  Copyright © 2020 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MicrophoneSignalProcess.h"
#import <Cordova/CDV.h>

@interface spf : CDVPlugin <OnCalibrationFinished, OnPeakFound, OnModeChanges>

//@property (nonatomic, strong) NSObject<OnCalibrationFinished>* onFinish;

- (void)startCalibration:(CDVInvokedUrlCommand *)command;
- (void)stopCalibration:(CDVInvokedUrlCommand *)command;
- (void)startMeasurement:(CDVInvokedUrlCommand *)command;
- (void)stopMeasurement:(CDVInvokedUrlCommand *)command;

@end
