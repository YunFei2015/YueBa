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
@property (nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *sex;
@property (nonatomic) NSInteger age;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSArray *userPhotos;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *matchTime;

@property (strong, nonatomic) AVIMKeyedConversation *keyedConversation;
@property (strong, nonatomic) NSDate *lastMessageAt;
@property (nonatomic) QYMessageStatus messageStatus;




-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(instancetype)userWithDictionary:(NSDictionary *)dict;
@end
