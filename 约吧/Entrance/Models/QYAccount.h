//
//  QYAccount.h
//  约吧
//
//  Created by 云菲 on 4/8/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYAccount : NSObject
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *token;

+(instancetype)currentAccount;
-(void)saveAccount:(NSDictionary *)info;
-(void)logout;
-(BOOL)isLogin;
-(NSMutableDictionary *)accountParameters;
@end
