//
//  UIViewController+Extension.h
//  约吧
//
//  Created by 云菲 on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYUserInfo;

@interface UIViewController (Extension)

-(void)presentToNewFriendControllerForUser:(QYUserInfo *)user;
@end
