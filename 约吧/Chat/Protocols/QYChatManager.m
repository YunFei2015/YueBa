//
//  ChatManager.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/9.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYChatManager.h"
#import "QYAccount.h"
#import "QYUserInfo.h"
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

-(AVIMConversation *)conversationFromKeyedConversation:(AVIMKeyedConversation *)keyedConversation{
    return [self.client conversationWithKeyedConversation:keyedConversation];
}

-(void)sendTextMessage:(NSString *)message withConversation:(AVIMConversation *)conversation{
    AVIMTextMessage *textMessage = [AVIMTextMessage messageWithText:message attributes:nil];
    [self sendTypedMessage:textMessage withConversation:conversation];
}

-(void)sendVoiceMessageWithConversation:(AVIMConversation *)conversation{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kAudioPath]) {
        return;
    }
    AVFile *file = [AVFile fileWithName:@"temwwwp.caf" contentsAtPath:kAudioPath];
#if 0
    [file saveInBackground];//将文件上传到云端
#endif
    AVIMAudioMessage *message = [AVIMAudioMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

-(void)sendImageMessageWithData:(NSData *)data withConversation:(AVIMConversation *)conversation{
    AVFile *file = [AVFile fileWithData:data];
    AVIMImageMessage *message = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation withConversation:(AVIMConversation *)conversation{
    AVIMLocationMessage *message = [AVIMLocationMessage messageWithText:annotation.title latitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

-(void)sendTypedMessage:(AVIMTypedMessage *)message withConversation:(AVIMConversation *)conversation{
    if ([self.delegate respondsToSelector:@selector(willSendMessage:)]) {
        [self.delegate willSendMessage:message];
    }
    
    [conversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if ([self.delegate respondsToSelector:@selector(didSendMessage:succeeded:)]) {
                [self.delegate didSendMessage:message succeeded:YES];
            }
        }else{
            NSLog(@"send message failed : %@", error);
            if ([self.delegate respondsToSelector:@selector(didSendMessage:succeeded:)]) {
                [self.delegate didSendMessage:nil succeeded:NO];
            }
        }
    }];
}

-(void)queryMessagesFromServerWithConversation:(AVIMConversation *)conversation beforeId:(NSString *)messageId limit:(NSInteger)limit{
    [conversation queryMessagesBeforeId:messageId timestamp:0 limit:20 callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(didQueryMessagesFromServer:succeeded:)]) {
                [self.delegate didQueryMessagesFromServer:objects succeeded:YES];
            }
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(didQueryMessagesFromServer:succeeded:)]) {
            NSLog(@"%@", error);
            [self.delegate didQueryMessagesFromServer:nil succeeded:NO];
        }
    }];
}

-(void)findConversationWithUser:(NSString *)userId{
    AVIMConversationQuery *query = [self.client conversationQuery];
    query.cacheMaxAge = CLTimeIntervalMax;
    [query whereKey:@"m" containsAllObjectsInArray:@[self.client.clientId, userId]];
    [query whereKey:@"m" sizeEqualTo:2];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        __block AVIMConversation *result;
        if (objects.count == 0) {
            NSString *conversationName = [NSString stringWithFormat:@"%@ and %@", self.client.clientId, userId];
            [self.client createConversationWithName:conversationName clientIds:@[userId] attributes:nil options:AVIMConversationOptionNone callback:^(AVIMConversation *conversation, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(didCreateConversation:succeeded:)]) {
                    [self.delegate didCreateConversation:conversation succeeded:YES];
                }
            }];
        }else{
            result = objects.firstObject;
            if ([self.delegate respondsToSelector:@selector(didCreateConversation:succeeded:)]) {
                [self.delegate didCreateConversation:result succeeded:YES];
            }
        }
    }];
    
}

//-(void)findConversationForId:(NSString *)conversationId withCompletion:(QYFindConversationCompletion)findConversationCompletion{
//    AVIMConversationQuery *query = [self.client conversationQuery];
//    query.cacheMaxAge = CLTimeIntervalMax;
//    [query whereKey:@"conversationId" equalTo:conversationId];
//    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
//        if (error) {
//            NSLog(@"%@", error);
//        }
//        
//        findConversationCompletion(objects[0]);
//    }];
//}

//-(AVIMConversation *)conversationForId:(NSString *)conversationId{
//    AVIMConversation *conversation = [self.client conversationForId:conversationId];
//    return conversation;
//}

-(void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread{
    //TODO: 未读消息显示/
    NSLog(@"未读消息数 : %ld", unread);
    
}

-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{
    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:inConversation:)]) {
        [self.delegate didReceiveMessage:message inConversation:conversation];
    }
}

#pragma mark - setters
-(void)setDelegate:(id)delegate{
    _delegate = delegate;
}

-(void)setClient:(AVIMClient *)client{
    _client = client;
    _client.delegate = self;
}



@end
