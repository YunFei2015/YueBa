//
//  QYUserStorage.h
//  约吧
//
//  Created by 云菲 on 4/12/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QYUserInfo;
@class AVIMKeyedConversation;

@interface QYUserStorage : NSObject

+(instancetype)sharedInstance;
/**
 *  插入1个用户
 *
 *  @param user 用户对象
 */

-(void)addUser:(NSDictionary *)user;

/**
 *  插入多个用户
 *
 *  @param users 用户对象列表
 */

-(void)addUsers:(NSArray *)users;

/**
 *  更新1个用户的最后一条消息
 *
 *  @param message 消息内容
 *  @param time    消息时间
 *  @param userId  用户ID
 */

//-(void)updateUserMessage:(NSString *)message time:(NSInteger)time forUserId:(NSString *)userId;
-(void)updateUserConversation:(AVIMKeyedConversation *)conversation forUserId:(NSString *)userId;
-(void)updateUserLastMessageAt:(NSDate *)time forUserId:(NSString *)userId;
-(void)updateUserMessageStatus:(QYMessageStatus)status forUserId:(NSString *)userId;

///**
// *  更新多个用户
// *
// *  @param users 用户对象列表
// */
//
//-(void)updateUsers:(NSArray *)users;

/**
 *  删除指定用户
 *
 *  @param userId 用户Id
 */

-(void)deleteUser:(NSString *)userId;

//-(QYUserInfo *)getUser:(NSString *)userId;

/**
 *  查询所有用户
 *
 *  @return QYUserInfo对象列表
 */

-(NSArray *)getAllUsersWithSortType:(NSString *)key;

-(QYUserInfo *)getUserForId:(NSString *)userId;
@end
