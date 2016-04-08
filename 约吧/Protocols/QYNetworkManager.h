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

@end

@interface QYNetworkManager : NSObject
@property (nonatomic, weak) id <QYNetworkDelegate> delegate;
+(instancetype)sharedInstance;
-(void)loginWithParameters:(NSDictionary *)params;
-(void)registerWithParameters:(NSDictionary *)params;
-(void)getVerifyCodeWithParameters:(NSDictionary *)params;

@end
