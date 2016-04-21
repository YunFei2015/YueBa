//
//  QYChatCell.h
//  约吧
//
//  Created by 云菲 on 4/14/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYUserInfo;
@class AVIMConversation;

@interface QYChatCell : UITableViewCell
@property (strong, nonatomic) QYUserInfo *user;
@property (strong, nonatomic) NSString *message;
@property (nonatomic) QYMessageStatus status;
@end
