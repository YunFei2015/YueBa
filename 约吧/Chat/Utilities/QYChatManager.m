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
#import "QYUserStorage.h"
#import "QYSoundAlert.h"
#import "QYChatsListVC.h"
#import <AVOSCloudIM.h>
#import <AVFile.h>
#import <AVPush.h>

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

//会话对象反序列化
-(AVIMConversation *)conversationFromKeyedConversation:(AVIMKeyedConversation *)keyedConversation{
    return [self.client conversationWithKeyedConversation:keyedConversation];
}

//查询我和好友userId之间的会话，若不存在则创建
-(void)findConversationWithUser:(NSInteger)userId{
    NSString *userIdStr = @(userId).stringValue;
    AVIMConversationQuery *query = [self.client conversationQuery];
    query.cachePolicy = kAVIMCachePolicyCacheElseNetwork;
    query.cacheMaxAge = CLTimeIntervalMax;
    [query whereKey:@"m" containsAllObjectsInArray:@[self.client.clientId, userIdStr]];
    [query whereKey:@"m" sizeEqualTo:2];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        __block AVIMConversation *result;
        if (objects.count == 0) {
            NSString *conversationName = [NSString stringWithFormat:@"%@ and %@", self.client.clientId, userIdStr];
            [self.client createConversationWithName:conversationName clientIds:@[userIdStr] attributes:nil options:AVIMConversationOptionNone callback:^(AVIMConversation *conversation, NSError *error) {
                if ([self.delegate respondsToSelector:@selector(didFindConversation:succeeded:)]) {
                    [self.delegate didFindConversation:conversation succeeded:YES];
                }
            }];
        }else{
            result = objects.firstObject;
            if ([self.delegate respondsToSelector:@selector(didFindConversation:succeeded:)]) {
                [self.delegate didFindConversation:result succeeded:YES];
            }
        }
    }];
}

-(void)findConversationsOnCacheWithCompletion:(QYFindConversationsCompletion)findConversationsCompletion{
    AVIMConversationQuery *query = [self.client conversationQuery];
    query.cachePolicy = kAVIMCachePolicyCacheOnly;
    query.cacheMaxAge = CLTimeIntervalMax;
    query.limit = NSUIntegerMax;
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        NSLog(@"%ld", objects.count);
        if (error) {
            NSLog(@"%@",error);
        }
        if (findConversationsCompletion) {
            findConversationsCompletion(objects);
        }
    }];
}

//发送文本消息
-(void)sendTextMessage:(NSString *)message withConversation:(AVIMConversation *)conversation{
    AVIMTextMessage *textMessage = [AVIMTextMessage messageWithText:message attributes:nil];
    [self sendTypedMessage:textMessage withConversation:conversation];
}

//发送语音消息
-(void)sendVoiceMessageWithDuration:(NSTimeInterval)duration withConversation:(AVIMConversation *)conversation{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kAudioPath]) {
        return;
    }
    AVFile *file = [AVFile fileWithName:@"temwwwp.caf" contentsAtPath:kAudioPath];
#if 1
    [file saveInBackground];//将文件上传到云端
#endif
    
    AVIMAudioMessage *message = [AVIMAudioMessage messageWithText:@(duration).stringValue file:file attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

//发送图片消息
-(void)sendImageMessageWithData:(NSData *)data withConversation:(AVIMConversation *)conversation{
    UIImage *image = [UIImage imageWithData:data];
    AVFile *file = [AVFile fileWithData:data];
    [file.metaData setValue:@(image.size.width) forKey:@"width"];
    [file.metaData setValue:@(image.size.height) forKey:@"height"];
    
    AVIMImageMessage *message = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

-(void)sendImageMessageWithURL:(NSURL *)url withConversation:(AVIMConversation *)conversation{
    AVFile *file = [AVFile fileWithURL:url.absoluteString];
    AVIMImageMessage *message = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

//发送位置消息
-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation withConversation:(AVIMConversation *)conversation{
    AVIMLocationMessage *message = [AVIMLocationMessage messageWithText:annotation.title latitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude attributes:nil];
    [self sendTypedMessage:message withConversation:(AVIMConversation *)conversation];
}

//发送富文本消息
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
            message.sendTimestamp = [[NSDate date] timeIntervalSince1970];
            if ([self.delegate respondsToSelector:@selector(didSendMessage:succeeded:)]) {
                [self.delegate didSendMessage:message succeeded:NO];
            }
        }
    }];
}

/*
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
 */


/*
-(void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread{
    //TODO: 未读消息显示/
    NSLog(@"未读消息数 : %ld", unread);
    if (unread > 0) {
        if ([self.delegate respondsToSelector:@selector(didReceiveUnread:inConversation:)]) {
            [self.delegate didReceiveUnread:unread inConversation:conversation];
        }
    }
}
 */

#pragma mark - AVIMClient Delegate
//接收消息代理
-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{

    [conversation.members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *userId = (NSString *)obj;
        if (userId.integerValue != [QYAccount currentAccount].userId) {
            
           QYUserInfo *user = [[QYUserStorage sharedInstance] getUserForId:userId.integerValue];
            
//            //如果数据库中没有该用户，临时构造一个，等做好了网络接口部分，新添加的好友会立刻存入数据库
//            if (user == nil) {
//                NSDictionary *userDict = @{kUserId : userId,
//                                           kUserName : @"新来的",
//                                           kUserPhotos : @[@"2"],
//                                           kUserMatchTime : @([[NSDate date] timeIntervalSince1970]),
//                                           kUserAge : @20};
//                [[QYUserStorage sharedInstance] addUser:userDict];
//                user = [QYUserInfo userWithDictionary:userDict];
//            }
            
            //如果用户的会话属性为空，则将会话存储到本地
            if (user.keyedConversation == nil) {
                [[QYUserStorage sharedInstance] updateUserConversation:conversation.keyedConversation forUserId:user.userId];
            }
            
            //存储最后一条消息时间
            [[QYUserStorage sharedInstance] updateUserLastMessageAt:[NSDate dateWithTimeIntervalSince1970:message.sendTimestamp] forUserId:user.userId];
            
            //存储消息状态
            [[QYUserStorage sharedInstance] updateUserMessageStatus:QYMessageStatusUnread forUserId:user.userId];
            *stop = TRUE;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:inConversation:)]) {
        [self.delegate didReceiveMessage:message inConversation:conversation];
        
        //如果当前不在聊天界面，则提示音；反之，没有提示音
        if ([self.delegate isKindOfClass:[QYChatsListVC class]]){
            [[QYSoundAlert sharedInstance] play];
        }
    }else{//提示音
        [[QYSoundAlert sharedInstance] play];
    }
}

#pragma mark - setters
-(void)setClient:(AVIMClient *)client{
    _client = client;
    _client.delegate = self;
    [_client openWithCallback:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"client open failed : %@", error);
            return;
        }
    }];
}



@end
