//
//  ChatManager.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/9.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYChatManager.h"
#import <AVOSCloudIM.h>
#import <AVFile.h>

@interface QYChatManager () <AVIMClientDelegate>

@end

@implementation QYChatManager
+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


-(void)sendMessage:(id)message{
    if ([message isKindOfClass:[NSString class]]) {
        [self sendCommonMessage:message];
        return;
    }
}

-(void)sendCommonMessage:(id)message{
    AVIMMessage *AVIMmessage = [AVIMMessage messageWithContent:message];
    [_conversation sendMessage:AVIMmessage options:0 callback:^(BOOL succeeded, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didSendMessage:succeeded:)]) {
            [self.delegate didSendMessage:AVIMmessage succeeded:succeeded];
        }
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
//    AVIMTextMessage *textMessage = [AVIMTextMessage messageWithText:message attributes:nil];
//    [_conversation sendMessage:textMessage options:0 callback:^(BOOL succeeded, NSError *error) {
//        if ([self.delegate respondsToSelector:@selector(didSendMessage:succeeded:)]) {
//            [self.delegate didSendTypedMessage:textMessage succeeded:YES];
//        }
//        if (error) {
//            [self.delegate didSendTypedMessage:nil succeeded:NO];
//            NSLog(@"%@", error);
//        }
//    }];
}

//-(void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSTimeInterval)duration{
//    if (![[NSFileManager defaultManager] fileExistsAtPath:voicePath]) {
//        return;
//    }
//    AVFile *file = [AVFile fileWithName:@"temwwwp.caf" contentsAtPath:voicePath];
//    AVIMAudioMessage *message = [AVIMAudioMessage messageWithText:nil file:file attributes:nil];
//    [_conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            if ([self.delegate respondsToSelector:@selector(didSendTypedMessage:succeeded:)]) {
//                [self.delegate didSendTypedMessage:message succeeded:YES];
//                return;
//            }
//        }
//        
//        if ([self.delegate respondsToSelector:@selector(didSendTypedMessage:succeeded:)]) {
//            [self.delegate didSendTypedMessage:nil succeeded:NO];
//            return;
//        }
//        
//    }];
//}

-(void)sendVoiceMessage{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kAudioPath]) {
        return;
    }
    AVFile *file = [AVFile fileWithName:@"temwwwp.caf" contentsAtPath:kAudioPath];
#if 0
    [file saveInBackground];//将文件上传到云端
#endif
    AVIMAudioMessage *message = [AVIMAudioMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message];
}

-(void)sendImageMessageWithData:(NSData *)data{
    AVFile *file = [AVFile fileWithData:data];
    AVIMImageMessage *message = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message];
}

-(void)sendTypedMessage:(AVIMTypedMessage *)message{
    [_conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if ([self.delegate respondsToSelector:@selector(didSendTypedMessage:succeeded:)]) {
                [self.delegate didSendTypedMessage:message succeeded:YES];
                return;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(didSendTypedMessage:succeeded:)]) {
            [self.delegate didSendTypedMessage:nil succeeded:NO];
            return;
        }
        
    }];
}


-(void)queryHistoryMessagesWith:(NSArray *)clientIDs{
    [_conversation queryMessagesWithLimit:kMessageLimit callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(didQueryHistoryMessages:succeeded:)]) {
                [self.delegate didQueryHistoryMessages:objects succeeded:YES];
            }
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(didQueryHistoryMessages:succeeded:)]) {
            NSLog(@"%@", error);
            [self.delegate didQueryHistoryMessages:nil succeeded:NO];
        }
    }];
}

#pragma mark - setters
-(void)setDelegate:(id)delegate{
    _delegate = delegate;
    _client.delegate = delegate;
}


@end
