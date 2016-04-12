//
//  QYUserStorage.h
//  约吧
//
//  Created by 云菲 on 4/12/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QYUserInfo;

@interface QYUserStorage : NSObject

+(instancetype)sharedInstance;
-(void)addUsers:(NSArray *)users;

-(void)addUser:(QYUserInfo *)user;



-(void)deleteUser:(NSString *)userId;


-(QYUserInfo *)queryUser:(NSString *)userId;
@end
