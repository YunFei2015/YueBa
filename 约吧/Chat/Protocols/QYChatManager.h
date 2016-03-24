//
//  ChatManager.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/9.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AVIMClient;
@class AVIMConversation;
@class AVIMMessage;
@class AVIMTypedMessage;
@class AVIMAudioMessage;
@class AVIMImageMessage;

@protocol QYChatManagerDelegate <NSObject>
@optional
-(void)didSendTypedMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded;
-(void)didSendAudioMessage:(AVIMAudioMessage *)message succeeded:(BOOL)succeeded;
-(void)didSendMessage:(AVIMMessage *)message succeeded:(BOOL)succeeded;
-(void)didQueryHistoryMessages:(NSArray *)historyMessages succeeded:(BOOL)succeeded;
@end

@interface QYChatManager : NSObject
@property (strong, nonatomic) AVIMClient *client;
@property (strong, nonatomic) AVIMConversation *conversation;
@property (nonatomic) id delegate;

+(instancetype)sharedManager;
-(void)sendMessage:(id)message;
-(void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSTimeInterval)duration;
-(void)sendVoiceMessage;
-(void)sendImageMessageWithData:(NSData *)data;
-(void)queryHistoryMessagesWith:(NSArray *)clientIDs;
@end
