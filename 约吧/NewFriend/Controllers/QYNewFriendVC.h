//
//  QYNewFriendVC.h
//  约吧
//
//  Created by 云菲 on 16/5/3.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYUserInfo;

typedef void(^talkToNewFriendBlock)(QYUserInfo *);

@interface QYNewFriendVC : UIViewController

@property (strong, nonatomic) QYUserInfo *friend;
@property (copy, nonatomic) talkToNewFriendBlock talkToNewFriend;

@end
