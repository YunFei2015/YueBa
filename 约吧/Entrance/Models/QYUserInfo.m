//
//  QYUserInfo.m
//  约吧
//
//  Created by 云菲 on 4/11/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserInfo.h"

@implementation QYUserInfo
//@dynamic userId;
//@dynamic isMan;
//@dynamic age;
//@dynamic iconImage;
//@dynamic name;

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        _userId = dict[kNetworkKeyUserId];
        _isMan = NO;
        _age = 28;
        _iconImage = [UIImage imageNamed:@"2"];
    }
    return self;
}

+(instancetype)userWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}
@end
