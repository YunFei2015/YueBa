//
//  QYUserStorage.m
//  约吧
//
//  Created by 云菲 on 4/12/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserStorage.h"
#import "QYUserInfo.h"

@interface QYUserStorage ()


@end

@implementation QYUserStorage

#pragma mark - Init
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Custom Methods

-(void)addUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
   
}

-(void)deleteUser:(NSString *)userId{
    
    NSError *error;
    if (error) {
        [NSException raise:@"删除错误" format:@"%@", [error localizedDescription]];
    }
}

-(QYUserInfo *)queryUser:(NSString *)userId{
    return nil;
}

-(NSArray *)queryUsersWithPredicate:(NSPredicate *)predicate{
 
    NSError *error;
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    
    
    return nil;
}

//-(QYUserInfo *)userFromObject:(NSManagedObject *)object{
//    QYUserInfo *user = [[QYUserInfo alloc] init];
//    user.userId = [object valueForKey:@"userId"];
//    return user;
//}

#pragma mark - Getters


//-(NSEntityDescription *)userEntity{
//    if (_userEntity == nil) {
//        NSManagedObjectModel *model = [[self.context persistentStoreCoordinator] managedObjectModel];
//        NSEntityDescription *entity = [[model entitiesByName] objectForKey:@"User"];
//        _userEntity = entity;
//    }
//    return _userEntity;
//}


@end
