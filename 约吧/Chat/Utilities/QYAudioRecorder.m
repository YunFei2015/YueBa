//
//  AudioRecorder.m
//  约吧
//
//  Created by 云菲 on 3/17/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYAudioRecorder.h"
#import <UIKit/UIKit.h>

@interface QYAudioRecorder () <AVAudioRecorderDelegate>{
//    NSTimer *_timer;
    BOOL _isPause;
//#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
//    UIBackgroundTaskIdentifier _backgroundIdentifier;
//#endif
}
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (copy, nonatomic, readwrite) NSString *recordPath;
@property (nonatomic, readwrite) NSTimeInterval currentTimeInterval;
@property (strong, nonatomic) NSTimer *timer;


@end

@implementation QYAudioRecorder
-(instancetype)init{
    self = [super init];
    if (self) {
//#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
//        _backgroundIdentifier = UIBackgroundTaskInvalid;
//#endif
    }
    return self;
}

-(void)dealloc{
    [self stopRecording];
    self.recordPath = nil;
}

-(void)cancelRecording{
    if (!_recorder) {
        return;
    }

    if (_recorder.isRecording) {
        [_recorder stop];
        NSError *error;
        //AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation 恢复其它之前被中断的audio session
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (error) {
            NSLog(@"%@ %ld %@", [error domain], [error code], [[error userInfo] description]);
        }
    }
    _recorder = nil;
}

-(void)stopRecording{
    [self cancelRecording];
    [self resetTimer];
}

-(void)pauseRecording{
    [_recorder pause];
    if (_timer.isValid) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)continueRecording{
    [_recorder record];
    [_timer setFireDate:[NSDate distantPast]];
}


-(void)prepareToRecordWithPath:(NSString *)path completion:(QYPrepareRecorderCompletion)prepareRecorderCompletion{
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            NSLog(@"%@ %ld %@", [error domain], [error code], [[error userInfo] description]);
            return;
        }
        
        NSDictionary *settings = @{
                                   AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                   AVSampleRateKey : @16000,
                                   AVNumberOfChannelsKey : @1};
        if (weakSelf) {
            STRONGSELF
            strongSelf.recordPath = path;
            error = nil;
            if (strongSelf.recorder) {
                [strongSelf cancelRecording];
            }else{
                strongSelf.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:path] settings:settings error:&error];
                strongSelf.recorder.delegate = strongSelf;
                [strongSelf.recorder prepareToRecord];
                strongSelf.recorder.meteringEnabled = YES;
                [strongSelf.recorder recordForDuration:kVoiceRecorderMaxTime];

                if (error) {
                    NSLog(@"%@ %ld %@", [error domain], [error code], [[error userInfo] description]);
                    return;
                }
                
                prepareRecorderCompletion();
            }
        }
    });
}

-(void)startToRecordWithStartRecorderCompletion:(QYStartRecorderCompletion)startRecorderCompletion{
    if ([_recorder record]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetTimer];
#warning //???: 为什么只调用了一次？原因是：NSTimer被加到了当前runloop上，因此需要派发到主线程上执行
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePowerValue) userInfo:nil repeats:YES];
            if (startRecorderCompletion) {
                startRecorderCompletion();
            }
        });
    }
}

-(void)pauseToRecordWithPauseRecorderCompletion:(QYPauseRecorderCompletion)pauseRecorderCompletion{
    if (_recorder.isRecording) {
        [self pauseRecording];
        if (pauseRecorderCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                pauseRecorderCompletion();
            });
        }
    }
}

-(void)continueToRecordWithContinueRecordCompletion:(QYContinueRecorderCompletion)continueRecorderCompletion{
    if (!_recorder.isRecording) {
        [self continueRecording];
        if (continueRecorderCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                continueRecorderCompletion();
            });
        }
    }
}

-(void)stopRecordingWithStopRecorderCompletion:(QYStopRecorderCompletion)stopRecorderCompletion{
//    [self getVoiceDuration:_recordPath];
    [self stopRecording];
    dispatch_async(dispatch_get_main_queue(), stopRecorderCompletion);
}

-(void)cancelRecordingWithCancelRecorderCompletion:(QYCancelRecorderCompletion)cancelRecorderCompletion{
    [self stopRecording];
    
    if (self.recordPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.recordPath]) {
            NSError *error;
            [fileManager removeItemAtPath:self.recordPath error:&error];
            if (error) {
                NSLog(@"%@", error.description);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelRecorderCompletion(error);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelRecorderCompletion(nil);
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            cancelRecorderCompletion(nil);
        });
    }
}

//-(void)getVoiceDuration:(NSString *)recordPath{
//    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:recordPath] error:nil];
//    NSLog(@"时长：%f", player.duration);
//    self.recordDuration = [NSString stringWithFormat:@"%1.f", player.duration];
//}

-(void)resetTimer{
    if (!_timer) {
        return;
    }
    
    [_timer invalidate];
    _timer = nil;
}

-(void)updatePowerValue{
    if (!_recorder) {
        NSLog(@"录音器不存在，计时器停止");
        return;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_recorder updateMeters];
        self.currentTimeInterval = _recorder.currentTime;
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.015;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
//        dispatch_async(dispatch_get_main_queue(), ^{
            if (_peakPowerForChannel) {
                NSLog(@"peakPowerForChannel：%f", peakPowerForChannel);
                _peakPowerForChannel(peakPowerForChannel);
            }
//        });
    
        if (self.currentTimeInterval > kVoiceRecorderMaxTime) {
            NSLog(@"达到最长时间，计时器停止");
            [self stopRecording];
            dispatch_async(dispatch_get_main_queue(), ^{
                _maxTimeStopRecorderCompletion();
            });
        }
        
//    });
}

//+ (instancetype)sharedInstance
//{
//    static id sharedInstance = nil;
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}


//-(void)record{
//    if (![self.recorder record]){//???: 最长录15秒，自动结束
//        NSLog(@"录音失败");
//    }
//}

//-(void)play{
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    if (self.player) {
//        [self.player stop];
//        self.player = nil;
//    }
//    [self.player play];
//}

//-(void)stopRecord{
////    if ([self.recorder isRecording]) {
////        [self.recorder stop];
////    }
//    
//    [self cancelRecording];
//}
//



//-(void)playWith:(NSData *)data{
//    NSError *error;
//    _player = [[AVAudioPlayer alloc] initWithData:data error:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        return;
//    }
//    _player.meteringEnabled = YES;
//    _player.enableRate = YES;
//    _player.delegate = self.delegate;
//    [_player prepareToPlay];
//    [_player play];
//}

//#pragma mark - getters
//-(AVAudioRecorder *)recorder{
//    if (_recorder == nil) {
//        NSError *error;
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//        if (error) {
//            NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
//            return nil;
//        }
//        
//        error = nil;
//        [session setActive:YES error:&error];
//        if (error) {
//            NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
//            return nil;
//        }
//        
//        NSDictionary *settings = @{
//                                   AVFormatIDKey : @(kAudioFormatMPEG4AAC),
//                                   AVSampleRateKey : @(16000),
//                                   AVNumberOfChannelsKey : @(1)};
//
//        
//        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:kAudioPath] settings:settings error:&error];
//        _recorder.meteringEnabled = YES;
//        _recorder.delegate = self.delegate;
//        if (error) {
//            NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
//            return nil;
//        }
//        
//        
//        if(![_recorder prepareToRecord]){
//            NSLog(@"准备录音失败");
//        }
//    }
//    return _recorder;
//}

//-(AVAudioPlayer *)player{
//    if (_player == nil) {
//        NSError *error;
//        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:kAudioPath] error:&error];
//        _player.meteringEnabled = YES;
//        _player.enableRate = YES;
//        _player.delegate = self.delegate;
//        [_player prepareToPlay];
//    }
//    return _player;
//}

@end
