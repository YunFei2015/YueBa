//
//  QYUserInfo.m
//  约吧
//
//  Created by 云菲 on 4/11/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserInfo.h"
#import <AVIMMessage.h>

@implementation QYUserInfo

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        _userId = [dict[kUserId] integerValue];
        _sex = [dict objectForKey:kUserSex];
        _age = [[dict objectForKey:kUserAge] integerValue];
        _iconUrl = [dict objectForKey: kUserIconUrl];
        _name = [dict objectForKey:kUserName];
        if ([dict objectForKey:kUserMatchTime]) {
            _matchTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:kUserMatchTime] integerValue]];
        }else{
            _matchTime = nil;
        }
        
        _keyedConversation = [dict objectForKey:@"keyedConversation"];
        _lastMessageAt = [dict objectForKey:@"lastMessageAt"];
        
        NSNumber *messageStatus = [dict objectForKey:@"messageStatus"];
        if (messageStatus) {
            switch ([dict[@"messageStatus"] integerValue]) {
                case 0:
                    _messageStatus = QYMessageStatusDefault;
                    break;
                    
                case 1:
                    _messageStatus = QYMessageStatusUnread;
                    break;
                    
                case 2:
                    _messageStatus = QYMessageStatusFailed;
                    break;
                    
                default:
                    break;
            }
        }else{
            _messageStatus = -1;
        }
        
        
    }
    return self;
}

+(instancetype)userWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}
@end
