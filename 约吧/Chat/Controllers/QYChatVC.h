//
//  ViewController.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendModel;
@class AVIMConversation;

@interface QYChatVC : UIViewController
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *targetUserName;
@property (strong, nonatomic) AVIMConversation *conversation;
@property (strong, nonatomic) FriendModel *friendModel;


//-(instancetype)initWithFriend:(FriendModel *)friendModel;

@end

