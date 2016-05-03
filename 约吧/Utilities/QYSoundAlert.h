//
//  QYSoundAlert.h
//  约吧
//
//  Created by 云菲 on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYSoundAlert : NSObject

+(instancetype)sharedInstance;

-(void)play;
-(void)pushNotificationPlay;


@end
