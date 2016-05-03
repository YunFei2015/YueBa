//
//  QYUserStorage.m
//  约吧
//
//  Created by 云菲 on 4/12/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserStorage.h"
#import "QYUserInfo.h"
#import <FMDB.h>
#import <AVIMConversation.h>
#import <AVIMKeyedConversation.h>

#define kUserDBFileName @"users.db"
#define kUserTable @"User"

@interface QYUserStorage ()
@property (strong, nonatomic) FMDatabase *database;
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

#pragma mark - Custom Methods - 外部接口
-(void)addUser:(NSDictionary *)user{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when add user!");
        return;
    }
    
    //插入信息
    [self updateUser:user withDatabase:self.database isNew:YES];
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when add user!");
    }
}

-(void)addUsers:(NSArray *)users{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[kTempDirectory stringByAppendingPathComponent:kUserDBFileName]];
    [queue inDatabase:^(FMDatabase *db) {
        [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self updateUser:obj withDatabase:db isNew:YES];
        }];
    }];
}

//更新一个用户
//-(void)updateUserMessage:(NSString *)message time:(NSInteger)time forUserId:(NSString *)userId{
//    //打开数据库
//    if (![self.database open]) {
//        NSLog(@"User database open failed when update user!");
//        return;
//    }
//    
//    //插入信息
//    NSString *set = [NSString stringWithFormat:@"lastMessage = '%@', lastMessageTime = %ld", message, time];
//    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where userId = %@", kUserTable, set, userId];
//    BOOL result = [self.database executeUpdate:sql];
//    NSLog(@"%d", result);
//    
//    
//    //关闭数据库
//    if (![self.database close]) {
//        NSLog(@"User database close failed when update user!");
//    }
//}

-(void)updateUserConversation:(AVIMKeyedConversation *)conversation forUserId:(NSString *)userId{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when update user conversation!");
        return;
    }
    
    //插入信息
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:conversation];
    NSLog(@"%d", self.database.open);
    BOOL result = [self.database executeUpdate:@"update User set keyedConversation = ? where userId = ?", data, userId];
    NSLog(@"%d", result);
    
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when update user conversation!");
    }
}

-(void)updateUserLastMessageAt:(NSDate *)time forUserId:(NSString *)userId{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when update user lastMessageAt!");
        return;
    }
    
    //插入信息
    NSLog(@"%d", self.database.open);
    BOOL result = [self.database executeUpdate:@"update User set lastMessageAt = ? where userId = ?", time, userId];
    NSLog(@"%d", result);
    
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when update user lastMessageAt!");
    }
}

-(void)updateUserMessageStatus:(QYMessageStatus)status forUserId:(NSString *)userId{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when update user message status!");
        return;
    }
    
    //插入信息
    NSLog(@"%d", self.database.open);
    BOOL result = [self.database executeUpdate:@"update User set messageStatus = ? where userId = ?", @(status), userId];
    NSLog(@"%d", result);
    
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when update user message status!");
    }
}

////更新多个用户
//-(void)updateUsers:(NSArray *)users{
//    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[kTempDirectory stringByAppendingPathComponent:kUserDBFileName]];
//    [queue inDatabase:^(FMDatabase *db) {
//        [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self updateUser:obj withDatabase:(FMDatabase *)db isNew:NO];
//        }];
//    }];
//}

//查询所有用户
-(NSArray *)getAllUsersWithSortType:(NSString *)key{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when get all users!");
        return nil;
    }
    
    //创建sql语句
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ > 0 order by %@ desc", kUserTable, key, key];
    
    //执行sql
    FMResultSet *result = [self.database executeQuery:sql];
    NSMutableArray *results = [NSMutableArray array];
    while ([result next]) {
        NSDictionary * dict = [result resultDictionary];
        NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSData class]]) {
                id value = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
                [muDict setValue:value forKey:key];
            }
            
            if ([obj isKindOfClass:[NSNull class]]) {
                [muDict removeObjectForKey:key];
            }
        }];
        QYUserInfo *user = [QYUserInfo userWithDictionary:muDict];
        [results addObject:user];
    }
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when get all users!");
    }
    return results;
}

//删除指定用户
-(void)deleteUser:(NSString *)userId{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when delete user!");
        return;
    }
    
    //创建sql语句
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = %@", kUserTable, kUserId, userId];\
    
    //执行sql
    BOOL result = [self.database executeUpdate:sql];
    NSLog(@"%d", result);
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when delete user!");
    }
    
}

-(QYUserInfo *)getUserForId:(NSString *)userId{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when select user!");
        return nil;
    }
    
    //创建sql语句
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %@", kUserTable, kUserId, userId];
    FMResultSet *result = [self.database executeQuery:sql];
    QYUserInfo *user;
    while ([result next]) {
        NSDictionary * dict = [result resultDictionary];
        NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSData class]]) {
                id value = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
                [muDict setValue:value forKey:key];
            }
            
            if ([obj isKindOfClass:[NSNull class]]) {
                [muDict removeObjectForKey:key];
            }
        }];
        user = [QYUserInfo userWithDictionary:muDict];
        return user;
    }

    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when select user!");
        return nil;
    }
    
    return user;
}

#pragma mark - 内部接口
//更新一个用户
-(void)updateUser:(NSDictionary *)user withDatabase:(FMDatabase *)db isNew:(BOOL)isNew{
    //字典所有的键
    NSArray *allKeys = user.allKeys;
    //表的所有键
    NSArray *tableKeys = [self getTableKeys];
    //字典和表共有的键
    NSArray *commonKeys = [self commonObjectsBetweenArray:tableKeys andArray:allKeys];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:user];
    NSMutableArray *values = [NSMutableArray array];
    [allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //如果共有键值中不包含该键值，则从字典中删除
        if (![commonKeys containsObject:obj]) {
            [dict removeObjectForKey:obj];
        }else{
            id value = [dict valueForKey:obj];
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[AVIMKeyedConversation class]]) {
                //将字典或数组转化成NSData
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                [dict setValue:data forKey:obj];
            }
            
            if (value == nil) {
                [dict removeObjectForKey:obj];
            }
            [values addObject:[dict valueForKey:obj]];
        }
    }];
    
    //创建sql语句、执行
    NSString *sql = [self sqlStringWithKeys:[dict allKeys] dict:dict isNew:isNew];
    NSLog(@"%d", db.open);
    BOOL result = [db executeUpdate:sql withParameterDictionary:dict];
    NSLog(@"%d", result);
}

//两个数组之间的共有对象
-(NSArray *)commonObjectsBetweenArray:(NSArray *)array1 andArray:(NSArray *)array2{
    NSMutableArray *results = [NSMutableArray array];
    [array1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([array2 containsObject:obj]) {
            [results addObject:obj];
        }
    }];
    
    return results;
}

//构造更新sql语句
-(NSString *)sqlStringWithKeys:(NSArray *)keys dict:(NSDictionary *)dict isNew:(BOOL)isNew{
    NSString *sql;
    if (isNew) {
        NSString *columns = [keys componentsJoinedByString:@", "];
        NSString *values = [keys componentsJoinedByString:@", :"];
        values = [@":" stringByAppendingString:values];
        //执行插入
        sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", kUserTable, columns, values];
    }else{
        //执行更新
        NSString *set = [NSString stringWithFormat:@"keyedConversation=%@", dict[@"keyedConversation"]];
        sql = [NSString stringWithFormat:@"update %@ set %@ where userId = %@", kUserTable, set, dict[kUserId]];
    }
    
    return sql;
}

//获取User表所有的键值
-(NSArray *)getTableKeys{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when get table keys!");
        return nil;
    }
    
    //执行表结构查询命令
    FMResultSet *result = [self.database getTableSchema:kUserTable];
    NSMutableArray *columns = [NSMutableArray array];
    while ([result next]) {
        NSString *column = [result objectForColumnName:@"name"];
        [columns addObject:column];
    }
    
    //关闭数据库
    if (![self.database close]) {
        NSLog(@"User database close failed when get table keys!");
    }
    
    return columns;
}



/*
 -(QYUserInfo *)getUser:(NSString *)userId{
 //打开数据库
 if (![self.database open]) {
 NSLog(@"User database open failed when get User : %@!", userId);
 return nil;
 }
 
 //创建sql语句
 
 
 //执行sql
 
 //关闭数据库
 if (![self.database close]) {
 NSLog(@"User database close failed when get User : %@!", userId);
 }
 
 return nil;
 }
 */

//创建User表
-(void)createUserTable{
    //打开数据库
    if (![self.database open]) {
        NSLog(@"User database open failed when create user table!");
        return;
    }
    
    //创建表
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@ TEXT PRIMARY KEY, %@ TEXT, %@ INTEGER, %@ BOOL, %@ TEXT, %@ INTEGER, %@ BLOB, %@ INTEGER, %@ INTEGER)", kUserTable, kUserId, kUserName, kUserAge, kUserSex, kUserIconUrl, kUserMatchTime, @"keyedConversation", @"lastMessageAt", @"messageStatus"];
    NSLog(@"create User table sql : %@", sql);
    [self.database executeUpdate:sql];
    
    //关闭数据库
    [self.database close];
}

#pragma mark - Getters
-(FMDatabase *)database{
    if (_database == nil) {
        NSString *dbPath = [kTempDirectory stringByAppendingPathComponent:kUserDBFileName];
        NSLog(@"Users database : %@", dbPath);
        _database = [FMDatabase databaseWithPath:dbPath];
        //创建表
        [self createUserTable];
    }
    return _database;
}


@end
