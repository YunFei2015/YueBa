//
//  QYSoundAlert.m
//  约吧
//
//  Created by 云菲 on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSoundAlert.h"
#import <AudioToolbox/AudioToolbox.h>

@interface QYSoundAlert ()
@property (nonatomic) SystemSoundID soundId;
@end

@implementation QYSoundAlert

+ (instancetype)sharedInstance
{
    static QYSoundAlert *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        NSString *path = @"/System/Library/Audio/UISounds/sms-received1.caf";//三全音
        if (path) {
            SystemSoundID theSoundID;
            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                sharedInstance.soundId = theSoundID;
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    });
    return sharedInstance;
}

-(void)play{
    //如果app开启了震动模式，就播放提示音+震动；反之，只播放提示音
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibrate"]) {
        AudioServicesPlaySystemSound(1007);
    }else{
        AudioServicesPlaySystemSound(_soundId);
    }
}

-(void)pushNotificationPlay{
    //三全音，提示音根据系统设置灵活变化，如果系统开了震动，提示就会有震动
    AudioServicesPlaySystemSound(1007);
}

-(void)dealloc{
    AudioServicesDisposeSystemSoundID(_soundId);
}


@end
