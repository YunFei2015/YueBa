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
}

-(void)setConversation:(AVIMConversation *)conversation{
    _conversation = conversation;
    if (conversation) {
        NSArray *objects = [conversation queryMessagesFromCacheWithLimit:1];
        if (objects.count > 0) {//如果会话存在，且有历史消息，则显示历史消息
            [self configMessageLabelWithMessage:objects[0]];
        }else{//如果会话存在，但是没有历史消息，则显示配对时间
            [self configMessageLabelWithNoMessage];
        }
    }else{//如果会话不存在，则显示配对时间
        [self configMessageLabelWithNoMessage];
    }
}

-(void)configMessageLabelWithMessage:(AVIMTypedMessage *)message{
    NSString *content = [NSString string];
    switch (message.mediaType) {
        case kAVIMMessageMediaTypeText:
            content = message.text;
            break;
            
        case kAVIMMessageMediaTypeAudio:
            content = @"[语音]";
            break;
            
        case kAVIMMessageMediaTypeImage:
            content = @"[图片]";
            break;
            
        case kAVIMMessageMediaTypeLocation:
            content = @"[位置]";
            break;
            
        default:
            break;
    }
     _latestMessageLabel.attributedText = [NSString faceAttributeTextWithMessage:content withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor lightGrayColor]} faceSize:20];
}

-(void)configMessageLabelWithNoMessage{
    NSString *timeString = [_user.matchTime stringFromDateWithFormatter:@"yyyy.MM.dd"];
    _latestMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"配对于 %@", timeString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
}

@end
