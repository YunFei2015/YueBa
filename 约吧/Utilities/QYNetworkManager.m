//
//  QYNetworkManager.m
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYNetworkManager.h"
#import <AFNetworking.h>

@interface QYNetworkManager ()
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@end

@implementation QYNetworkManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(AFHTTPSessionManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

-(void)loginWithParameters:(NSDictionary *)params{
    [self.manager POST:[kBaseUrl stringByAppendingPathComponent:kLoginApi] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didFinishLogin:success:)]) {
                [self.delegate didFinishLogin:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didFinishLogin:success:)]) {
                [self.delegate didFinishLogin:responseObject success:NO];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didFinishLogin:success:)]) {
            [self.delegate didFinishLogin:nil success:NO];
        }
    }];
}

//注册
-(void)registerWithParameters:(NSDictionary *)params{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kRegisterApi];
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didFinishRegister:success:)]) {
                [self.delegate didFinishRegister:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didFinishRegister:success:)]) {
                [self.delegate didFinishRegister:responseObject success:NO];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if ([self.delegate respondsToSelector:@selector(didFinishRegister:success:)]) {
            [self.delegate didFinishRegister:nil success:NO];
        }
    }];
}

//获取验证码
-(void)getVerifyCodeWithParameters:(NSDictionary *)params{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kVerifyCodeApi];
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didGetVerifyCode:success:)]) {
                [self.delegate didGetVerifyCode:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didGetVerifyCode:success:)]) {
                [self.delegate didGetVerifyCode:responseObject success:NO];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if ([self.delegate respondsToSelector:@selector(didGetVerifyCode:success:)]) {
            [self.delegate didGetVerifyCode:nil success:NO];
        }
    }];
}

//获取用户信息
-(void)getUsersWithParameters:(NSDictionary *)parameters{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kGetUsersApi];
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didGetUsers:success:)]) {
                [self.delegate didGetUsers:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didGetUsers:success:)]) {
                [self.delegate didGetUsers:responseObject success:NO];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didGetUsers:success:)]) {
            [self.delegate didGetUsers:nil success:NO];
        }
    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"plist"];
//        NSDictionary *responseObject = [NSDictionary dictionaryWithContentsOfFile:path];
//        if ([self.delegate respondsToSelector:@selector(didGetUsers:success:)]) {
//            [self.delegate didGetUsers:responseObject success:YES];
//        }
//    });
}

//获取好友列表
-(void)getFriendsListWithParameters:(NSDictionary *)parameters{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kGetFriendListApi];
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didGetFriendsList:success:)]) {
                [self.delegate didGetFriendsList:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didGetFriendsList:success:)]) {
                [self.delegate didGetFriendsList:responseObject success:NO];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didGetFriendsList:success:)]) {
            [self.delegate didGetFriendsList:nil success:NO];
        }
    }];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"plist"];
//    NSDictionary *responseObject = [NSDictionary dictionaryWithContentsOfFile:path];
    
}

//更新用户信息
-(void)updateUserInfoWithParameters:(NSDictionary *)parameters{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kUpdateUserInfoApi];
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didUpdateUserInfo:success:)]) {
                [self.delegate didUpdateUserInfo:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didUpdateUserInfo:success:)]) {
                [self.delegate didUpdateUserInfo:responseObject success:NO];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didUpdateUserInfo:success:)]) {
            [self.delegate didUpdateUserInfo:nil success:NO];
        }
    }];
}

-(void)markUserRelationshipWithParameters:(NSDictionary *)parameters{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kMarkUserRelationshipApi];
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[kResponseKeySuccess] boolValue]) {
            if ([self.delegate respondsToSelector:@selector(didMarkUserRelationship:success:)]) {
                [self.delegate didMarkUserRelationship:responseObject success:YES];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(didMarkUserRelationship:success:)]) {
                [self.delegate didMarkUserRelationship:responseObject success:NO];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([self.delegate respondsToSelector:@selector(didMarkUserRelationship:success:)]) {
            [self.delegate didMarkUserRelationship:nil success:NO];
        }
    }];
}

@end
