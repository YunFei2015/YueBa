//
//  QYChatCell.m
//  约吧
//
//  Created by 云菲 on 4/14/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYChatCell.h"
#import "QYUserInfo.h"

#import "UIView+Extension.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"

#import <AVIMMessage.h>
#import <AVIMTypedMessage.h>

@interface QYChatCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestMessageLabel;

@end

@implementation QYChatCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)setChat:(QYChatModel *)chat{
//    _chat = chat;
//    
//    _iconImageView.image = [UIImage imageNamed:.user.iconUrl];
//    [UIView drawRoundCornerOnImageView:_iconImageView];
//    
//    _nameLabel.text = _chat.user.name;
//    
//    [self configMessageLabel];
//}

-(void)setUser:(QYUserInfo *)user{
    _user = user;
    
    _iconImageView.image = [UIImage imageNamed:user.iconUrl];
    [UIView drawRoundCornerOnImageView:_iconImageView];
    
    _nameLabel.text = user.name;
    
    [self configMessageLabel];
}

//-(void)setMessage:(NSString *)message{
//    _message = message;
//    
//    _latestMessageLabel.text = _message;
//}

-(void)configMessageLabel{
//#if 1
    //如果没有聊过天，显示配对时间
    if (_user.message) {
        //如果最后一条消息是普通文本，则显示普通文本
        _latestMessageLabel.attributedText = [NSString faceAttributeTextWithMessage:_user.message withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]} faceSize:20];
    }else{
        NSString *timeString = [_user.matchTime stringFromDateWithFormatter:@"MM/dd"];
        _latestMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"配对于%@", timeString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    }

//#endif
    
    
}

@end
