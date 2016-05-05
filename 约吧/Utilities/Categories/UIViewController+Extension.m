//
//  UIViewController+Extension.m
//  约吧
//
//  Created by 云菲 on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "QYNewFriendVC.h"
#import "QYChatVC.h"
#import "QYUserStorage.h"
#import "QYUserInfo.h"

@implementation UIViewController (Extension)

-(void)presentToNewFriendControllerForUser:(QYUserInfo *)user{
    UIStoryboard *friendStoryboard = [UIStoryboard storyboardWithName:@"NewFriend" bundle:nil];
    QYNewFriendVC *friendVC = [friendStoryboard instantiateInitialViewController];
    friendVC.friend = user;
    friendVC.talkToNewFriend = ^(QYUserInfo *user){
        QYChatVC *chatVC = [[QYChatVC alloc] init];
        chatVC.user = user;
        chatVC.presented = YES;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
        [self presentViewController:nav animated:YES completion:nil];
    };
    
    [self presentViewController:friendVC animated:YES completion:nil];
}
@end
