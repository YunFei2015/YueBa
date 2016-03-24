//
//  MessageTableViewCell.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVIMMessage;
@class AVIMTypedMessage;

@interface MessageTableViewCell : UITableViewCell
{
    AVIMMessage *_message;
    AVIMTypedMessage *_typedMessage;
    NSAttributedString *_attributedText;
}

@property (strong, nonatomic) AVIMMessage *message;
@property (strong, nonatomic) AVIMTypedMessage *typedMessage;
@property (weak, nonatomic) IBOutlet UIImageView *messageTypeImageView;

-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap;
//-(void)tapCellAction:(UITapGestureRecognizer *)tap;
@end

@interface LeftMessageTableViewCell : MessageTableViewCell

@end

@interface RightMessageTableViewCell : MessageTableViewCell

@end
