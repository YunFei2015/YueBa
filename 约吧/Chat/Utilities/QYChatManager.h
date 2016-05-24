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
@class AVIMKeyedConversation;
@class AVIMTypedMessage;

typedef void(^QYFindConversationsCompletion)(NSArray *conversations);

@protocol QYChatManagerDelegate <NSObject>
@optional
//-(void)didQueryMessagesFromServer:(NSArray *)messages succeeded:(BOOL)succeeded;
-(void)didFindConversation:(AVIMConversation *)conversation succeeded:(BOOL)succeeded;

//发送消息代理
-(void)willSendMessage:(AVIMTypedMessage *)message;
-(void)didSendMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded;

//接收消息代理
-(void)didReceiveMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation;
//-(void)didReceiveUnread:(NSInteger)unread inConversation:(AVIMConversation *)conversation;
@end

@interface QYChatManager : NSObject
@property (strong, nonatomic) AVIMClient *client;
@property (nonatomic, weak) id delegate;

+(instancetype)sharedManager;
/**
 *  创建会话
 *
 *  @param userId 好友ID
 */
-(void)findConversationWithUser:(NSInteger)userId;
-(void)findConversationsOnCacheWithCompletion:(QYFindConversationsCompletion)findConversationsCompletion;
//-(void)findConversationForId:(NSString *)conversationId withCompletion:(QYFindConversationCompletion)findConversationCompletion;
-(AVIMConversation *)conversationFromKeyedConversation:(AVIMKeyedConversation *)keyedConversation;
-(void)sendTextMessage:(NSString *)message withConversation:(AVIMConversation *)conversation;
-(void)sendVoiceMessageWithDuration:(NSTimeInterval)duration withConversation:(AVIMConversation *)conversation;
-(void)sendImageMessageWithData:(NSData *)data withConversation:(AVIMConversation *)conversation;
-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation withConversation:(AVIMConversation *)conversation;
-(void)sendTypedMessage:(AVIMTypedMessage *)message withConversation:(AVIMConversation *)conversation;
//-(void)queryMessagesFromServerWithConversation:(AVIMConversation *)conversation beforeId:(NSString *)messageId limit:(NSInteger)limit;

-(void)sendImageMessageWithURL:(NSURL *)url withConversation:(AVIMConversation *)conversation;
@end
