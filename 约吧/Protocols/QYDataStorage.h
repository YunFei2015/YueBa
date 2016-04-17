//
//  QYDataManager.h
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYDataStorage : NSObject

+(instancetype)sharedInstance;

-(void)saveUsers:(NSArray *)users;

-(void)deleteUser:(NSString *)userId;

-(QYUserInfo *)getUser:(NSString *)userId;

-(NSArray *)getAllUsers;
@end
