//
//  QYAccount.m
//  约吧
//
//  Created by 云菲 on 4/8/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYAccount.h"
#import "NSString+Extension.h"

@interface QYAccount () <NSCoding>

@end

@implementation QYAccount

+ (instancetype)currentAccount
{
    static id currentAccount = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *filePath = [NSString pathInDocumentWithFileName:kAccountFileName];
        currentAccount = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (!currentAccount) {
            currentAccount = [[self alloc] init];
        }
    });
    return currentAccount;
}

-(void)saveAccount:(NSDictionary *)info{
    self.userId = info[kAccountKeyUid];
    self.token = info[kAccountKeyToken];
    NSString *filePath = [NSString pathInDocumentWithFileName:kAccountFileName];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

-(void)logout{
    self.userId = nil;
    self.token = nil;
    NSString *filePath = [NSString pathInDocumentWithFileName:kAccountFileName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

-(BOOL)isLogin{
    if (self.token) {
        return YES;
    }
    
    return NO;
}

-(NSMutableDictionary *)accountParameters{
    NSMutableDictionary *accountParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.token, kAccountKeyToken, self.userId, kAccountKeyUid, nil];
    return accountParams;
}

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.token forKey:kAccountKeyToken];
    [aCoder encodeObject:self.userId forKey:kAccountKeyUid];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.token = [aDecoder decodeObjectForKey:kAccountKeyToken];
        self.userId = [aDecoder decodeObjectForKey:kAccountKeyUid];
    }
    return self;
}


@end
