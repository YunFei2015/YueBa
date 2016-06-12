//
//  QLProfileInfo.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLSingleton.h"

@interface QLProfileInfo : NSObject <NSCoding>

QLSingletonInterface(ProfileInfo)

@property (nonatomic, copy, readonly) NSArray *arrProfileInfos;

+(instancetype)profileInfo;
+(instancetype)profileInfoExceptEmpty;

@end
