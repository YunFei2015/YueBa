//
//  QYChatCell.h
//  约吧
//
//  Created by 云菲 on 4/14/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYChatModel;
@class QYUserInfo;

@interface QYChatCell : UITableViewCell
@property (strong, nonatomic) QYChatModel *chat;
@property (strong, nonatomic) QYUserInfo *user;
//@property (strong, nonatomic) NSString *message;

@end
