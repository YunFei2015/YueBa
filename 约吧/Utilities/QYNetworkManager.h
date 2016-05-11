//
//  QYNetworkManager.h
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QYNetworkDelegate <NSObject>

@optional
-(void)didFinishLogin:(id)responseObject success:(BOOL)success;
-(void)didFinishRegister:(id)responseObject success:(BOOL)success;
-(void)didGetVerifyCode:(id)responseObject success:(BOOL)success;
-(void)didGetUserInfo:(id)responseObject success:(BOOL)success;
-(void)didGetFriendsList:(id)responseObject success:(BOOL)success;
-(void)didUpdateUserInfo:(id)responseObject success:(BOOL)success;
@end

@interface QYNetworkManager : NSObject
@property (nonatomic, weak) id <QYNetworkDelegate> delegate;
+(instancetype)sharedInstance;
//登录
-(void)loginWithParameters:(NSDictionary *)params;

//注册
-(void)registerWithParameters:(NSDictionary *)params;

//获取验证码
-(void)getVerifyCodeWithParameters:(NSDictionary *)params;

//查询用户信息
-(void)getUserInfoWithParameters:(NSDictionary *)parameters;

//获取好友列表
-(void)getFriendsListWithParameters:(NSDictionary *)parameters;

//更新个人信息
-(void)updateUserInfoWithParameters:(NSDictionary *)parameters;

@end
