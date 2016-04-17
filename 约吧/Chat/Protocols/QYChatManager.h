//
//  ChatManager.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/9.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QYPinAnnotation.h"
@class AVIMClient;
@class AVIMConversation;
@class AVIMMessage;
@class AVIMTypedMessage;
@class AVIMAudioMessage;
@class AVIMImageMessage;
@class AVIMLocationMessage;

//typedef void(^QYQueryMessagesFromCacheCompletion)(NSArray *);

@protocol QYChatManagerDelegate <NSObject>
@optional
-(void)didQueryMessagesFromCache:(NSArray *)messages succeeded:(BOOL)succeeded;
-(void)didQueryMessagesFromServer:(NSArray *)messages succeeded:(BOOL)succeeded;
-(void)didCreateConversation:(AVIMConversation *)conversation succeeded:(BOOL)succeeded;
-(void)didFindConversation:(AVIMConversation *)conversation succeeded:(BOOL)succeeded;

//发送消息代理
-(void)willSendMessage:(AVIMMessage *)message;
-(void)willSendTypedMessage:(AVIMTypedMessage *)message;
-(void)didSendTypedMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded;
-(void)didSendMessage:(AVIMMessage *)message succeeded:(BOOL)succeeded;

//接收消息代理
-(void)didReceiveMessage:(AVIMMessage *)message inConversation:(AVIMConversation *)conversation;
-(void)didReceiveTypedMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation;
-(void)didReceiveUnread:(NSInteger)unread inConversation:(AVIMConversation *)conversation;
@end

@interface QYChatManager : NSObject
@property (strong, nonatomic) AVIMClient *client;
@property (strong, nonatomic) AVIMConversation *conversation;
@property (nonatomic) id delegate;

+(instancetype)sharedManager;
/**
 *  创建会话
 *
 *  @param userId 目标用户ID
 */
-(void)createConversationWithUser:(NSString *)userId;

-(void)findConversationWithUser:(NSString *)userId;

-(void)sendMessage:(id)message;
//-(void)sendVoiceMessage:(NSString *)voicePath voiceDuration:(NSTimeInterval)duration;
-(void)sendVoiceMessage;
-(void)sendImageMessageWithData:(NSData *)data;
-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation;
//-(void)queryMessageFromCacheWithConversation:(AVIMConversation *)conversation limit:(NSInteger)limit completion:(QYQueryMessagesFromCacheCompletion)queryMessagesFromCacheCompletion;
-(void)queryMessagesFromServerWithConversation:(AVIMConversation *)conversation beforeId:(NSString *)messageId limit:(NSInteger)limit;
@end
