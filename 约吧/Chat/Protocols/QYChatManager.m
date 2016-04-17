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


-(void)sendMessage:(id)message{
    if ([message isKindOfClass:[NSString class]]) {
        if ([self.delegate respondsToSelector:@selector(willSendMessage:)]) {
            [self.delegate willSendMessage:message];
        }
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
//    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    [data writeToURL:url atomically:YES];
//    AVFile *file = [AVFile fileWithURL:path];
    AVFile *file = [AVFile fileWithData:data];
    
    AVIMImageMessage *message = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message];
}

-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation{
    AVIMLocationMessage *message = [AVIMLocationMessage messageWithText:annotation.title latitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude attributes:nil];
    [self sendTypedMessage:message];
}

-(void)sendTypedMessage:(AVIMTypedMessage *)message{
    if ([self.delegate respondsToSelector:@selector(willSendTypedMessage:)]) {
        [self.delegate willSendTypedMessage:message];
    }
    
    
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
//
//-(void)queryMessageFromCacheWithConversation:(AVIMConversation *)conversation limit:(NSInteger)limit completion:(QYQueryMessagesFromCacheCompletion)queryMessagesFromCacheCompletion{
//    NSArray *objects = [_conversation queryMessagesFromCacheWithLimit:limit];
//    if (queryMessagesFromCacheCompletion) {
//        queryMessagesFromCacheCompletion(objects);
//    }
//}

-(void)queryMessagesFromServerWithConversation:(AVIMConversation *)conversation beforeId:(NSString *)messageId limit:(NSInteger)limit{
    [_conversation queryMessagesBeforeId:messageId timestamp:0 limit:20 callback:^(NSArray *objects, NSError *error) {
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

-(void)createConversationWithUser:(NSString *)userId{
    AVIMConversationQuery *query = [self.client conversationQuery];
    [query whereKey:@"m" containsAllObjectsInArray:@[self.client.clientId, userId]];
    [query whereKey:@"m" sizeEqualTo:2];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        if (objects.count == 0) {
            NSString *conversationName = [NSString stringWithFormat:@"%@ and %@", self.client.clientId, userId];
            [self.client createConversationWithName:conversationName clientIds:@[userId] attributes:nil options:AVIMConversationOptionNone callback:^(AVIMConversation *conversation, NSError *error) {
                _conversation = conversation;
            }];
        }else{
            _conversation = objects.firstObject;
        }
        
        if ([self.delegate respondsToSelector:@selector(didCreateConversation:succeeded:)]) {
            [self.delegate didCreateConversation:_conversation succeeded:YES];
        }
    }];
    
}

-(void)findConversationWithUser:(NSString *)userId{
//    [self.client openWithCallback:^(BOOL succeeded, NSError *error) {
        AVIMConversationQuery *query = [self.client conversationQuery];
        [query whereKey:@"m" containsAllObjectsInArray:@[self.client.clientId, userId]];
        [query whereKey:@"m" sizeEqualTo:2];
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (error) {
                if ([self.delegate respondsToSelector:@selector(didFindConversation:succeeded:)]) {
                    [self.delegate didFindConversation:objects.firstObject succeeded:NO];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(didFindConversation:succeeded:)]) {
                    [self.delegate didFindConversation:objects.firstObject succeeded:YES];
                }
            }
        }];
//    }];
    
}

-(void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread{
    //TODO: 未读消息显示/
}

-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:inConversation:)]) {
        [self.delegate didReceiveMessage:message inConversation:conversation];
    }else{
        //TODO: 提示有新消息
    }
}

-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{
    if ([self.delegate respondsToSelector:@selector(didReceiveTypedMessage:inConversation:)]) {
        [self.delegate didReceiveTypedMessage:message inConversation:conversation];
    }else{
        //TODO: 提示有新消息
    }
}

#pragma mark - setters
-(void)setDelegate:(id)delegate{
    _delegate = delegate;
//    self.client.delegate = delegate;
}

-(void)setClient:(AVIMClient *)client{
    _client = client;
    _client.delegate = self;
}



@end
