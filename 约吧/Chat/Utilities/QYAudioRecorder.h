//
//  AudioRecorder.h
//  约吧
//
//  Created by 云菲 on 3/17/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef BOOL(^QYPrepareRecorderCompletion)();
typedef void(^QYStartRecorderCompletion)();
typedef void(^QYPauseRecorderCompletion)();
typedef void(^QYContinueRecorderCompletion)();
typedef void(^QYStopRecorderCompletion)(NSTimeInterval duration);
typedef void(^QYCancelRecorderCompletion)();
typedef void(^QYPeakPowerForChannel)(float peakPowerForChannel);

@interface QYAudioRecorder : NSObject
@property (nonatomic, copy, readonly) NSString *recordPath;
//@property (nonatomic, copy) NSString *recordDuration;

@property (nonatomic, readonly) NSTimeInterval currentTimeInterval;

@property (nonatomic, copy) QYPeakPowerForChannel peakPowerForChannel;
//@property (nonatomic, copy) QYStopRecorderCompletion maxTimeStopRecorderCompletion;

-(void)prepareToRecordWithPath:(NSString *)path completion:(QYPrepareRecorderCompletion)prepareRecorderCompletion;
-(void)startToRecordWithStartRecorderCompletion:(QYStartRecorderCompletion)startRecorderCompletion;
-(void)pauseToRecordWithPauseRecorderCompletion:(QYPauseRecorderCompletion)pauseRecorderCompletion;
-(void)continueToRecordWithContinueRecordCompletion:(QYContinueRecorderCompletion)continueRecorderCompletion;
-(void)stopRecordingWithStopRecorderCompletion:(QYStopRecorderCompletion)stopRecorderCompletion;
-(void)cancelRecordingWithCancelRecorderCompletion:(QYCancelRecorderCompletion)cancelRecorderCompletion;
@end
