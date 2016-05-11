//
//  AudioPlayer.m
//  约吧
//
//  Created by 云菲 on 3/21/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYAudioPlayer.h"
#import <AVFoundation/AVAudioSession.h>
#import <UIKit/UIKit.h>
#import <AVFile.h>

@interface QYAudioPlayer ()
@property (strong, nonatomic) NSData *playingData;

@end

@implementation QYAudioPlayer
-(instancetype)init{
    self = [super init];
    if (self) {
        [self configProximityMonitorEnableState:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    return self;
}

-(void)dealloc{
    [self configProximityMonitorEnableState:NO];
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - custom public methods
//播放
/*
-(void)playAudio:(NSString *)fileName{
    if (fileName.length > 0) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (_playingFileName && [_playingFileName isEqualToString:fileName]) {
            if (_player) {
                if (_player.isPlaying) {
                    [self stop];
                    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
                }else{
                    [self play];
                }
            }
        }else{
            if (_player) {
                [self stop];
                self.player = nil;
            }
            
            NSError *error;
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fileName] error:&error];
            if (error) {
                NSLog(@"file error: %@", error);
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerFailedPlay:)]) {
                    [self.delegate didAudioPlayerFailedPlay:_player];
                    return;
                }
            }
            
            _player.delegate = self;
            [self play];
        }
        self.playingFileName = fileName;
    }
}
 */

-(void)playAudioWithData:(NSData *)data{
    if (data) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (_playingData && ([_playingData isEqualToData:data])) {
            if (_player) {
                if (_player.isPlaying) {
                    [self stop];
                    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
                }else{
                    [self play];
                }
            }
        }else{
            if (_player) {
                [self stop];
                self.player = nil;
            }
            
            NSError *error;
            _player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            if (error) {
                NSLog(@"file error: %@", error);
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerFailedPlay:)]) {
                    [self.delegate didAudioPlayerFailedPlay:_player];
                    return;
                }
            }
            
            _player.delegate = self;
            [self play];
        }
        self.playingData = data;
    }
}

-(void)play{
    [_player play];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
        [self.delegate didAudioPlayerBeginPlay:_player];
    }
}

-(void)stop{
    NSError *error;
    [_player stop];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"%@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

//暂停
-(void)pauseAudio{
    if (_player) {
        [_player pause];
        if ([self.delegate respondsToSelector:@selector(didAudioPlayerPausePlay:)]) {
            [self.delegate didAudioPlayerPausePlay:_player];
        }
    }
}

//停止
-(void)stopAudio{
    self.playingFileName = @"";
    if (_player && _player.isPlaying) {
        [self stop];
        return;
    }
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"%@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - 近距离传感器
-(void)configProximityMonitorEnableState:(BOOL)enabled{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        if (enabled) {
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        }else{
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

-(void)proximityStateChange:(NSNotification *)notification{
    if ([UIDevice currentDevice].proximityState) {
        NSLog(@"device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        NSLog(@"device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

#pragma mark - setter & getter
-(void)setDelegate:(id<QYAudioPlayerDelegate>)delegate{
    _delegate = delegate;
    
    if (_delegate == nil) {
        [self stopAudio];
    }
}

-(BOOL)isPlaying{
    if (!_player) {
        return NO;
    }
    
    return _player.isPlaying;
}

#pragma mark - audio player delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopAudio];
}

@end
