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
    
//    [self configMessageLabel];
}


-(void)configMessageLabel{
#if 0
    //如果没有聊过天，显示配对时间
    if (_user.message) {
        //如果最后一条消息是普通文本，则显示普通文本
        _latestMessageLabel.attributedText = [NSString faceAttributeTextWithMessage:_user.message withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]} faceSize:20];
    }else{
        NSString *timeString = [_user.matchTime stringFromDateWithFormatter:@"MM/dd"];
        _latestMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"配对于%@", timeString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    }

#endif
}

-(void)setConversation:(AVIMConversation *)conversation{
    _conversation = conversation;
    if (conversation) {
        [conversation queryMessagesWithLimit:1 callback:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {//如果会话存在，且有历史消息，则显示历史消息
                [self configMessageLabelWithMessage:objects[0]];
            }else{//如果会话存在，但是没有历史消息，则显示配对时间
                [self configMessageLabelWithNoMessage];
            }
        }];
    }else{//如果会话不存在，则显示配对时间
        [self configMessageLabelWithNoMessage];
    }
}

-(void)configMessageLabelWithMessage:(id)object{
    NSString *content = [NSString string];
    if ([object isKindOfClass:[AVIMTypedMessage class]]) {
        AVIMTypedMessage *message = (AVIMTypedMessage *)object;
        switch (message.mediaType) {
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
    }else{
        AVIMMessage *message = (AVIMMessage *)object;
        content = message.content;
    }
    
    _latestMessageLabel.attributedText = [NSString faceAttributeTextWithMessage:content withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]} faceSize:20];
}

-(void)configMessageLabelWithNoMessage{
    NSString *timeString = [_user.matchTime stringFromDateWithFormatter:@"MM/dd"];
    _latestMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"配对于%@", timeString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
}

@end
