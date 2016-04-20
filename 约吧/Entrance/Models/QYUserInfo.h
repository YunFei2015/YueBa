//
//  QYUserInfo.h
//  约吧
//
//  Created by 云菲 on 4/11/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVIMKeyedConversation;

@interface QYUserInfo : NSObject
@property (strong, nonatomic) NSString *userId;
@property (nonatomic) BOOL isMan;
@property (nonatomic) NSInteger age;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *matchTime;

@property (strong, nonatomic) AVIMKeyedConversation *keyedConversation;
@property (strong, nonatomic) NSDate *lastMessageAt;





-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(instancetype)userWithDictionary:(NSDictionary *)dict;
@end
