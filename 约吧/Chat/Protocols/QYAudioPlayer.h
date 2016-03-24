//
//  AudioPlayer.h
//  约吧
//
//  Created by 云菲 on 3/21/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@protocol QYAudioPlayerDelegate <NSObject>
@optional
-(void)didAudioPlayerBeginPlay:(AVAudioPlayer *)player;
-(void)didAudioPlayerStopPlay:(AVAudioPlayer *)player;
-(void)didAudioPlayerPausePlay:(AVAudioPlayer *)player;
-(void)didAudioPlayerFailedPlay:(AVAudioPlayer *)player;
@end

@interface QYAudioPlayer : NSObject <AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *playingFileName;
@property (nonatomic) id<QYAudioPlayerDelegate> delegate;

+(instancetype)sharedInstance;
-(BOOL)isPlaying;
-(void)playAudioWithData:(NSData *)data;
-(void)playAudio:(NSString *)fileName;
-(void)pauseAudio;
-(void)stopAudio;
@end
