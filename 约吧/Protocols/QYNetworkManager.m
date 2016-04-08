//
//  QYNetworkManager.m
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYNetworkManager.h"
#import "QYDataManager.h"
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

//TODO: 登录
-(void)loginWithParameters:(NSDictionary *)params{
    if ([self.delegate respondsToSelector:@selector(didFinishLogin:success:)]) {
        [self.delegate didFinishLogin:nil success:YES];
    }
}

//注册
-(void)registerWithParameters:(NSDictionary *)params{
    NSString *url = [kBaseUrl stringByAppendingPathComponent:kRegisterApi];
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[kResponseKeySuccess] integerValue] == 1) {
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
        if ([responseObject[kResponseKeySuccess] integerValue] == 1) {
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



@end
