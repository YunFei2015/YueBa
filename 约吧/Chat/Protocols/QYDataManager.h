//
//  QYDataManager.h
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYDataManager : NSObject

+(instancetype)sharedInstance;
-(BOOL)saveVoiceFileWithMessageID:(NSString *)messageID;
-(NSString *)voiceFilePathForMessageID:(NSString *)messageID;
@end
