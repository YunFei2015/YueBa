//
//  QYDataManager.m
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYDataStorage.h"
#import <FMDB.h>



@interface QYDataStorage ()
@property (strong, nonatomic) FMDatabase *database;

@end

@implementation QYDataStorage
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)createDatabase{
    
}

-(void)saveUsers:(NSArray *)users{
    
}

-(void)deleteUser:(NSString *)userId{
    
}

-(QYUserInfo *)getUser:(NSString *)userId{
    return nil;
}

-(NSArray *)getAllUsers{
    return nil;
}

#pragma mark - Getters
-(FMDatabase *)database{
    if (_database == nil) {
        
    }
    return _database;
}




//-(BOOL)saveVoiceFileWithMessageID:(NSString *)messageID{
//    NSString *voicePath = [kDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", messageID]];
//    NSError *error;
//    [[NSFileManager defaultManager] copyItemAtPath:kAudioPath toPath:voicePath error:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        return NO;
//    }
//    
//    return YES;
//}
//
//-(NSString *)voiceFilePathForMessageID:(NSString *)messageID{
//    NSString *voicePath = [kDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", messageID]];
//    return voicePath;
//}




@end
