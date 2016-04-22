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

#import <AVIMConversation.h>
#import <AVIMMessage.h>
#import <AVIMTypedMessage.h>

@interface QYChatCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageStatusImgView;

@end

@implementation QYChatCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}

-(void)setUser:(QYUserInfo *)user{
    _user = user;
    
    _iconImageView.image = [UIImage imageNamed:user.iconUrl];
    [UIView drawRoundCornerOnImageView:_iconImageView];
    
    _nameLabel.text = user.name;
    self.status = user.messageStatus;
}

-(void)setStatus:(QYMessageStatus)status{
    _status = status;
    
    switch (status) {
        case QYMessageStatusDefault://消息正常(已读或发送成功的消息)
            _messageStatusImgView.image = [[UIImage alloc] init];
            break;
            
        case QYMessageStatusUnread://消息未读
            _messageStatusImgView.image = [UIImage imageNamed:@"chat_unread_message_icon"];
            break;
            
        case QYMessageStatusFailed://消息发送失败
            _messageStatusImgView.image = [UIImage imageNamed:@"chat_error_icon"];
            break;
            
        default:
            break;
    }
}

-(void)setMessage:(NSString *)message{
    if (message) {
        _latestMessageLabel.attributedText = [NSString faceAttributeTextWithMessage:message withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor lightGrayColor]} faceSize:20];
        
        
    }else{
        _messageStatusImgView.image = [[UIImage alloc] init];
        [self configMessageLabelWithNoMessage];
    }
}

-(void)configMessageLabelWithNoMessage{
    NSString *timeString = [_user.matchTime stringFromDateWithFormatter:@"yyyy.MM.dd"];
    _latestMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"配对于 %@", timeString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
}

@end
