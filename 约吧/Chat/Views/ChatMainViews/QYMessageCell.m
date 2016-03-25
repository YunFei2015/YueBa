//
//  QYMessageCell.m
//  约吧
//
//  Created by 云菲 on 3/24/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMessageCell.h"
#import "FaceModel.h"
#import "UIImage+Extension.h"

#import <AVOSCloudIM.h>
#import <AVFile.h>

#define kIconViewW 40 //用户头像宽度
#define kIconViewH 40 //用户头像高度
#define kMaxMessageWidth kScreenW / 2 //消息最长宽度
#define kPhotoWidth kScreenW / 2.f //图片宽度
#define kPhotoHeight kScreenH / 3.f

@interface QYMessageCell ()


/**
 *  公共属性
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *chatBubbleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewRightConstraint;

-(void)maskPhotoToBubble:(UIImageView *)bubbleView;//将图片裁剪成气泡样式


/**
 *  位置
 */
@property (strong, nonatomic) UIView *locationView;


@end

@implementation QYMessageCell

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark - setters
-(void)setMessage:(AVIMMessage *)message{
    if (!message) {
        return;
    }
    _message = message;
}

-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
    if (!typedMessage) {
        return;
    }
    
    _typedMessage = typedMessage;
    
    if (_typedMessage.mediaType == kAVIMMessageMediaTypeImage) {
        [self maskPhotoToBubble:_chatBubbleView];
    }
}

-(void)setMessageCellType:(kMessageCellType)messageCellType{
    _messageCellType = messageCellType;
    
    [self layoutIfNeeded];
    if (_messageCellType == kMessageCellTypeReceive) {//接收消息的界面显示
        _chatBubbleView.image = [UIImage imageNamed:@"chat_bubble_gray"];
        _iconImageView.image = [UIImage imageNamed:@"小心"];
         //用户头像显示在左侧
        _iconImageViewLeftConstraint.active = YES;
        _iconImageViewRightConstraint.active = NO;
//        _iconImageViewLeftConstraint.priority = UILayoutPriorityRequired;
//        _iconImageViewRightConstraint.priority = UILayoutPriorityDefaultHigh;
        
        //灰色泡泡，位置在用户头像右侧
        _bubbleViewLeftConstraint.active = YES;
        _bubbleViewRightConstraint.active = NO;
//        _bubbleViewLeftConstraint.priority = UILayoutPriorityRequired;
//        _bubbleViewRightConstraint.priority = UILayoutPriorityDefaultHigh;
        
    }else if (_messageCellType == kMessageCellTypeSend){//发送消息的界面显示
        _chatBubbleView.image = [UIImage imageNamed:@"chat_bubble_red"];
        _iconImageView.image = [UIImage imageNamed:@"小丸子"];
        //用户头像显示在右侧
        _iconImageViewLeftConstraint.active = NO;
        _iconImageViewRightConstraint.active = YES;
//        _iconImageViewLeftConstraint.priority = UILayoutPriorityDefaultHigh;
//        _iconImageViewRightConstraint.priority = UILayoutPriorityRequired;
        
        //红色泡泡，位置在用户头像左侧
        _bubbleViewLeftConstraint.active = NO;
        _bubbleViewRightConstraint.active = YES;
//        _bubbleViewLeftConstraint.priority = UILayoutPriorityDefaultHigh;
//        _bubbleViewRightConstraint.priority = UILayoutPriorityRequired;
        
    }else{
        NSLog(@"这不可能！");
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

#pragma mark - getters
-(kMessageType)messageType{
    return _messageType;
}

-(AVIMMessage *)message{
    return _message;
}

-(AVIMTypedMessage *)typedMessage{
    return _typedMessage;
}

#pragma mark - custom methods
-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.contentView];
    NSLog(@"%f,%f", point.x, point.y);
    if (CGRectContainsPoint(self.chatBubbleView.frame, point)) {
        return YES;
    }
    
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

#pragma mark - QYTextMessageCell
/**
 *  文本
 */
@interface QYTextMessageCell ()
@property (weak, nonatomic) IBOutlet UILabel *textMessageLabel;//文本消息
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewWidthConstraint;
@end

@implementation QYTextMessageCell
-(void)setMessageCellType:(kMessageCellType)messageCellType{
    [super setMessageCellType:messageCellType];
    
    if (messageCellType == kMessageCellTypeReceive) {
        _textMessageLabel.textColor = [UIColor blackColor];
    }else if (messageCellType == kMessageCellTypeSend){
        _textMessageLabel.textColor = [UIColor whiteColor];
    }else{
        NSLog(@"这不可能！");
    }
}

-(void)setMessage:(AVIMMessage *)message{
    [super setMessage:message];
    
    _messageType = kMessageTypeText;
    _textMessageLabel.attributedText = [self faceAttributeTextWithMessage:[message content]];
    [self calculateLayoutWith:_textMessageLabel.attributedText];
}

-(NSAttributedString *)faceAttributeTextWithMessage:(NSString *)message{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Faces" ofType:@"plist"];
    NSArray *faces = [NSDictionary dictionaryWithContentsOfFile:path][kFaceTT];
    
    NSMutableAttributedString *messageAttriText = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    [faces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FaceModel *face = [FaceModel faceModelWithDictionary:obj];
        if ([message containsString:face.text]) {
            //创建富文本
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *image = [UIImage imageNamed:face.imgName];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, -8, image.size.width, image.size.height);
            NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            //用富文本替换表情文本
            NSRange resultRange;
            NSRange searchRange = NSMakeRange(0, messageAttriText.length);
            while ((resultRange = [[messageAttriText string] rangeOfString:face.text options:0 range:searchRange]).location != NSNotFound) {
                [messageAttriText replaceCharactersInRange:resultRange withAttributedString:attributeStr];
                resultRange.length = 1;
                searchRange = NSMakeRange(NSMaxRange(resultRange), messageAttriText.length - NSMaxRange(resultRange));
            }
        }
    }];
    return messageAttriText;
}

-(void)calculateLayoutWith:(NSAttributedString *)text{
    //根据文本内容调整布局
    CGRect rect = [text boundingRectWithSize:CGSizeMake(kMessageMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _bubbleViewWidthConstraint.constant = ceilf(rect.size.width) + 10 + 10;
}
@end

#pragma mark - QYVoiceMessageCell
/**
 *  语音
 */
@interface QYVoiceMessageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *voiceAnimatingView;//播放动画
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceAnimatingViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceAnimatingViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;//语音时长
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabRightConstraint;

@end
@implementation QYVoiceMessageCell
-(void)setMessageCellType:(kMessageCellType)messageCellType{
    [super setMessageCellType:messageCellType];
    
    if (messageCellType == kMessageCellTypeReceive) {
        _durationLabLeftConstraint.active = YES;
        _durationLabRightConstraint.active = NO;
//        _durationLabLeftConstraint.priority = 1000;
//        _durationLabRightConstraint.priority = 500;
        _durationLab.textAlignment = NSTextAlignmentLeft;
        
        _voiceAnimatingViewLeftConstraint.active = YES;
        _voiceAnimatingViewRightConstraint.active = NO;
//        _voiceAnimatingViewLeftConstraint.priority = 1000;
//        _voiceAnimatingViewRightConstraint.priority = 500;
        _voiceAnimatingView.image = [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
        _voiceAnimatingView.animationImages = @[
                                                [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                                                [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                                                [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                                                [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    }else if (messageCellType == kMessageCellTypeSend){
        _durationLabLeftConstraint.active = NO;
        _durationLabRightConstraint.active = YES;
//        _durationLabLeftConstraint.priority = 500;
//        _durationLabRightConstraint.priority = 1000;
        _durationLab.textAlignment = NSTextAlignmentRight;
        
        _voiceAnimatingViewLeftConstraint.active = NO;
        _voiceAnimatingViewRightConstraint.active = YES;
//        _voiceAnimatingViewLeftConstraint.priority = 500;
//        _voiceAnimatingViewRightConstraint.priority = 1000;
        _voiceAnimatingView.image = [UIImage imageNamed:@"SenderVoiceNodePlaying"];
        _voiceAnimatingView.animationImages = @[
                                                [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                                                [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                                                [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                                                [UIImage imageNamed:@"SenderVoiceNodePlaying003"]];
    }else{
        NSLog(@"这不可能");
    }
}

-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
    [super setTypedMessage:typedMessage];
    
    _messageType = kMessageTypeVoice;
    if (typedMessage.mediaType == kAVIMMessageMediaTypeAudio) {
        AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)_typedMessage;
        //下载音频文件，若之前下载过，不会重复下载
        [audioMessage.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            NSLog(@"音频数据下载成功");
            _durationLab.text = [NSString stringWithFormat:@"%.0f\"", audioMessage.duration];
            _voiceAnimatingView.animationDuration = 1;
            _voiceAnimatingView.animationRepeatCount = audioMessage.duration;
        }];
    }
}

-(void)startAnimating{
    [_voiceAnimatingView startAnimating];
}

-(void)stopAnimating{
    [_voiceAnimatingView stopAnimating];
}


@end

#pragma mark - QYPhotoMessageCell
/**
 *  图片
 */
@interface QYPhotoMessageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;//图片
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewHeightConstraint;
@end

@implementation QYPhotoMessageCell
-(void)awakeFromNib{
    _bubbleViewWidthConstraint.constant = kPhotoWidth;
    _bubbleViewHeightConstraint.constant = kPhotoHeight;
}
#pragma mark - setters
-(void)setMessageCellType:(kMessageCellType)messageCellType{
    [super setMessageCellType:messageCellType];
    
    if (messageCellType == kMessageCellTypeReceive) {
        
    }else if (messageCellType == kMessageCellTypeSend){
        
    }else{
        NSLog(@"这不可能");
    }
}

-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
    [super setTypedMessage:typedMessage];
    _messageType = kMessageTypePhoto;
    
    AVIMImageMessage *message = (AVIMImageMessage *)typedMessage;
    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        UIImage *photo = [image resizeToSize:CGSizeMake(kPhotoWidth, kPhotoHeight)];
        self.photoView.image = photo;
        [self layoutIfNeeded];
    }];
}

#pragma mark - custom methods
//将图片裁剪成气泡样式
-(void)maskPhotoToBubble:(UIImageView *)bubbleView{
    CALayer *layer = bubbleView.layer;
    layer.frame = CGRectMake(0, 0, kPhotoWidth, kPhotoHeight);
    self.photoView.layer.mask = layer;
    [self.photoView setNeedsDisplay];
}
@end

#pragma mark - QYLocationMessageCell
@implementation QYLocationMessageCell
-(void)setMessageCellType:(kMessageCellType)messageCellType{
    [super setMessageCellType:messageCellType];
    
    if (messageCellType == kMessageCellTypeReceive) {
        
    }else if (messageCellType == kMessageCellTypeSend){
        
    }else{
        NSLog(@"这不可能");
    }
}

-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
    [super setTypedMessage:typedMessage];
    
    _messageType = kMessageTypeLocation;
}
@end
