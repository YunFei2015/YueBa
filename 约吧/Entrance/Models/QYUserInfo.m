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
        _userId = dict[kNetworkKeyUserId];
        _isMan = dict[@"sex"];
        _age = [dict[@"age"] integerValue];
        _iconUrl = dict[@"iconUrl"];
        _name = dict[@"name"];
        _matchTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"matchTime"] integerValue]];
        
        if (dict[@"keyedConversation"] == nil || dict[@"keyedConversation"] == [NSNull null]) {
            _keyedConversation = nil;
        }else{
            _keyedConversation = dict[@"keyedConversation"];
        }
        
        if (dict[@"lastMessageAt"] == nil || dict[@"lastMessageAt"] == [NSNull null]) {
            _lastMessageAt = nil;
        }else{
            _lastMessageAt = dict[@"lastMessageAt"];
        }
        
    }
    return self;
}

+(instancetype)userWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}
@end
