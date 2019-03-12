//
//  iFlyWavConverter.h
//  TripStickyInScene
//
//  Created by JiangZhuo on 7/15/17.
//  Copyright © 2017 qunar. All rights reserved.
//
#import <iflyMSC/iflyMSC.h>
@import AVFoundation;
@import SystemConfiguration;
@import Foundation;
@import AudioToolbox;

@interface iFlyWavConverter : NSObject <IFlySpeechSynthesizerDelegate>

+ (void)initUtility;

- (void)getPathTextToSpeech:(NSString *)text completionHandler:(void (^)(NSString *))block;

@end
