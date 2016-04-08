//
//  QYDataManager.m
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYDataManager.h"

@interface QYDataManager ()
@property (strong, nonatomic) NSString *documentDirPath;
@end

@implementation QYDataManager
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(BOOL)saveVoiceFileWithMessageID:(NSString *)messageID{
    NSString *voicePath = [self.documentDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", messageID]];
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:kAudioPath toPath:voicePath error:&error];
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    
    return YES;
}

-(NSString *)voiceFilePathForMessageID:(NSString *)messageID{
    NSString *voicePath = [self.documentDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", messageID]];
    return voicePath;
}

#pragma mark - getters
-(NSString *)documentDirPath{
    if (_documentDirPath == nil) {
        _documentDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    return _documentDirPath;
}


@end
