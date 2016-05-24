//
//  ViewController.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYMessageCell.h"
@class QYUserInfo;
@class AVIMConversation;


typedef void(^QYLastMessageDidChanged)(AVIMConversation *);

@interface QYChatVC : UIViewController
@property (strong, nonatomic) QYUserInfo *user;
@property (strong, nonatomic) QYLastMessageDidChanged lastMessageDidChanged;
@property (strong, nonatomic) QYMessageCell *selectedCell;//点击的cell

@property (nonatomic, getter=isPresented) BOOL presented;//标注该控制器是否模态出来的，默认为否（即压栈）
@end

